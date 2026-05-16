import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/search_input.dart';
import '../../widgets/section_header.dart';
import '../../widgets/track_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(searchViewModelProvider);
    final playerService = ref.watch(playerServiceProvider);
    final normalizedQuery = _query.trim().toLowerCase();
    final results = normalizedQuery.isEmpty
        ? viewModel.searchableTracks
        : viewModel.searchableTracks.where((track) {
            return track.title.toLowerCase().contains(normalizedQuery) ||
                track.artist.toLowerCase().contains(normalizedQuery) ||
                track.collection.toLowerCase().contains(normalizedQuery);
          }).toList();

    return AdaptivePage(
      child: ListView(
        children: [
          Text(
            'Search',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 18),
          SearchInput(
            controller: _controller,
            onChanged: (value) {
              setState(() => _query = value);
            },
          ),
          const SizedBox(height: 26),
          const SectionHeader(title: 'Browse moods'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final mood in viewModel.moods)
                _MoodChip(label: mood, onPressed: () => _applyMood(mood)),
            ],
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: normalizedQuery.isEmpty ? 'Open picks' : 'Results',
          ),
          for (final track in results)
            TrackTile(
              track: track,
              onTap: () {
                playerService.playTrack(track);
              },
            ),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'No matches in this foundation catalog.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  void _applyMood(String mood) {
    _controller.text = mood;
    setState(() => _query = mood);
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
      avatar: const Icon(Icons.auto_awesome_rounded, size: 18),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
