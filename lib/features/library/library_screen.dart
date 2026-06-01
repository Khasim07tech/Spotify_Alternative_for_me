import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'downloads_screen.dart';
import '../spotify/spotify_sync_screen.dart';
import '../player/playlist_screen.dart';
import '../../models/playlist.dart';
import '../../providers/auth_providers.dart';
import '../../providers/catalog_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/gradient_artwork.dart';
import '../../widgets/section_header.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

enum _LibraryFilter { playlists, artists, albums }

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  _LibraryFilter _filter = _LibraryFilter.playlists;

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(libraryViewModelProvider);
    final tracks = ref.watch(catalogServiceProvider).recentTracks();

    return AdaptivePage(
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Your Library',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Sign out',
                onPressed: () {
                  ref.read(authServiceProvider).signOut();
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: 'Playlists',
                selected: _filter == _LibraryFilter.playlists,
                onSelected: () => setState(() => _filter = _LibraryFilter.playlists),
              ),
              _FilterChip(
                label: 'Artists',
                selected: _filter == _LibraryFilter.artists,
                onSelected: () => setState(() => _filter = _LibraryFilter.artists),
              ),
              _FilterChip(
                label: 'Albums',
                selected: _filter == _LibraryFilter.albums,
                onSelected: () => setState(() => _filter = _LibraryFilter.albums),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              leading: const Icon(Icons.offline_bolt_rounded),
              title: const Text('Downloaded songs'),
              subtitle: const Text('Play cached legal tracks offline'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const DownloadsScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            child: ListTile(
              leading: const Icon(Icons.graphic_eq_rounded),
              title: const Text('Spotify taste sync'),
              subtitle: const Text('Analyze listening taste for future recommendations'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const SpotifySyncScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (_filter == _LibraryFilter.playlists) ...[
            const SectionHeader(title: 'Saved playlists'),
            ...viewModel.playlists.map((playlist) {
              return _LibraryPlaylistTile(playlist: playlist);
            }),
          ] else if (_filter == _LibraryFilter.artists) ...[
            const SectionHeader(title: 'Artists'),
            ...tracks.map((track) => _LibraryInfoTile(
                  title: track.artist,
                  subtitle: '${track.collection} - ${track.sourceName}',
                  icon: Icons.person_rounded,
                  colorValue: track.colorValue,
                )),
          ] else ...[
            const SectionHeader(title: 'Albums'),
            ...tracks.map((track) => _LibraryInfoTile(
                  title: track.collection,
                  subtitle: '${track.title} - ${track.artist}',
                  icon: Icons.album_rounded,
                  colorValue: track.colorValue,
                )),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onSelected,
    this.selected = false,
  });

  final String label;
  final VoidCallback onSelected;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ActionChip(
      label: Text(label),
      onPressed: onSelected,
      backgroundColor:
          selected ? scheme.primary.withValues(alpha: 0.18) : scheme.surfaceContainerHighest,
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outline.withValues(alpha: 0.12),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      labelStyle: TextStyle(
        color: selected ? scheme.primary : scheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }
}

class _LibraryInfoTile extends StatelessWidget {
  const _LibraryInfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorValue,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          GradientArtwork(color: Color(colorValue), size: 56, icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryPlaylistTile extends StatelessWidget {
  const _LibraryPlaylistTile({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => PlaylistScreen(playlist: playlist),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              GradientArtwork(
                color: Color(playlist.colorValue),
                size: 60,
                icon: Icons.queue_music_rounded,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${playlist.trackCount} tracks - ${playlist.subtitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
