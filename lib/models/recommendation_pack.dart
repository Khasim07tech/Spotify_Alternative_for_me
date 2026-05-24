import 'track.dart';

class RecommendationPack {
  const RecommendationPack({
    required this.weeklyTracks,
    required this.moodPlaylists,
    required this.similarArtists,
    required this.generatedAt,
    required this.basis,
  });

  final List<Track> weeklyTracks;
  final List<MoodPlaylist> moodPlaylists;
  final List<String> similarArtists;
  final DateTime generatedAt;
  final String basis;
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
}
