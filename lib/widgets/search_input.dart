import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onVoiceSearch,
    this.isListening = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onVoiceSearch;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search songs, artists, playlists',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onVoiceSearch != null)
              IconButton(
                tooltip: isListening ? 'Listening' : 'Voice search',
                onPressed: onVoiceSearch,
                icon: Icon(
                  isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                ),
              ),
            if (controller.text.isNotEmpty)
              IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close),
                ),
          ],
        ),
      ),
    );
  }
}
