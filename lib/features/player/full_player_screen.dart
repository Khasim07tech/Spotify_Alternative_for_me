import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../models/track.dart';
import '../../providers/lyrics_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/gradient_artwork.dart';

class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(playerServiceProvider);
    final track = ref.watch(currentTrackProvider).value ?? service.queue.first;
    final playerState = ref.watch(playerStateProvider).value;
    final position = ref.watch(playbackPositionProvider).value ?? Duration.zero;
    final duration = ref.watch(playbackDurationProvider).value ?? track.duration;
    final shuffleEnabled = ref.watch(shuffleEnabledProvider).value ?? false;
    final repeatMode = ref.watch(repeatModeProvider).value ?? LoopMode.off;
    final lyrics = ref.watch(currentLyricsProvider);
    final isPlaying = playerState?.playing ?? false;
    final isBusy = playerState?.processingState == ProcessingState.loading ||
        playerState?.processingState == ProcessingState.buffering;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final content = [
              _ArtworkPanel(track: track),
              _ControlsPanel(
                track: track,
                position: position,
                duration: duration,
                isPlaying: isPlaying,
                isBusy: isBusy,
                shuffleEnabled: shuffleEnabled,
                repeatMode: repeatMode,
                lyrics: lyrics,
                onSeek: (position) {
                  service.seek(position);
                },
                onPrevious: () {
                  service.previous();
                },
                onTogglePlay: () {
                  service.togglePlayPause();
                },
                onNext: () {
                  service.next();
                },
                onShuffle: () {
                  service.toggleShuffle();
                },
                onRepeat: () {
                  service.cycleRepeatMode();
                },
              ),
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: content.first),
                        const SizedBox(width: 40),
                        Expanded(child: content.last),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        content.first,
                        const SizedBox(height: 30),
                        content.last,
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ArtworkPanel extends StatelessWidget {
  const _ArtworkPanel({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'artwork-${track.id}',
      child: AspectRatio(
        aspectRatio: 1,
        child: GradientArtwork(
          color: Color(track.colorValue),
          icon: Icons.album_rounded,
        ),
      ),
    );
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.track,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isBusy,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.lyrics,
    required this.onSeek,
    required this.onPrevious,
    required this.onTogglePlay,
    required this.onNext,
    required this.onShuffle,
    required this.onRepeat,
  });

  final Track track;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBusy;
  final bool shuffleEnabled;
  final LoopMode repeatMode;
  final List<String> lyrics;
  final ValueChanged<Duration> onSeek;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlay;
  final VoidCallback onNext;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxMs = duration.inMilliseconds <= 0 ? 1.0 : duration.inMilliseconds.toDouble();
    final currentMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          track.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          track.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          '${track.sourceName} - ${track.license}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.primary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Slider(
          value: currentMs,
          max: maxMs,
          onChanged: (value) {
            onSeek(Duration(milliseconds: value.round()));
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_format(position), style: Theme.of(context).textTheme.labelMedium),
            Text(_format(duration), style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              tooltip: shuffleEnabled ? 'Shuffle on' : 'Shuffle off',
              color: shuffleEnabled ? scheme.primary : scheme.onSurfaceVariant,
              onPressed: onShuffle,
              icon: const Icon(Icons.shuffle_rounded),
            ),
            IconButton(
              tooltip: 'Previous',
              iconSize: 34,
              onPressed: onPrevious,
              icon: const Icon(Icons.skip_previous_rounded),
            ),
            FilledButton(
              onPressed: onTogglePlay,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                fixedSize: const Size.square(72),
              ),
              child: isBusy
                  ? const SizedBox.square(
                      dimension: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 38,
                    ),
            ),
            IconButton(
              tooltip: 'Next',
              iconSize: 34,
              onPressed: onNext,
              icon: const Icon(Icons.skip_next_rounded),
            ),
            IconButton(
              tooltip: 'Repeat',
              color: repeatMode == LoopMode.off ? scheme.onSurfaceVariant : scheme.primary,
              onPressed: onRepeat,
              icon: Icon(
                repeatMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: false,
          title: const Text('Lyrics'),
          subtitle: const Text('Open-source notes when lyrics are unavailable'),
          children: [
            for (final line in lyrics)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  line,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
