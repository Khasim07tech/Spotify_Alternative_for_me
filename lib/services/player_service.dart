import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/track.dart';

class PlayerService {
  PlayerService({required List<Track> queue}) : _queue = List.of(queue);

  final List<Track> _queue;
  final AudioPlayer _player = AudioPlayer();
  Future<void>? _initialization;

  AudioPlayer get player => _player;

  List<Track> get queue => List.unmodifiable(_queue);

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<bool> get shuffleModeEnabledStream => _player.shuffleModeEnabledStream;

  Stream<LoopMode> get loopModeStream => _player.loopModeStream;

  Stream<Track?> get currentTrackStream {
    return _player.currentIndexStream.map((index) {
      if (index == null || index < 0 || index >= _queue.length) {
        return _queue.isEmpty ? null : _queue.first;
      }
      return _queue[index];
    });
  }

  Future<void> initialize() {
    return _initialization ??= _configurePlayer();
  }

  Future<void> playTrack(Track track) async {
    await initialize();
    var index = _queue.indexWhere((candidate) => candidate.id == track.id);
    if (index == -1) {
      _queue.add(track);
      await _player.addAudioSource(_sourceForTrack(track));
      index = _queue.length - 1;
    }
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  Future<void> togglePlayPause() async {
    await initialize();
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await initialize();
    await _player.seek(position);
  }

  Future<void> next() async {
    await initialize();
    if (_player.hasNext) {
      await _player.seekToNext();
      await _player.play();
    }
  }

  Future<void> previous() async {
    await initialize();
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
      await _player.play();
    }
  }

  Future<void> toggleShuffle() async {
    await initialize();
    final nextValue = !_player.shuffleModeEnabled;
    await _player.setShuffleModeEnabled(nextValue);
  }

  Future<void> cycleRepeatMode() async {
    await initialize();
    final nextMode = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(nextMode);
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _configurePlayer() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    await _player.setAudioSources(
      _queue.map(_sourceForTrack).toList(growable: false),
      initialIndex: 0,
      initialPosition: Duration.zero,
      preload: false,
    );
  }

  AudioSource _sourceForTrack(Track track) {
    final uri = Uri.parse(track.streamUrl);
    return AudioSource.uri(
      uri,
      tag: MediaItem(
        id: track.id,
        album: track.collection,
        title: track.title,
        artist: track.artist,
        duration: track.duration,
        extras: {
          'source': track.sourceName,
          'license': track.license,
        },
      ),
    );
  }
}
