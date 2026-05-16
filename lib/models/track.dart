class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.collection,
    required this.duration,
    required this.colorValue,
  });

  final String id;
  final String title;
  final String artist;
  final String collection;
  final Duration duration;
  final int colorValue;
}
