import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/async_state_widgets.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class ArtistScreen extends ConsumerWidget {
  const ArtistScreen({super.key, required this.artist});

  final String artist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(streamingSearchProvider(artist));
    final player = ref.watch(playerServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Artist')),
      body: SafeArea(
        child: AdaptivePage(
          child: ListView(
            children: [
              Text(artist, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Open catalog matches from Audius and Jamendo.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'Songs'),
              tracks.when(
                data: (items) => Column(
                  children: [
                    for (final track in items)
                      TrackTile(
                        track: track,
                        onTap: () => player.playTrack(track),
                      ),
                  ],
                ),
                loading: () => const InlineLoader(label: 'Loading artist songs'),
                error: (error, stackTrace) => InlineError(
                  message: 'Could not load artist songs.',
                  onRetry: () => ref.invalidate(streamingSearchProvider(artist)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
