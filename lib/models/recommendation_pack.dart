import 'track.dart';

class RecommendationPack {
  const RecommendationPack({
    required this.weeklyTracks,
    required this.moodPlaylists,
    required this.similarArtists,
    required this.generatedAt,
    required this.nextRefreshAt,
    required this.refreshHistory,
    required this.basis,
  });

  final List<Track> weeklyTracks;
  final List<MoodPlaylist> moodPlaylists;
  final List<String> similarArtists;
  final DateTime generatedAt;
  final DateTime nextRefreshAt;
  final List<DateTime> refreshHistory;
  final String basis;

  bool get isRefreshDue => !DateTime.now().isBefore(nextRefreshAt);

  Map<String, Object?> toJson() {
    return {
      'weeklyTracks': weeklyTracks.map((track) => track.toJson()).toList(),
      'moodPlaylists': moodPlaylists.map((playlist) => playlist.toJson()).toList(),
      'similarArtists': similarArtists,
      'generatedAt': generatedAt.toIso8601String(),
      'nextRefreshAt': nextRefreshAt.toIso8601String(),
      'refreshHistory': refreshHistory.map((date) => date.toIso8601String()).toList(),
      'basis': basis,
    };
  }

  factory RecommendationPack.fromJson(Map<String, Object?> json) {
    return RecommendationPack(
      weeklyTracks: _readMaps(json['weeklyTracks']).map(Track.fromJson).toList(),
      moodPlaylists: _readMaps(json['moodPlaylists']).map(MoodPlaylist.fromJson).toList(),
      similarArtists: _readStrings(json['similarArtists']),
      generatedAt: _readDate(json['generatedAt']),
      nextRefreshAt: _readDate(json['nextRefreshAt']),
      refreshHistory: _readStrings(json['refreshHistory'])
          .map((value) => DateTime.tryParse(value))
          .nonNulls
          .toList(),
      basis: json['basis']?.toString() ?? 'Open catalog recommendations',
    );
  }

  static List<Map<String, Object?>> _readMaps(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.whereType<Map>().map((item) {
      return item.map((key, value) => MapEntry(key.toString(), value));
    }).toList();
  }

  static List<String> _readStrings(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.map((item) => item.toString()).toList();
  }

  static DateTime _readDate(Object? value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class MoodPlaylist {
  const MoodPlaylist({
    required this.id,
    required this.title,
    required this.mood,
    required this.tracks,
    required this.colorValue,
  });

  final String id;
  final String title;
  final String mood;
  final List<Track> tracks;
  final int colorValue;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'mood': mood,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'colorValue': colorValue,
    };
  }

  factory MoodPlaylist.fromJson(Map<String, Object?> json) {
    return MoodPlaylist(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'KX Mix',
      mood: json['mood']?.toString() ?? 'Weekly',
      tracks: RecommendationPack._readMaps(json['tracks']).map(Track.fromJson).toList(),
      colorValue: int.tryParse(json['colorValue']?.toString() ?? '') ?? 0xFF00F5FF,
    );
  }
}
