import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/recommendation_pack.dart';
import '../../providers/player_providers.dart';
import '../../providers/recommendation_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/async_state_widgets.dart';
import '../../widgets/gradient_artwork.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(recommendationPackProvider);
    return AdaptivePage(
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recommendationPackProvider);
          await ref.read(recommendationPackProvider.future);
        },
        child: ListView(
          children: [
            Text(
              'AI Discovery',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Personalized from your taste profile and legal open music sources.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 22),
            pack.when(
              data: (value) => _RecommendationContent(pack: value),
              error: (error, stackTrace) => InlineError(
                message: 'Recommendations are unavailable right now.',
                onRetry: () => ref.invalidate(recommendationPackProvider),
              ),
              loading: () => const InlineLoader(label: 'Generating recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationContent extends ConsumerWidget {
  const _RecommendationContent({required this.pack});

  final RecommendationPack pack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly KX Mix', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                pack.basis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: pack.weeklyTracks.isEmpty
                    ? null
                    : () {
                        ref.read(playerServiceProvider).playTrack(pack.weeklyTracks.first);
                      },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Play discovery'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Mood playlists'),
        const SizedBox(height: 10),
        SizedBox(
          height: 174,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _MoodCard(playlist: pack.moodPlaylists[index]);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: pack.moodPlaylists.length,
          ),
        ),
        const SizedBox(height: 26),
        const SectionHeader(title: 'Weekly recommendations'),
        ...pack.weeklyTracks.take(8).map(
              (track) => TrackTile(
                track: track,
                onTap: () => ref.read(playerServiceProvider).playTrack(track),
              ),
            ),
        if (pack.similarArtists.isNotEmpty) ...[
          const SizedBox(height: 24),
          const SectionHeader(title: 'Similar artist signals'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: pack.similarArtists
                .map(
                  (artist) => Chip(
                    avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(artist),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _MoodCard extends ConsumerWidget {
  const _MoodCard({required this.playlist});

  final MoodPlaylist playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 178,
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: playlist.tracks.isEmpty
              ? null
              : () => ref.read(playerServiceProvider).playTrack(playlist.tracks.first),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientArtwork(
                  color: Color(playlist.colorValue),
                  size: 64,
                  icon: Icons.auto_awesome_rounded,
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
                  '${playlist.mood} - ${playlist.tracks.length} tracks',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
