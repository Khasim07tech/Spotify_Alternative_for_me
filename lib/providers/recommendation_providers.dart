import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recommendation_pack.dart';
import '../services/recommendation_cache_service.dart';
import '../services/recommendation_service.dart';
import 'catalog_providers.dart';
import 'spotify_providers.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return const RecommendationService();
});

final recommendationCacheServiceProvider = Provider<RecommendationCacheService>((ref) {
  return const RecommendationCacheService();
});

final recommendationRefreshTickProvider =
    NotifierProvider<RecommendationRefreshTickNotifier, int>(
  RecommendationRefreshTickNotifier.new,
);

class RecommendationRefreshTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }
}

final recommendationPackProvider = FutureProvider<RecommendationPack>((ref) async {
  final refreshTick = ref.watch(recommendationRefreshTickProvider);
  final cache = ref.watch(recommendationCacheServiceProvider);
  final cached = await cache.cachedPack();
  if (cached != null && !cached.isRefreshDue && refreshTick == 0) {
    return cached;
  }
  final trending = await ref.watch(trendingTracksProvider.future);
  final catalog = ref.watch(catalogServiceProvider);
  final spotify = await ref.watch(spotifyServiceProvider).cachedProfile();
  final generated = ref.watch(recommendationServiceProvider).generate(
        candidates: [
          ...trending,
          ...catalog.recentTracks(),
        ],
        spotifyProfile: spotify,
        recentlyPlayed: catalog.recentTracks(),
        previousRefreshes: cached?.refreshHistory ?? const [],
      );
  await cache.savePack(generated);
  return generated;
});

final recommendationScheduleProvider = FutureProvider<RecommendationPack?>((ref) {
  ref.watch(recommendationRefreshTickProvider);
  return ref.watch(recommendationCacheServiceProvider).cachedPack();
});

final recommendationUpdateControllerProvider =
    NotifierProvider<RecommendationUpdateController, String?>(
  RecommendationUpdateController.new,
);

class RecommendationUpdateController extends Notifier<String?> {
  @override
  String? build() => null;

  void refreshNow() {
    state = 'Refreshing weekly KX recommendations.';
    ref.read(recommendationRefreshTickProvider.notifier).increment();
    ref.invalidate(recommendationPackProvider);
    ref.invalidate(recommendationScheduleProvider);
  }

  Future<void> clearCache() async {
    await ref.read(recommendationCacheServiceProvider).clear();
    state = 'Recommendation cache cleared.';
    ref.invalidate(recommendationPackProvider);
    ref.invalidate(recommendationScheduleProvider);
  }
}
