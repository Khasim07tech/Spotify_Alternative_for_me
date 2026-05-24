import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../services/catalog_service.dart';
import '../services/streaming_service.dart';

final catalogServiceProvider = Provider<CatalogService>(
  (ref) => const MockCatalogService(),
);

final streamingServiceProvider = Provider<StreamingService>(
  (ref) => OpenMusicStreamingService(),
);

final trendingTracksProvider = FutureProvider<List<Track>>((ref) async {
  final service = ref.watch(streamingServiceProvider);
  final tracks = await service.trendingTracks();
  if (tracks.isEmpty) {
    return ref.watch(catalogServiceProvider).recentTracks();
  }
  return tracks;
});

final streamingSearchProvider =
    FutureProvider.family<List<Track>, String>((ref, query) async {
  final service = ref.watch(streamingServiceProvider);
  final tracks = await service.searchTracks(query);
  if (tracks.isEmpty) {
    final fallback = ref.watch(catalogServiceProvider).recentTracks();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return fallback;
    }
    return fallback.where((track) {
      return track.title.toLowerCase().contains(normalized) ||
          track.artist.toLowerCase().contains(normalized) ||
          track.collection.toLowerCase().contains(normalized);
    }).toList();
  }
  return tracks;
});

final featuredStreamingPlaylistsProvider = FutureProvider<List<Playlist>>((ref) async {
  final playlists = await ref.watch(streamingServiceProvider).featuredPlaylists();
  if (playlists.isEmpty) {
    return ref.watch(catalogServiceProvider).trendingPlaylists();
  }
  return playlists;
});

final homeViewModelProvider = Provider<HomeViewModel>((ref) {
  final catalog = ref.watch(catalogServiceProvider);
  return HomeViewModel(
    trending: catalog.trendingPlaylists(),
    recentTracks: catalog.recentTracks(),
  );
});

final searchViewModelProvider = Provider<SearchViewModel>((ref) {
  final catalog = ref.watch(catalogServiceProvider);
  return SearchViewModel(
    moods: catalog.searchMoods(),
    searchableTracks: catalog.recentTracks(),
  );
});

final libraryViewModelProvider = Provider<LibraryViewModel>((ref) {
  final catalog = ref.watch(catalogServiceProvider);
  return LibraryViewModel(playlists: catalog.libraryPlaylists());
});

class HomeViewModel {
  const HomeViewModel({
    required this.trending,
    required this.recentTracks,
  });

  final List<Playlist> trending;
  final List<Track> recentTracks;
}

class SearchViewModel {
  const SearchViewModel({
    required this.moods,
    required this.searchableTracks,
  });

  final List<String> moods;
  final List<Track> searchableTracks;
}

class LibraryViewModel {
  const LibraryViewModel({required this.playlists});

  final List<Playlist> playlists;
}
