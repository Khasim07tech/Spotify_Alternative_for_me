class SpotifyProfile {
  const SpotifyProfile({
    required this.topTracks,
    required this.topArtists,
    required this.genres,
    required this.playlists,
    required this.recentTracks,
    required this.syncedAt,
  });

  final List<String> topTracks;
  final List<String> topArtists;
  final List<String> genres;
  final List<String> playlists;
  final List<String> recentTracks;
  final DateTime syncedAt;

  Map<String, Object?> toJson() {
    return {
      'topTracks': topTracks,
      'topArtists': topArtists,
      'genres': genres,
      'playlists': playlists,
      'recentTracks': recentTracks,
      'syncedAt': syncedAt.toIso8601String(),
      'source': 'spotify-analytics-only',
    };
  }

  factory SpotifyProfile.fromJson(Map<String, Object?> json) {
    return SpotifyProfile(
      topTracks: _readStringList(json['topTracks']),
      topArtists: _readStringList(json['topArtists']),
      genres: _readStringList(json['genres']),
      playlists: _readStringList(json['playlists']),
      recentTracks: _readStringList(json['recentTracks']),
      syncedAt: DateTime.tryParse(json['syncedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }
}
