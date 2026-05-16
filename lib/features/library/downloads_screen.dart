import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/download_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/async_state_widgets.dart';
import '../../widgets/track_tile.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloads = ref.watch(downloadedTracksProvider);
    final player = ref.watch(playerServiceProvider);
    final error = ref.watch(downloadControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Downloaded Songs')),
      body: SafeArea(
        child: AdaptivePage(
          child: ListView(
            children: [
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              downloads.when(
                data: (tracks) {
                  if (tracks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 28),
                      child: Text(
                        'No offline songs yet. Download legal tracks from Home or Search.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final track in tracks)
                        TrackTile(
                          track: track,
                          showDownload: false,
                          onTap: () => player.playTrack(track),
                        ),
                    ],
                  );
                },
                loading: () => const InlineLoader(label: 'Loading downloads'),
                error: (error, stackTrace) => InlineError(
                  message: 'Could not load downloads.',
                  onRetry: () => ref.invalidate(downloadedTracksProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
