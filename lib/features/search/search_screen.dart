import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../providers/catalog_providers.dart';
import '../../providers/player_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/search_input.dart';
import '../../widgets/section_header.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/track_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _speech = SpeechToText();
  String _query = '';
  bool _isListening = false;

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
    final results = ref.watch(streamingSearchProvider(_query));

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
            isListening: _isListening,
            onChanged: (value) {
              setState(() => _query = value);
            },
            onVoiceSearch: _toggleVoiceSearch,
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
          SectionHeader(title: normalizedQuery.isEmpty ? 'Trending' : 'Results'),
          results.when(
            data: (tracks) => Column(
              children: [
                for (final track in tracks)
                  TrackTile(
                    track: track,
                    onTap: () => playerService.playTrack(track),
                  ),
              ],
            ),
            loading: () => const SkeletonList(itemCount: 5),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                'Streaming search is unavailable. Try again.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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

  Future<void> _toggleVoiceSearch() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice search is unavailable on this device.')),
      );
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(partialResults: false),
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) {
          return;
        }
        _controller.text = words;
        setState(() {
          _query = words;
          _isListening = false;
        });
      },
    );
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
