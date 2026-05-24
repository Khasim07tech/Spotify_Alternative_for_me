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

  Track copyWith({
    String? id,
    String? title,
    String? artist,
    String? collection,
    Duration? duration,
    int? colorValue,
    String? streamUrl,
    String? sourceName,
    String? license,
  }) {
    return Track(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      collection: collection ?? this.collection,
      duration: duration ?? this.duration,
      colorValue: colorValue ?? this.colorValue,
      streamUrl: streamUrl ?? this.streamUrl,
      sourceName: sourceName ?? this.sourceName,
      license: license ?? this.license,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'collection': collection,
      'durationMs': duration.inMilliseconds,
      'colorValue': colorValue,
      'streamUrl': streamUrl,
      'sourceName': sourceName,
      'license': license,
    };
  }

  factory Track.fromJson(Map<String, Object?> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown track',
      artist: json['artist']?.toString() ?? 'Unknown artist',
      collection: json['collection']?.toString() ?? 'KX Wave',
      duration: Duration(
        milliseconds: int.tryParse(json['durationMs']?.toString() ?? '') ?? 0,
      ),
      colorValue: int.tryParse(json['colorValue']?.toString() ?? '') ?? 0xFF00F5FF,
      streamUrl: json['streamUrl']?.toString() ?? '',
      sourceName: json['sourceName']?.toString() ?? 'Open source',
      license: json['license']?.toString() ?? 'Open music',
    );
  }
}
