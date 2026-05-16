import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/track.dart';
import '../services/download_service.dart';

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final downloadedTracksProvider = FutureProvider<List<Track>>((ref) {
  return ref.watch(downloadServiceProvider).downloadedTracks();
});

final downloadProgressProvider = StreamProvider<Map<String, double>>((ref) {
  return ref.watch(downloadServiceProvider).progressStream;
});

final downloadControllerProvider =
    NotifierProvider<DownloadController, String?>(DownloadController.new);

class DownloadController extends Notifier<String?> {
  @override
  String? build() => null;

  Future<void> download(Track track) async {
    state = null;
    try {
      await ref.read(downloadServiceProvider).download(track);
      ref.invalidate(downloadedTracksProvider);
    } catch (error) {
      state = 'Download failed. Check connection and try again.';
    }
  }

  Future<void> remove(String trackId) async {
    await ref.read(downloadServiceProvider).remove(trackId);
    ref.invalidate(downloadedTracksProvider);
  }
}
