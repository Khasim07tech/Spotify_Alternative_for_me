import 'package:flutter/material.dart';

import '../models/playlist.dart';
import 'gradient_artwork.dart';

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.playlist,
    this.compact = false,
    this.onTap,
  });

  final Playlist playlist;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(playlist.colorValue);
    final width = compact ? 170.0 : 190.0;

    return Semantics(
      button: true,
      label: playlist.title,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.14),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GradientArtwork(color: color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    playlist.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    playlist.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${playlist.trackCount} tracks',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
      ),
    );
  }
}
