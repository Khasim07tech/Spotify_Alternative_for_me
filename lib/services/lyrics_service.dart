import '../models/track.dart';

class LyricsService {
  const LyricsService();

  List<String> linesFor(Track track) {
    final normalized = track.title.toLowerCase();
    if (normalized.contains('ole miss')) {
      return const [
        'Public-domain ragtime recording',
        'Bright brass phrases over a steady stride',
        'KX Wave displays listening notes when lyrics are unavailable',
      ];
    }
    if (normalized.contains('dipper')) {
      return const [
        'Classic jazz signal from the archive',
        'Horn lines trade sparks across the room',
        'Instrumental track: no official lyrics provided',
      ];
    }
    if (normalized.contains('rhapsody')) {
      return const [
        'Long-form public-domain performance',
        'Piano and ensemble move through blue-lit themes',
        'Instrumental track: no official lyrics provided',
      ];
    }
    return [
      'No official lyrics are available for this legal/open track.',
      'Source: ${track.sourceName}',
      'License: ${track.license}',
    ];
  }
}
