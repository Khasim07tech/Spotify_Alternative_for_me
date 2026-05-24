import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/playlist.dart';
import '../models/track.dart';

abstract interface class StreamingService {
  Future<List<Track>> trendingTracks();

  Future<List<Track>> searchTracks(String query);

  Future<List<Track>> artistTracks(String artist);

  Future<List<Playlist>> featuredPlaylists();
}

class OpenMusicStreamingService implements StreamingService {
  OpenMusicStreamingService({http.Client? client}) : _client = client;

  static const _appName = 'KXWave';
  static const _jamendoClientId = String.fromEnvironment('JAMENDO_CLIENT_ID');
  final http.Client? _client;
  final Map<String, List<Track>> _trackCache = {};
  List<Playlist>? _playlistCache;

  http.Client get _http => _client ?? http.Client();

  @override
  Future<List<Track>> trendingTracks() async {
    final cached = _trackCache['trending'];
    if (cached != null) {
      return cached;
    }
    final audius = await _fetchAudiusTrending();
    if (audius.isNotEmpty) {
      _trackCache['trending'] = audius;
      return audius;
    }
    final jamendo = await _fetchJamendo('electronic');
    _trackCache['trending'] = jamendo;
    return jamendo;
  }

  @override
  Future<List<Track>> searchTracks(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return trendingTracks();
    }
    final cacheKey = 'search:${trimmed.toLowerCase()}';
    final cached = _trackCache[cacheKey];
    if (cached != null) {
      return cached;
    }
    final results = <Track>[
      ...await _fetchAudiusSearch(trimmed),
      ...await _fetchJamendo(trimmed),
    ];
    final deduped = _dedupe(results);
    _trackCache[cacheKey] = deduped;
    return deduped;
  }

  @override
  Future<List<Track>> artistTracks(String artist) {
    return searchTracks(artist);
  }

  @override
  Future<List<Playlist>> featuredPlaylists() async {
    final cached = _playlistCache;
    if (cached != null) {
      return cached;
    }
    final tracks = await trendingTracks();
    _playlistCache = [
      Playlist(
        id: 'kx-trending',
        title: 'KX Trending',
        subtitle: 'Live Audius open-streaming signals',
        trackCount: tracks.length,
        colorValue: 0xFF00F5FF,
      ),
      const Playlist(
        id: 'jamendo-open',
        title: 'Jamendo Open',
        subtitle: 'Creative Commons catalog when API key is configured',
        trackCount: 20,
        colorValue: 0xFFC0C7D2,
      ),
    ];
    return _playlistCache!;
  }

  Future<List<Track>> _fetchAudiusTrending() async {
    final uri = Uri.https('api.audius.co', '/v1/tracks/trending', {
      'app_name': _appName,
      'limit': '24',
    });
    return _getJson(uri, (json) {
      final data = json['data'];
      if (data is! List) {
        return const <Track>[];
      }
      return data
          .whereType<Map<String, Object?>>()
          .where((track) => track['is_streamable'] != false)
          .where(_hasOpenLicense)
          .map(_audiusTrack)
          .toList();
    });
  }

  Future<List<Track>> _fetchAudiusSearch(String query) async {
    final uri = Uri.https('api.audius.co', '/v1/tracks/search', {
      'app_name': _appName,
      'query': query,
      'limit': '20',
    });
    return _getJson(uri, (json) {
      final data = json['data'];
      if (data is! List) {
        return const <Track>[];
      }
      return data
          .whereType<Map<String, Object?>>()
          .where((track) => track['is_streamable'] != false)
          .where(_hasOpenLicense)
          .map(_audiusTrack)
          .toList();
    });
  }

  Future<List<Track>> _fetchJamendo(String query) async {
    if (_jamendoClientId.isEmpty) {
      return const [];
    }
    final uri = Uri.https('api.jamendo.com', '/v3.0/tracks/', {
      'client_id': _jamendoClientId,
      'format': 'json',
      'limit': '20',
      'audioformat': 'mp32',
      'search': query,
    });
    return _getJson(uri, (json) {
      final data = json['results'];
      if (data is! List) {
        return const <Track>[];
      }
      return data.whereType<Map<String, Object?>>().map(_jamendoTrack).toList();
    });
  }

  Future<List<T>> _getJson<T>(
    Uri uri,
    List<T> Function(Map<String, Object?> json) mapper,
  ) async {
    try {
      final response = await _http.get(uri).timeout(const Duration(seconds: 9));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return const [];
      }
      return mapper(decoded);
    } catch (_) {
      return const [];
    }
  }

  Track _audiusTrack(Map<String, Object?> json) {
    final id = _string(json['id']);
    final title = _string(json['title'], fallback: 'Audius Track');
    final user = json['user'];
    final artist = user is Map<String, Object?>
        ? _string(user['name'], fallback: 'Audius Artist')
        : 'Audius Artist';
    final duration = Duration(seconds: _int(json['duration'], fallback: 180));
    final license = _string(json['license'], fallback: 'Open Audius streaming');
    return Track(
      id: 'audius-$id',
      title: title,
      artist: artist,
      collection: 'Audius Trending',
      duration: duration,
      colorValue: 0xFF00F5FF,
      streamUrl: 'https://api.audius.co/v1/tracks/$id/stream?app_name=$_appName',
      sourceName: 'Audius',
      license: license,
    );
  }

  Track _jamendoTrack(Map<String, Object?> json) {
    final id = _string(json['id']);
    return Track(
      id: 'jamendo-$id',
      title: _string(json['name'], fallback: 'Jamendo Track'),
      artist: _string(json['artist_name'], fallback: 'Jamendo Artist'),
      collection: _string(json['album_name'], fallback: 'Jamendo Open'),
      duration: Duration(seconds: _int(json['duration'], fallback: 180)),
      colorValue: 0xFFC0C7D2,
      streamUrl: _string(json['audio'], fallback: ''),
      sourceName: 'Jamendo',
      license: 'Creative Commons / Jamendo',
    );
  }

  List<Track> _dedupe(List<Track> tracks) {
    final seen = <String>{};
    return [
      for (final track in tracks)
        if (track.streamUrl.isNotEmpty && seen.add(track.id)) track,
    ];
  }

  String _string(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  int _int(Object? value, {required int fallback}) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _hasOpenLicense(Map<String, Object?> track) {
    final license = _string(track['license']).toLowerCase();
    if (license.isEmpty || license.contains('all rights reserved')) {
      return false;
    }
    return license.contains('creative commons') ||
        license.contains('cc') ||
        license.contains('public domain') ||
        license.contains('open');
  }
}
