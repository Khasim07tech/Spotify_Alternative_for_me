import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/player/artist_screen.dart';
import '../models/track.dart';
import '../providers/download_providers.dart';
import 'gradient_artwork.dart';

class TrackTile extends ConsumerWidget {
  const TrackTile({
    super.key,
    required this.track,
    this.onTap,
    this.showDownload = true,
  });

  final Track track;
  final VoidCallback? onTap;
  final bool showDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(downloadProgressProvider).value ?? const {};
    final downloaded = ref.watch(downloadedTracksProvider).value ?? const [];
    final isDownloaded = downloaded.any((item) => item.id == track.id);
    final activeProgress = progress[track.id];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GradientArtwork(
                color: Color(track.colorValue),
                size: 52,
                icon: Icons.music_note,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${track.artist} - ${track.collection}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(track.duration),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              IconButton(
                tooltip: 'Artist',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ArtistScreen(artist: track.artist),
                    ),
                  );
                },
                icon: const Icon(Icons.person_search_rounded),
              ),
              if (showDownload)
                IconButton(
                  tooltip: isDownloaded ? 'Downloaded' : 'Download',
                  onPressed: activeProgress == null || isDownloaded
                      ? () {
                          if (!isDownloaded) {
                            ref.read(downloadControllerProvider.notifier).download(track);
                          }
                        }
                      : null,
                  icon: activeProgress == null
                      ? Icon(
                          isDownloaded
                              ? Icons.offline_pin_rounded
                              : Icons.download_rounded,
                        )
                      : SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: activeProgress <= 0 ? null : activeProgress,
                          ),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
