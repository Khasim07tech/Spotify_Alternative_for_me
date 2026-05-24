import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/lyrics_service.dart';
import 'player_providers.dart';

final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return const LyricsService();
});

final currentLyricsProvider = Provider<List<String>>((ref) {
  final service = ref.watch(lyricsServiceProvider);
  final track = ref.watch(currentTrackProvider).value ?? ref.watch(playerServiceProvider).queue.first;
  return service.linesFor(track);
});
