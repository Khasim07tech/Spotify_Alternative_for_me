import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/track.dart';

class DownloadService {
  DownloadService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  })  : _client = client ?? http.Client(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  static const _manifestKey = 'kx.download.manifest.v1';
  static const _cacheKey = 'kx.download.cache.key';

  final http.Client _client;
  final FlutterSecureStorage _secureStorage;
  final StreamController<Map<String, double>> _progressController =
      StreamController<Map<String, double>>.broadcast();
  Map<String, double> _progress = {};

  Stream<Map<String, double>> get progressStream => _progressController.stream;

  Future<List<Track>> downloadedTracks() async {
    final manifest = await _readManifest();
    return manifest.map(_trackFromJson).toList(growable: false);
  }

  Future<bool> isDownloaded(String trackId) async {
    final manifest = await _readManifest();
    return manifest.any((item) => item['id'] == trackId);
  }

  Future<Track> download(Track track) async {
    await _ensureCacheKey();
    final directory = await _downloadDirectory();
    final file = File('${directory.path}/${_safeFileName(track.id)}.mp3');
    final request = http.Request('GET', Uri.parse(track.streamUrl));
    final response = await _client.send(request).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DownloadException('Download failed with status ${response.statusCode}.');
    }

    final sink = file.openWrite();
    var received = 0;
    final total = response.contentLength;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        if (total != null && total > 0) {
          _setProgress(track.id, received / total);
        } else {
          _setProgress(track.id, 0.1);
        }
      }
    } finally {
      await sink.close();
    }
    _setProgress(track.id, 1);

    final offlineTrack = track.copyWith(
      streamUrl: file.uri.toString(),
      sourceName: '${track.sourceName} offline',
    );
    final manifest = await _readManifest();
    manifest.removeWhere((item) => item['id'] == track.id);
    manifest.add(_trackToJson(offlineTrack, file.path));
    await _writeManifest(manifest);
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      _clearProgress(track.id);
    });
    return offlineTrack;
  }

  Future<void> remove(String trackId) async {
    final manifest = await _readManifest();
    final item = manifest.where((entry) => entry['id'] == trackId).firstOrNull;
    if (item != null) {
      final path = item['filePath']?.toString();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
    manifest.removeWhere((entry) => entry['id'] == trackId);
    await _writeManifest(manifest);
  }

  Future<Track> importLocalAudio(File sourceFile) async {
    await _ensureCacheKey();
    if (!await sourceFile.exists()) {
      throw const DownloadException('Selected audio file no longer exists.');
    }
    final directory = await _downloadDirectory();
    final name = sourceFile.uri.pathSegments.isEmpty
        ? 'Local audio'
        : Uri.decodeComponent(sourceFile.uri.pathSegments.last);
    final id = 'local-${DateTime.now().microsecondsSinceEpoch}';
    final extension = _extensionFor(name);
    final destination = File('${directory.path}/${_safeFileName(id)}$extension');
    await sourceFile.copy(destination.path);
    final track = Track(
      id: id,
      title: _titleFor(name),
      artist: 'Local file',
      collection: 'Imported audio',
      duration: Duration.zero,
      colorValue: 0xFF00F5FF,
      streamUrl: destination.uri.toString(),
      sourceName: 'Device library',
      license: 'User imported local audio',
    );
    final manifest = await _readManifest();
    manifest.add(_trackToJson(track, destination.path));
    await _writeManifest(manifest);
    return track;
  }

  Future<Directory> _downloadDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final directory = Directory('${base.path}/kx_wave_downloads');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Future<List<Map<String, Object?>>> _readManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_manifestKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return [];
    }
    return decoded.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  Future<void> _writeManifest(List<Map<String, Object?>> manifest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_manifestKey, jsonEncode(manifest));
  }

  Future<void> _ensureCacheKey() async {
    final existing = await _secureStorage.read(key: _cacheKey);
    if (existing != null) {
      return;
    }
    await _secureStorage.write(
      key: _cacheKey,
      value: DateTime.now().microsecondsSinceEpoch.toRadixString(16),
    );
  }

  Map<String, Object?> _trackToJson(Track track, String filePath) {
    return {
      'id': track.id,
      'title': track.title,
      'artist': track.artist,
      'collection': track.collection,
      'durationMs': track.duration.inMilliseconds,
      'colorValue': track.colorValue,
      'streamUrl': track.streamUrl,
      'sourceName': track.sourceName,
      'license': track.license,
      'filePath': filePath,
    };
  }

  Track _trackFromJson(Map<String, Object?> json) {
    return Track(
      id: json['id'].toString(),
      title: json['title'].toString(),
      artist: json['artist'].toString(),
      collection: json['collection'].toString(),
      duration: Duration(
        milliseconds: int.tryParse(json['durationMs'].toString()) ?? 0,
      ),
      colorValue: int.tryParse(json['colorValue'].toString()) ?? 0xFF00F5FF,
      streamUrl: json['streamUrl'].toString(),
      sourceName: json['sourceName'].toString(),
      license: json['license'].toString(),
    );
  }

  String _safeFileName(String value) {
    return value.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
  }

  String _extensionFor(String value) {
    final lower = value.toLowerCase();
    for (final extension in const ['.mp3', '.m4a', '.aac', '.wav', '.ogg', '.flac']) {
      if (lower.endsWith(extension)) {
        return extension;
      }
    }
    return '.mp3';
  }

  String _titleFor(String value) {
    final withoutExtension = value.replaceFirst(RegExp(r'\.[^.]+$'), '');
    return withoutExtension.trim().isEmpty ? 'Local audio' : withoutExtension.trim();
  }

  void _setProgress(String trackId, double value) {
    _progress = {..._progress, trackId: value.clamp(0, 1)};
    _progressController.add(_progress);
  }

  void _clearProgress(String trackId) {
    _progress = {..._progress}..remove(trackId);
    _progressController.add(_progress);
  }
}

class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
