import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../models/track.dart';
import '../services/player_service.dart';
import 'catalog_providers.dart';

final playerServiceProvider = Provider<PlayerService>((ref) {
  final tracks = ref.watch(catalogServiceProvider).recentTracks();
  final service = PlayerService(queue: tracks);
  ref.onDispose(service.dispose);
  return service;
});

final currentTrackProvider = StreamProvider<Track?>((ref) {
  return ref.watch(playerServiceProvider).currentTrackStream;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(playerServiceProvider).playerStateStream;
});

final playbackPositionProvider = StreamProvider<Duration>((ref) {
  return ref.watch(playerServiceProvider).positionStream;
});

final playbackDurationProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(playerServiceProvider).durationStream;
});

final shuffleEnabledProvider = StreamProvider<bool>((ref) {
  return ref.watch(playerServiceProvider).shuffleModeEnabledStream;
});

final repeatModeProvider = StreamProvider<LoopMode>((ref) {
  return ref.watch(playerServiceProvider).loopModeStream;
});

final playbackErrorProvider = StreamProvider<String?>((ref) {
  return ref.watch(playerServiceProvider).errorStream;
});
