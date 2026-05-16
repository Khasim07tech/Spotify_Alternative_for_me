import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/catalog_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/playlist_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(homeViewModelProvider);

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
                        'Good evening',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Notifications',
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fresh playlists for a clean first build.',
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
                const SectionHeader(title: 'Trending now'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 720) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.trending.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.64,
                        ),
                        itemBuilder: (context, index) {
                          return PlaylistCard(
                            playlist: viewModel.trending[index],
                            compact: true,
                          );
                        },
                      );
                    }

                    return SizedBox(
                      height: 292,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: viewModel.trending.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(width: 12);
                        },
                        itemBuilder: (context, index) {
                          return PlaylistCard(
                            playlist: viewModel.trending[index],
                          );
                        },
                      ),
                    );
                  },
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
                const SectionHeader(title: 'Recently played'),
                ...viewModel.recentTracks.map((track) => TrackTile(track: track)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
