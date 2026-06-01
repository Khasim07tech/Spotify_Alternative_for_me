import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../models/spotify_profile.dart';

class SpotifyService {
  SpotifyService({
    http.Client? client,
    FlutterSecureStorage? storage,
  })  : _client = client ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _clientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');
  static const _redirectUri = String.fromEnvironment(
    'SPOTIFY_REDIRECT_URI',
    defaultValue: 'https://kxwave.app/spotify-auth',
  );
  static const _authBaseUrl = 'https://accounts.spotify.com';
  static const _apiBaseUrl = 'https://api.spotify.com/v1';
  static const _accessTokenKey = 'spotify_access_token';
  static const _refreshTokenKey = 'spotify_refresh_token';
  static const _expiresAtKey = 'spotify_expires_at';
  static const _verifierKey = 'spotify_pkce_verifier';
  static const _cachedProfileKey = 'spotify_cached_profile';

  final http.Client _client;
  final FlutterSecureStorage _storage;

  bool get isConfigured => _clientId.isNotEmpty;

  SpotifyProfile demoProfile() {
    return SpotifyProfile(
      topTracks: const [
        'Ole Miss Rag - W. C. Handy',
        'KX City Pulse - Local demo',
        'KX Midnight Blues - Local demo',
      ],
      topArtists: const [
        'W. C. Handy',
        "Sodero's Band",
        "King Oliver's Jazz Band",
      ],
      genres: const ['ragtime', 'jazz', 'instrumental', 'focus'],
      playlists: const ['KX Focus Signal', 'KX Pulse Drive'],
      recentTracks: const ['KX Neon Rag', 'KX Blue Rhapsody'],
      syncedAt: DateTime.now(),
    );
  }

  Future<bool> hasSession() async {
    return (await _storage.read(key: _refreshTokenKey)) != null ||
        (await _storage.read(key: _accessTokenKey)) != null;
  }

  Future<void> launchAuthorization() async {
    if (!isConfigured) {
      final profile = demoProfile();
      await _storage.write(key: _cachedProfileKey, value: jsonEncode(profile.toJson()));
      return;
    }
    final verifier = _generateVerifier();
    await _storage.write(key: _verifierKey, value: verifier);
    final challenge = _codeChallenge(verifier);
    final uri = Uri.parse('$_authBaseUrl/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': _clientId,
        'redirect_uri': _redirectUri,
        'scope': [
          'user-top-read',
          'user-read-recently-played',
          'playlist-read-private',
          'playlist-read-collaborative',
        ].join(' '),
        'code_challenge_method': 'S256',
        'code_challenge': challenge,
      },
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const SpotifyException('Could not open Spotify login.');
    }
  }

  Future<void> completeAuthorization(String code) async {
    _ensureConfigured();
    final verifier = await _storage.read(key: _verifierKey);
    if (verifier == null) {
      throw const SpotifyException('Start Spotify login before entering a code.');
    }

    final response = await _sendWithRetry(
      () => _client.post(
        Uri.parse('$_authBaseUrl/api/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'authorization_code',
          'code': code.trim(),
          'redirect_uri': _redirectUri,
          'client_id': _clientId,
          'code_verifier': verifier,
        },
      ),
    );
    final body = _decodeObject(response);
    if (response.statusCode >= 400) {
      throw SpotifyException(_errorMessage(body, 'Spotify login failed.'));
    }
    await _storeTokenResponse(body);
  }

  Future<SpotifyProfile?> cachedProfile() async {
    final raw = await _storage.read(key: _cachedProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return SpotifyProfile.fromJson(decoded);
  }

  Future<void> saveImportedProfile(SpotifyProfile profile) async {
    await _storage.write(key: _cachedProfileKey, value: jsonEncode(profile.toJson()));
    await _storeProfileInFirestore(profile);
  }

  Future<SpotifyProfile> syncProfile() async {
    if (!isConfigured) {
      final profile = demoProfile();
      await _storage.write(key: _cachedProfileKey, value: jsonEncode(profile.toJson()));
      await _storeProfileInFirestore(profile);
      return profile;
    }
    final token = await _validAccessToken();
    final results = await Future.wait([
      _get(token, '/me/top/tracks', {'limit': '10', 'time_range': 'medium_term'}),
      _get(token, '/me/top/artists', {'limit': '10', 'time_range': 'medium_term'}),
      _get(token, '/me/playlists', {'limit': '10'}),
      _get(token, '/me/player/recently-played', {'limit': '10'}),
    ]);

    final topTracks = _trackNames(results[0]);
    final artistData = results[1]['items'];
    final topArtists = _names(artistData);
    final genres = _genres(artistData);
    final playlists = _names(results[2]['items']);
    final recentTracks = _recentTrackNames(results[3]['items']);
    final profile = SpotifyProfile(
      topTracks: topTracks,
      topArtists: topArtists,
      genres: genres,
      playlists: playlists,
      recentTracks: recentTracks,
      syncedAt: DateTime.now(),
    );

    await _storage.write(key: _cachedProfileKey, value: jsonEncode(profile.toJson()));
    await _storeProfileInFirestore(profile);
    return profile;
  }

  Future<void> disconnect() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
      _storage.delete(key: _verifierKey),
      _storage.delete(key: _cachedProfileKey),
    ]);
  }

  Future<Map<String, Object?>> _get(
    String token,
    String path,
    Map<String, String> queryParameters,
  ) async {
    final response = await _sendWithRetry(
      () => _client.get(
        Uri.parse('$_apiBaseUrl$path').replace(queryParameters: queryParameters),
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    final body = _decodeObject(response);
    if (response.statusCode >= 400) {
      throw SpotifyException(_errorMessage(body, 'Spotify sync failed.'));
    }
    return body;
  }

  Future<String> _validAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    final expiresAt = int.tryParse(await _storage.read(key: _expiresAtKey) ?? '');
    final now = DateTime.now().millisecondsSinceEpoch;
    if (token != null && expiresAt != null && expiresAt > now + 60000) {
      return token;
    }
    return _refreshAccessToken();
  }

  Future<String> _refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null) {
      throw const SpotifyException('Connect Spotify before syncing.');
    }
    final response = await _sendWithRetry(
      () => _client.post(
        Uri.parse('$_authBaseUrl/api/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': _clientId,
        },
      ),
    );
    final body = _decodeObject(response);
    if (response.statusCode >= 400) {
      throw SpotifyException(_errorMessage(body, 'Spotify session expired.'));
    }
    await _storeTokenResponse(body, fallbackRefreshToken: refreshToken);
    return body['access_token'].toString();
  }

  Future<void> _storeTokenResponse(
    Map<String, Object?> body, {
    String? fallbackRefreshToken,
  }) async {
    final accessToken = body['access_token']?.toString();
    if (accessToken == null || accessToken.isEmpty) {
      throw const SpotifyException('Spotify did not return an access token.');
    }
    final expiresIn = int.tryParse(body['expires_in']?.toString() ?? '') ?? 3600;
    final refreshToken = body['refresh_token']?.toString() ?? fallbackRefreshToken;
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn)).millisecondsSinceEpoch;
    await _storage.write(key: _expiresAtKey, value: expiresAt.toString());
  }

  Future<void> _storeProfileInFirestore(SpotifyProfile profile) async {
    if (!FirebaseBootstrap.isConfigured || !FirebaseBootstrap.isInitialized) {
      return;
    }
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    await FirebaseFirestore.instance
        .collection('tasteProfiles')
        .doc(uid)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  Map<String, Object?> _decodeObject(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }
    return {'error_description': 'Unexpected Spotify response.'};
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() request,
  ) async {
    var delay = const Duration(milliseconds: 600);
    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await request().timeout(const Duration(seconds: 15));
      if (response.statusCode != 429 || attempt == 2) {
        return response;
      }
      final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
      await Future<void>.delayed(
        retryAfter == null ? delay : Duration(seconds: retryAfter),
      );
      delay *= 2;
    }
    return request().timeout(const Duration(seconds: 15));
  }

  String _errorMessage(Map<String, Object?> body, String fallback) {
    final description = body['error_description']?.toString();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    final error = body['error'];
    if (error is Map<String, Object?>) {
      return error['message']?.toString() ?? fallback;
    }
    return fallback;
  }

  void _ensureConfigured() {
    if (!isConfigured) {
      throw const SpotifyException(
        'Add SPOTIFY_CLIENT_ID as a dart-define before using Spotify sync.',
      );
    }
  }

  String _generateVerifier() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~';
    final random = Random.secure();
    return List.generate(64, (_) => alphabet[random.nextInt(alphabet.length)]).join();
  }

  String _codeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  List<String> _names(Object? items) {
    if (items is! List) {
      return const [];
    }
    return items
        .whereType<Map<String, Object?>>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<String> _trackNames(Map<String, Object?> payload) {
    final items = payload['items'];
    if (items is! List) {
      return const [];
    }
    return items.whereType<Map<String, Object?>>().map((item) {
      final artists = _names(item['artists']).join(', ');
      final name = item['name']?.toString() ?? '';
      return artists.isEmpty ? name : '$name - $artists';
    }).where((name) => name.isNotEmpty).toList();
  }

  List<String> _recentTrackNames(Object? items) {
    if (items is! List) {
      return const [];
    }
    return items.whereType<Map<String, Object?>>().map((item) {
      final track = item['track'];
      if (track is! Map<String, Object?>) {
        return '';
      }
      final artists = _names(track['artists']).join(', ');
      final name = track['name']?.toString() ?? '';
      return artists.isEmpty ? name : '$name - $artists';
    }).where((name) => name.isNotEmpty).toList();
  }

  List<String> _genres(Object? artists) {
    if (artists is! List) {
      return const [];
    }
    final counts = <String, int>{};
    for (final artist in artists.whereType<Map<String, Object?>>()) {
      final genres = artist['genres'];
      if (genres is! List) {
        continue;
      }
      for (final genre in genres) {
        final key = genre.toString();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(12).map((entry) => entry.key).toList();
  }
}

class SpotifyException implements Exception {
  const SpotifyException(this.message);

  final String message;

  @override
  String toString() => message;
}
