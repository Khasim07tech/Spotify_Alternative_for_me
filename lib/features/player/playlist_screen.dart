import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/playlist.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/async_state_widgets.dart';
import '../../widgets/gradient_artwork.dart';
import '../../widgets/track_tile.dart';

class PlaylistScreen extends ConsumerWidget {
  const PlaylistScreen({super.key, required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(trendingTracksProvider);
    final player = ref.watch(playerServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Playlist')),
      body: SafeArea(
        child: AdaptivePage(
          child: ListView(
            children: [
              Row(
                children: [
                  GradientArtwork(color: Color(playlist.colorValue), size: 96),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          playlist.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              tracks.when(
                data: (items) => Column(
                  children: [
                    for (final track in items)
                      TrackTile(track: track, onTap: () => player.playTrack(track)),
                  ],
                ),
                loading: () => const InlineLoader(label: 'Loading playlist'),
                error: (error, stackTrace) => InlineError(
                  message: 'Could not load playlist.',
                  onRetry: () => ref.invalidate(trendingTracksProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
