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
          duration: Duration(minutes: 2, seconds: 40),
          colorValue: 0xFF1ED760,
          streamUrl:
              'https://archive.org/download/1917-USA-Archives-1917-00-00-WC-Handys-Orch-Ole-Miss-Rag-Fox-Rag/1917%20%28USA%29%20Archives%201917%2000%2000%20W.C.%20Handy%27s%20Orch%20-%20Ole%20Miss%20Rag%20%28Fox%20Rag%29.mp3',
          sourceName: 'Internet Archive',
          license: 'Public domain',
        ),
        Track(
          id: 'paper-lights',
          title: 'William Tell Overture',
          artist: "Sodero's Band",
          collection: 'City Pulse',
          duration: Duration(minutes: 4, seconds: 19),
          colorValue: 0xFF22D3EE,
          streamUrl:
              'https://archive.org/download/78_william-tell-overture-part-2-the-storm_royal-albert-hall-orchestra/D_167_Ho_978ac.mp3',
          sourceName: 'Internet Archive',
          license: 'Public domain',
        ),
        Track(
          id: 'quiet-magnet',
          title: 'Dippermouth Blues',
          artist: "King Oliver's Jazz Band",
          collection: 'Midnight Focus',
          duration: Duration(minutes: 2, seconds: 24),
          colorValue: 0xFFA78BFA,
          streamUrl:
              'https://archive.org/download/78_dipper-mouth-blues_muggsy-spanier-and-his-ragtime-band-oliver-armstrong_gbia0393571b/DIPPER%20MOUTH%20BLUES%20-%20MUGGSY%20SPANIER%20AND%20HIS%20RAGTIME%20BAND.mp3',
          sourceName: 'Internet Archive',
          license: 'Public domain',
        ),
        Track(
          id: 'gold-room',
          title: 'Rhapsody in Blue',
          artist: 'George Gershwin',
          collection: 'Soft Static',
          duration: Duration(minutes: 9, seconds: 26),
          colorValue: 0xFFF97316,
          streamUrl: 'https://archive.org/download/edison-52145_01_18010/cusb_ed_52145_01_18010_0b.mp3',
          sourceName: 'Internet Archive',
          license: 'Public domain',
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
