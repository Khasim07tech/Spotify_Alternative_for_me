import '../models/playlist.dart';
import '../models/track.dart';

abstract interface class CatalogService {
  List<Playlist> trendingPlaylists();

  List<Playlist> libraryPlaylists();

  List<Track> recentTracks();

  List<String> searchMoods();
}

class MockCatalogService implements CatalogService {
  const MockCatalogService();

  @override
  List<Playlist> trendingPlaylists() => const [
        Playlist(
          id: 'sunrise-signal',
          title: 'Sunrise Signal',
          subtitle: 'Warm indie and open-electronic picks',
          trackCount: 34,
          colorValue: 0xFF1ED760,
        ),
        Playlist(
          id: 'midnight-focus',
          title: 'Midnight Focus',
          subtitle: 'Low-light beats for deep work',
          trackCount: 28,
          colorValue: 0xFF22D3EE,
        ),
        Playlist(
          id: 'city-pulse',
          title: 'City Pulse',
          subtitle: 'Fast-moving finds for the commute',
          trackCount: 41,
          colorValue: 0xFFF97316,
        ),
        Playlist(
          id: 'soft-static',
          title: 'Soft Static',
          subtitle: 'Quiet textures and ambient sketches',
          trackCount: 19,
          colorValue: 0xFFA78BFA,
        ),
      ];

  @override
  List<Playlist> libraryPlaylists() => const [
        Playlist(
          id: 'liked-foundations',
          title: 'Liked Foundations',
          subtitle: 'Your saved phase-one picks',
          trackCount: 12,
          colorValue: 0xFFFB7185,
        ),
        Playlist(
          id: 'open-discovery',
          title: 'Open Discovery',
          subtitle: 'Copyright-safe discoveries',
          trackCount: 24,
          colorValue: 0xFF38BDF8,
        ),
        Playlist(
          id: 'weekend-draft',
          title: 'Weekend Draft',
          subtitle: 'A playlist shell for future playback',
          trackCount: 8,
          colorValue: 0xFFFACC15,
        ),
      ];

  @override
  List<Track> recentTracks() => const [
        Track(
          id: 'northline',
          title: 'Northline',
          artist: 'Aster Field',
          collection: 'Sunrise Signal',
          duration: Duration(minutes: 3, seconds: 21),
          colorValue: 0xFF1ED760,
        ),
        Track(
          id: 'paper-lights',
          title: 'Paper Lights',
          artist: 'Hollow Atlas',
          collection: 'City Pulse',
          duration: Duration(minutes: 2, seconds: 48),
          colorValue: 0xFF22D3EE,
        ),
        Track(
          id: 'quiet-magnet',
          title: 'Quiet Magnet',
          artist: 'Noon Archive',
          collection: 'Midnight Focus',
          duration: Duration(minutes: 4, seconds: 7),
          colorValue: 0xFFA78BFA,
        ),
        Track(
          id: 'gold-room',
          title: 'Gold Room',
          artist: 'Signal Bloom',
          collection: 'Soft Static',
          duration: Duration(minutes: 3, seconds: 2),
          colorValue: 0xFFF97316,
        ),
      ];

  @override
  List<String> searchMoods() => const [
        'Indie',
        'Focus',
        'Ambient',
        'Workout',
        'Electronic',
        'Acoustic',
        'Fresh Finds',
        'Late Night',
      ];
}
