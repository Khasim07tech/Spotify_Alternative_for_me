class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.collection,
    required this.duration,
    required this.colorValue,
    required this.streamUrl,
    required this.sourceName,
    required this.license,
  });

  final String id;
  final String title;
  final String artist;
  final String collection;
  final Duration duration;
  final int colorValue;
  final String streamUrl;
  final String sourceName;
  final String license;
}
