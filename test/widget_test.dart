import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openwave/core/navigation/openwave_app.dart';
import 'package:openwave/models/auth_user.dart';
import 'package:openwave/providers/auth_providers.dart';
import 'package:openwave/services/auth_service.dart';

void main() {
  testWidgets('OpenWave launches authenticated users into the shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(
            _FakeAuthService(
              const AuthUser(uid: 'test-user', email: 'test@openwave.app'),
            ),
          ),
        ],
        child: const OpenWaveApp(),
      ),
    );

    expect(find.text('OpenWave'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('OpenWave shows authentication for signed out users', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_FakeAuthService(null)),
        ],
        child: const OpenWaveApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  const _FakeAuthService(this.user);

  final AuthUser? user;

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(user);

  @override
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'registered-user', email: email);
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'signed-in-user', email: email);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    return const AuthUser(uid: 'google-user', email: 'google@openwave.app');
  }

  @override
  Future<void> signOut() async {}
}
