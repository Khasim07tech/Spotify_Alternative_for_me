import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/playlist.dart';
import '../models/track.dart';
import '../services/catalog_service.dart';

final catalogServiceProvider = Provider<CatalogService>(
  (ref) => const MockCatalogService(),
);

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
