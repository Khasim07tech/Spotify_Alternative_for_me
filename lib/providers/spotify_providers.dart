import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/spotify_profile.dart';
import '../services/spotify_service.dart';

final spotifyServiceProvider = Provider<SpotifyService>((ref) {
  return SpotifyService();
});

final spotifySyncProvider = NotifierProvider<SpotifySyncNotifier, SpotifySyncState>(
  SpotifySyncNotifier.new,
);

class SpotifySyncState {
  const SpotifySyncState({
    this.profile,
    this.isLoading = false,
    this.message,
    this.errorMessage,
  });

  final SpotifyProfile? profile;
  final bool isLoading;
  final String? message;
  final String? errorMessage;

  SpotifySyncState copyWith({
    SpotifyProfile? profile,
    bool? isLoading,
    String? message,
    String? errorMessage,
    bool clearMessage = false,
    bool clearError = false,
  }) {
    return SpotifySyncState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : message ?? this.message,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SpotifySyncNotifier extends Notifier<SpotifySyncState> {
  @override
  SpotifySyncState build() {
    _loadCachedProfile();
    return const SpotifySyncState();
  }

  Future<void> startLogin() async {
    await _run(
      () async {
        await ref.read(spotifyServiceProvider).launchAuthorization();
        return state.copyWith(
          message: 'Spotify opened. Paste the code from the redirect URL to finish.',
        );
      },
    );
  }

  Future<void> completeLogin(String code) async {
    final trimmed = code.trim();
    if (trimmed.isEmpty) {
      state = state.copyWith(errorMessage: 'Paste the Spotify redirect code first.');
      return;
    }
    await _run(
      () async {
        await ref.read(spotifyServiceProvider).completeAuthorization(trimmed);
        return state.copyWith(message: 'Spotify connected. You can sync now.');
      },
    );
  }

  Future<void> sync() async {
    await _run(
      () async {
        final profile = await ref.read(spotifyServiceProvider).syncProfile();
        return state.copyWith(
          profile: profile,
          message: 'Spotify taste profile synced.',
        );
      },
    );
  }

  Future<void> disconnect() async {
    await _run(
      () async {
        await ref.read(spotifyServiceProvider).disconnect();
        return const SpotifySyncState(message: 'Spotify disconnected.');
      },
    );
  }

  Future<void> _loadCachedProfile() async {
    final profile = await ref.read(spotifyServiceProvider).cachedProfile();
    if (profile != null) {
      state = state.copyWith(profile: profile);
    }
  }

  Future<void> _run(Future<SpotifySyncState> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true, clearMessage: true);
    try {
      state = (await action()).copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyMessage(error),
      );
    }
  }

  String _friendlyMessage(Object error) {
    if (error is SpotifyException) {
      return error.message;
    }
    return 'Spotify sync failed. Check your connection and setup.';
  }
}
