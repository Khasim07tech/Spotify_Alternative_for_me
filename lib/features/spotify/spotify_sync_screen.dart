import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/spotify_providers.dart';
import '../../widgets/adaptive_page.dart';
import '../../widgets/gradient_artwork.dart';
import '../../widgets/section_header.dart';

class SpotifySyncScreen extends ConsumerStatefulWidget {
  const SpotifySyncScreen({super.key});

  @override
  ConsumerState<SpotifySyncScreen> createState() => _SpotifySyncScreenState();
}

class _SpotifySyncScreenState extends ConsumerState<SpotifySyncScreen> {
  final _codeController = TextEditingController();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForSpotifyCallback();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _listenForSpotifyCallback() async {
    final appLinks = AppLinks();
    final initialLink = await appLinks.getInitialLink();
    if (mounted && initialLink != null) {
      _handleSpotifyCallback(initialLink);
    }
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      if (mounted) {
        _handleSpotifyCallback(uri);
      }
    });
  }

  void _handleSpotifyCallback(Uri uri) {
    final isLegacyAppLink = uri.scheme == 'kxwave' && uri.host == 'spotify-auth';
    final isHttpsRedirect =
        uri.scheme == 'https' && uri.host == 'kxwave.app' && uri.path == '/spotify-auth';
    if (!isLegacyAppLink && !isHttpsRedirect) {
      return;
    }
    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      return;
    }
    _codeController.text = code;
    ref.read(spotifySyncProvider.notifier).completeLogin(code);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spotifySyncProvider);
    final controller = ref.read(spotifySyncProvider.notifier);
    final spotifyConfigured = ref.watch(spotifyServiceProvider).isConfigured;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Spotify Sync')),
      body: AdaptivePage(
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.13),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GradientArtwork(
                    color: scheme.primary,
                    size: 62,
                    icon: Icons.graphic_eq_rounded,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KX Taste Sync',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect Spotify to analyze your music taste for future KX recommendations. Spotify content is never streamed from KX Wave.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (!spotifyConfigured)
              _StatusBanner(
                message:
                    'Demo mode is active. Build with SPOTIFY_CLIENT_ID to connect a real Spotify account.',
                color: scheme.primary.withValues(alpha: 0.14),
                borderColor: scheme.primary,
              ),
            if (state.errorMessage != null)
              _StatusBanner(
                message: state.errorMessage!,
                color: scheme.errorContainer,
                borderColor: scheme.error,
              ),
            if (state.message != null)
              _StatusBanner(
                message: state.message!,
                color: scheme.primary.withValues(alpha: 0.14),
                borderColor: scheme.primary,
              ),
            TextField(
              controller: _codeController,
              enabled: !state.isLoading,
              decoration: const InputDecoration(
                labelText: 'Spotify redirect code',
                prefixIcon: Icon(Icons.key_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: state.isLoading ? null : controller.startLogin,
                  icon: const Icon(Icons.login_rounded),
                  label: Text(spotifyConfigured ? 'Open Spotify Login' : 'Load Demo Taste'),
                ),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => controller.completeLogin(_codeController.text),
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Connect'),
                ),
                OutlinedButton.icon(
                  onPressed: state.isLoading ? null : controller.sync,
                  icon: const Icon(Icons.sync_rounded),
                  label: const Text('Sync Taste'),
                ),
                OutlinedButton.icon(
                  onPressed: state.isLoading ? null : () => _importDataFile(controller),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Import Data File'),
                ),
                IconButton.filledTonal(
                  tooltip: 'Disconnect Spotify',
                  onPressed: state.isLoading ? null : controller.disconnect,
                  icon: const Icon(Icons.link_off_rounded),
                ),
              ],
            ),
            if (state.isLoading) ...[
              const SizedBox(height: 18),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 28),
            if (state.profile == null)
              Text(
                'No Spotify taste profile synced yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              )
            else ...[
              Text(
                'Last synced ${_formatDate(state.profile!.syncedAt)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              _ProfileSection(title: 'Top artists', items: state.profile!.topArtists),
              _ProfileSection(title: 'Genres', items: state.profile!.genres),
              _ProfileSection(title: 'Top tracks', items: state.profile!.topTracks),
              _ProfileSection(title: 'Playlists', items: state.profile!.playlists),
              _ProfileSection(title: 'Recently played', items: state.profile!.recentTracks),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  Future<void> _importDataFile(SpotifySyncNotifier controller) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json', 'csv', 'txt'],
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) {
      return;
    }
    await controller.importFile(File(path));
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.color,
    required this.borderColor,
  });

  final String message;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withValues(alpha: 0.32)),
      ),
      child: Text(message),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: scheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
