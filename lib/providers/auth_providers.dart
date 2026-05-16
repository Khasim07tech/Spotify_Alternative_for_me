import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/firebase/firebase_bootstrap.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>(
  (ref) {
    if (!FirebaseBootstrap.isConfigured || !FirebaseBootstrap.isInitialized) {
      return const DemoAuthService();
    }
    return FirebaseAuthService();
  },
);

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

final authFormProvider = NotifierProvider<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);

class AuthFormState {
  const AuthFormState({
    this.isRegistering = false,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isRegistering;
  final bool isLoading;
  final String? errorMessage;

  AuthFormState copyWith({
    bool? isRegistering,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthFormState(
      isRegistering: isRegistering ?? this.isRegistering,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void toggleMode() {
    state = state.copyWith(
      isRegistering: !state.isRegistering,
      clearError: true,
    );
  }

  Future<void> submitEmail({
    required String email,
    required String password,
  }) async {
    await _runAuthAction(() {
      final service = ref.read(authServiceProvider);
      if (state.isRegistering) {
        return service.registerWithEmail(email: email, password: password);
      }
      return service.signInWithEmail(email: email, password: password);
    });
  }

  Future<void> submitGoogle() async {
    await _runAuthAction(() {
      return ref.read(authServiceProvider).signInWithGoogle();
    });
  }

  Future<void> _runAuthAction(Future<AuthUser> Function() action) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await action();
      state = state.copyWith(isLoading: false, clearError: true);
    } on firebase_auth.FirebaseAuthException catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyFirebaseMessage(error),
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _friendlyMessage(error),
      );
    }
  }

  String _friendlyFirebaseMessage(firebase_auth.FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account exists for that email.',
      'wrong-password' || 'invalid-credential' => 'Email or password is incorrect.',
      'email-already-in-use' => 'That email is already registered.',
      'weak-password' => 'Use a stronger password.',
      'network-request-failed' => 'Check your internet connection and try again.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    if (text.contains('replace-with-firebase')) {
      return 'Firebase credentials are not configured yet.';
    }
    return 'Authentication failed. Please try again.';
  }
}
