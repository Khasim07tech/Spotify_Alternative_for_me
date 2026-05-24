import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/recommendation_pack.dart';
import '../services/recommendation_service.dart';
import 'catalog_providers.dart';
import 'spotify_providers.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return const RecommendationService();
});

final recommendationPackProvider = FutureProvider<RecommendationPack>((ref) async {
  final trending = await ref.watch(trendingTracksProvider.future);
  final catalog = ref.watch(catalogServiceProvider);
  final spotify = await ref.watch(spotifyServiceProvider).cachedProfile();
  return ref.watch(recommendationServiceProvider).generate(
        candidates: [
          ...trending,
          ...catalog.recentTracks(),
        ],
        spotifyProfile: spotify,
        recentlyPlayed: catalog.recentTracks(),
      );
});
