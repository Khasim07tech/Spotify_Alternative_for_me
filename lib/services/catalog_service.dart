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
          title: 'Ole Miss Rag',
          artist: 'W. C. Handy',
          collection: 'Sunrise Signal',
          duration: Duration(seconds: 12),
          colorValue: 0xFF1ED760,
          streamUrl: 'asset:///assets/audio/kx_neon_rag.wav',
          sourceName: 'KX bundled audio',
          license: 'Original generated demo loop',
        ),
        Track(
          id: 'paper-lights',
          title: 'William Tell Overture',
          artist: "Sodero's Band",
          collection: 'City Pulse',
          duration: Duration(seconds: 12),
          colorValue: 0xFF22D3EE,
          streamUrl: 'asset:///assets/audio/kx_city_pulse.wav',
          sourceName: 'KX bundled audio',
          license: 'Original generated demo loop',
        ),
        Track(
          id: 'quiet-magnet',
          title: 'Dippermouth Blues',
          artist: "King Oliver's Jazz Band",
          collection: 'Midnight Focus',
          duration: Duration(seconds: 12),
          colorValue: 0xFFA78BFA,
          streamUrl: 'asset:///assets/audio/kx_midnight_blues.wav',
          sourceName: 'KX bundled audio',
          license: 'Original generated demo loop',
        ),
        Track(
          id: 'gold-room',
          title: 'Rhapsody in Blue',
          artist: 'George Gershwin',
          collection: 'Soft Static',
          duration: Duration(seconds: 12),
          colorValue: 0xFFF97316,
          streamUrl: 'asset:///assets/audio/kx_blue_rhapsody.wav',
          sourceName: 'KX bundled audio',
          license: 'Original generated demo loop',
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
