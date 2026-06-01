import 'dart:convert';
import 'dart:io';

import '../models/spotify_profile.dart';

class SpotifyImportService {
  const SpotifyImportService();

  Future<SpotifyProfile> importFile(File file) async {
    final text = await file.readAsString();
    final lowerPath = file.path.toLowerCase();
    if (lowerPath.endsWith('.csv') || lowerPath.endsWith('.txt')) {
      return _profileFromRows(_readCsvLike(text));
    }
    final decoded = jsonDecode(text);
    return _profileFromRows(_readJson(decoded));
  }

  SpotifyProfile _profileFromRows(List<_ImportedRow> rows) {
    if (rows.isEmpty) {
      throw const SpotifyImportException('No Spotify songs were found in that file.');
    }
    final trackCounts = <String, int>{};
    final artistCounts = <String, int>{};
    final playlistCounts = <String, int>{};
    final recentTracks = <String>[];

    for (final row in rows) {
      if (row.track.isNotEmpty) {
        final trackLabel = row.artist.isEmpty ? row.track : '${row.track} - ${row.artist}';
        trackCounts[trackLabel] = (trackCounts[trackLabel] ?? 0) + 1;
        if (recentTracks.length < 20) {
          recentTracks.add(trackLabel);
        }
      }
      if (row.artist.isNotEmpty) {
        artistCounts[row.artist] = (artistCounts[row.artist] ?? 0) + 1;
      }
      if (row.playlist.isNotEmpty) {
        playlistCounts[row.playlist] = (playlistCounts[row.playlist] ?? 0) + 1;
      }
    }

    return SpotifyProfile(
      topTracks: _top(trackCounts, 25),
      topArtists: _top(artistCounts, 20),
      genres: _inferGenres(artistCounts.keys, trackCounts.keys),
      playlists: _top(playlistCounts, 20),
      recentTracks: recentTracks,
      syncedAt: DateTime.now(),
    );
  }

  List<_ImportedRow> _readJson(Object? decoded, {String playlist = ''}) {
    final rows = <_ImportedRow>[];
    if (decoded is List) {
      for (final item in decoded) {
        rows.addAll(_readJson(item, playlist: playlist));
      }
      return rows;
    }
    if (decoded is! Map) {
      return rows;
    }
    final map = decoded.map((key, value) => MapEntry(key.toString(), value));

    final playlistName = _string(map['name']).isNotEmpty && _hasPlaylistItems(map)
        ? _string(map['name'])
        : playlist;

    final direct = _rowFromMap(map, playlistName);
    if (direct != null) {
      rows.add(direct);
    }

    for (final key in const ['tracks', 'items', 'playlists']) {
      final value = map[key];
      if (value is List) {
        for (final item in value) {
          rows.addAll(_readJson(item, playlist: playlistName));
        }
      }
    }

    final nestedTrack = map['track'];
    if (nestedTrack is Map) {
      rows.addAll(_readJson(nestedTrack, playlist: playlistName));
    }
    return rows;
  }

  _ImportedRow? _rowFromMap(Map<String, Object?> map, String playlist) {
    final track = _firstText(map, const [
      'trackName',
      'track',
      'song',
      'name',
      'master_metadata_track_name',
    ]);
    final artist = _firstText(map, const [
      'artistName',
      'artist',
      'artists',
      'albumArtistName',
      'master_metadata_album_artist_name',
    ]);
    if (track.isEmpty && artist.isEmpty) {
      return null;
    }
    return _ImportedRow(track: track, artist: artist, playlist: playlist);
  }

  bool _hasPlaylistItems(Map<String, Object?> map) {
    return map['items'] is List || map['tracks'] is List;
  }

  List<_ImportedRow> _readCsvLike(String text) {
    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) {
      return const [];
    }
    final header = _splitLine(lines.first).map((item) => item.toLowerCase()).toList();
    final hasHeader = header.any((item) => item.contains('track') || item.contains('artist'));
    final rows = <_ImportedRow>[];
    for (final line in hasHeader ? lines.skip(1) : lines) {
      final columns = _splitLine(line);
      if (columns.isEmpty) {
        continue;
      }
      if (hasHeader) {
        rows.add(
          _ImportedRow(
            track: _column(columns, header, const ['track', 'song', 'title', 'name']),
            artist: _column(columns, header, const ['artist', 'album artist']),
            playlist: _column(columns, header, const ['playlist']),
          ),
        );
      } else {
        rows.add(
          _ImportedRow(
            track: columns.first,
            artist: columns.length > 1 ? columns[1] : '',
            playlist: columns.length > 2 ? columns[2] : '',
          ),
        );
      }
    }
    return rows;
  }

  List<String> _splitLine(String line) {
    return line.split(RegExp(r',|\t|;')).map((item) {
      return item.trim().replaceAll(RegExp(r'^"|"$'), '');
    }).where((item) => item.isNotEmpty).toList();
  }

  String _column(List<String> columns, List<String> header, List<String> names) {
    for (final name in names) {
      final index = header.indexWhere((item) => item.contains(name));
      if (index >= 0 && index < columns.length) {
        return columns[index];
      }
    }
    return '';
  }

  String _firstText(Map<String, Object?> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is List) {
        final text = value.map(_string).where((item) => item.isNotEmpty).join(', ');
        if (text.isNotEmpty) {
          return text;
        }
      }
      final text = _string(value);
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }

  List<String> _top(Map<String, int> counts, int limit) {
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).map((entry) => entry.key).toList();
  }

  List<String> _inferGenres(Iterable<String> artists, Iterable<String> tracks) {
    final text = [...artists, ...tracks].join(' ').toLowerCase();
    final genres = <String>[];
    for (final entry in const {
      'jazz': ['jazz', 'blues', 'rag'],
      'classical': ['rhapsody', 'overture', 'orchestra', 'piano'],
      'electronic': ['electronic', 'beat', 'pulse', 'synth'],
      'focus': ['focus', 'ambient', 'soft', 'night'],
      'pop': ['pop'],
      'rock': ['rock'],
      'hip hop': ['hip hop', 'rap'],
    }.entries) {
      if (entry.value.any(text.contains)) {
        genres.add(entry.key);
      }
    }
    return genres.isEmpty ? const ['imported taste'] : genres;
  }

  String _string(Object? value) {
    return value?.toString().trim() ?? '';
  }
}

class _ImportedRow {
  const _ImportedRow({
    required this.track,
    required this.artist,
    required this.playlist,
  });

  final String track;
  final String artist;
  final String playlist;
}

class SpotifyImportException implements Exception {
  const SpotifyImportException(this.message);

  final String message;
}
