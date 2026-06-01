import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/playlist.dart';
import '../../features/player/playlist_screen.dart';
import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/async_state_widgets.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(playerServiceProvider);
    final trendingTracks = ref.watch(trendingTracksProvider);
    final featuredPlaylists = ref.watch(featuredStreamingPlaylistsProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AdaptivePage(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'KX Wave',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Notifications',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('KX updates are active. Weekly mixes refresh in AI.'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Neon open streaming from Audius and Jamendo.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AdaptivePage(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Streaming playlists'),
                featuredPlaylists.when(
                  data: (playlists) => _PlaylistStrip(playlists: playlists),
                  loading: () => const InlineLoader(label: 'Loading playlists'),
                  error: (error, stackTrace) => InlineError(
                    message: 'Could not load playlists.',
                    onRetry: () => ref.invalidate(featuredStreamingPlaylistsProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: AdaptivePage(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Trending songs'),
                trendingTracks.when(
                  data: (tracks) => Column(
                    children: [
                      for (final track in tracks)
                        TrackTile(
                          track: track,
                          onTap: () => playerService.playTrack(track),
                        ),
                    ],
                  ),
                  loading: () => const InlineLoader(label: 'Loading trending songs'),
                  error: (error, stackTrace) => InlineError(
                    message: 'Could not load trending songs.',
                    onRetry: () => ref.invalidate(trendingTracksProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistStrip extends StatelessWidget {
  const _PlaylistStrip({required this.playlists});

  final List<Playlist> playlists;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 292,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: playlists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return PlaylistCard(
            playlist: playlist,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => PlaylistScreen(playlist: playlist),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
