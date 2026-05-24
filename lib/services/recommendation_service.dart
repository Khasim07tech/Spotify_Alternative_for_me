import '../models/recommendation_pack.dart';
import '../models/spotify_profile.dart';
import '../models/track.dart';

class RecommendationService {
  const RecommendationService();

  RecommendationPack generate({
    required List<Track> candidates,
    required SpotifyProfile? spotifyProfile,
    required List<Track> recentlyPlayed,
  }) {
    final scored = candidates
        .map(
          (track) => _ScoredTrack(
            track: track,
            score: _scoreTrack(
              track: track,
              spotifyProfile: spotifyProfile,
              recentlyPlayed: recentlyPlayed,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    final weeklyTracks = scored.map((item) => item.track).take(20).toList();
    final seedTracks = weeklyTracks.isEmpty ? candidates : weeklyTracks;
    final generatedAt = DateTime.now();

    return RecommendationPack(
      weeklyTracks: weeklyTracks,
      moodPlaylists: [
        _moodPlaylist(
          id: 'kx-focus-${generatedAt.millisecondsSinceEpoch}',
          title: 'KX Focus Signal',
          mood: 'Focus',
          tracks: seedTracks,
          colorValue: 0xFF00F5FF,
          terms: const ['ambient', 'focus', 'classic', 'blue', 'soft'],
        ),
        _moodPlaylist(
          id: 'kx-pulse-${generatedAt.millisecondsSinceEpoch}',
          title: 'KX Pulse Drive',
          mood: 'Energy',
          tracks: seedTracks,
          colorValue: 0xFFFF4FD8,
          terms: const ['pulse', 'city', 'jazz', 'rag', 'overture'],
        ),
        _moodPlaylist(
          id: 'kx-night-${generatedAt.millisecondsSinceEpoch}',
          title: 'KX Night Current',
          mood: 'Late night',
          tracks: seedTracks,
          colorValue: 0xFF8B5CF6,
          terms: const ['midnight', 'night', 'blues', 'quiet', 'static'],
        ),
      ],
      similarArtists: _similarArtists(spotifyProfile, candidates),
      generatedAt: generatedAt,
      basis: spotifyProfile == null
          ? 'Open catalog and in-app listening history'
          : 'Spotify taste profile and open catalog matching',
    );
  }

  int _scoreTrack({
    required Track track,
    required SpotifyProfile? spotifyProfile,
    required List<Track> recentlyPlayed,
  }) {
    var score = 20;
    final text = '${track.title} ${track.artist} ${track.collection}'.toLowerCase();
    if (recentlyPlayed.any((item) => item.artist == track.artist)) {
      score += 22;
    }
    if (recentlyPlayed.any((item) => item.collection == track.collection)) {
      score += 10;
    }
    final profile = spotifyProfile;
    if (profile != null) {
      score += _matches(text, profile.topArtists) * 28;
      score += _matches(text, profile.genres) * 16;
      score += _matches(text, profile.playlists) * 10;
      score += _matches(text, profile.topTracks) * 8;
      score += _matches(text, profile.recentTracks) * 6;
    }
    score += track.duration.inMinutes.clamp(1, 9);
    return score;
  }

  int _matches(String text, List<String> terms) {
    var matches = 0;
    for (final term in terms) {
      final normalized = term.toLowerCase();
      if (normalized.length > 2 && text.contains(normalized)) {
        matches++;
      }
    }
    return matches;
  }

  MoodPlaylist _moodPlaylist({
    required String id,
    required String title,
    required String mood,
    required List<Track> tracks,
    required int colorValue,
    required List<String> terms,
  }) {
    final ranked = List<Track>.of(tracks)
      ..sort((a, b) {
        return _moodScore(b, terms).compareTo(_moodScore(a, terms));
      });
    return MoodPlaylist(
      id: id,
      title: title,
      mood: mood,
      tracks: ranked.take(8).toList(),
      colorValue: colorValue,
    );
  }

  int _moodScore(Track track, List<String> terms) {
    final text = '${track.title} ${track.artist} ${track.collection}'.toLowerCase();
    return terms.where(text.contains).length;
  }

  List<String> _similarArtists(SpotifyProfile? profile, List<Track> candidates) {
    final artists = <String>{};
    if (profile != null) {
      artists.addAll(profile.topArtists.take(8));
    }
    artists.addAll(candidates.map((track) => track.artist));
    return artists.where((artist) => artist.trim().isNotEmpty).take(12).toList();
  }
}

class _ScoredTrack {
  const _ScoredTrack({
    required this.track,
    required this.score,
  });

  final Track track;
  final int score;
}
