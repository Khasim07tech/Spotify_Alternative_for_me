import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openwave/core/navigation/openwave_app.dart';
import 'package:openwave/features/library/library_screen.dart';
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

    expect(find.text('KX Wave'), findsWidgets);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('KX Wave'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('bottom navigation and library actions respond', (tester) async {
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

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('AI Discovery'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Browse moods'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'rag');
    await tester.pump();
    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('rag'), findsNothing);

    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pump();
    expect(find.textContaining('KX updates are active'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('Downloaded songs'), findsOneWidget);
  });

  testWidgets('library action tiles open their screens', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(
            _FakeAuthService(
              const AuthUser(uid: 'test-user', email: 'test@openwave.app'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: LibraryScreen()),
        ),
      ),
    );

    await tester.pump();
    final spotifyTile = find.widgetWithText(ListTile, 'Spotify taste sync');
    await tester.ensureVisible(spotifyTile);
    expect(tester.widget<ListTile>(spotifyTile).onTap, isNotNull);

    final downloadsTile = find.widgetWithText(ListTile, 'Downloaded songs');
    await tester.ensureVisible(downloadsTile);
    expect(tester.widget<ListTile>(downloadsTile).onTap, isNotNull);
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
