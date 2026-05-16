import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';

abstract interface class AuthService {
  Stream<AuthUser?> authStateChanges();

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  bool _googleInitialized = false;
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  @override
  Stream<AuthUser?> authStateChanges() {
    return _firebaseAuth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _requireUser(credential.user);
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _requireUser(credential.user);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        serverClientId:
            _googleServerClientId.isEmpty ? null : _googleServerClientId,
      );
      _googleInitialized = true;
    }

    final googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;
    if (googleAuth.idToken == null) {
      throw const AuthException(
        'Google sign-in needs Firebase OAuth configuration before it can continue.',
      );
    }
    final credential = firebase_auth.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _requireUser(userCredential.user);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      if (_googleInitialized) _googleSignIn.signOut(),
    ]);
  }

  AuthUser _requireUser(firebase_auth.User? user) {
    final mapped = _mapFirebaseUser(user);
    if (mapped == null) {
      throw const AuthException('Authentication completed without a user.');
    }
    return mapped;
  }

  AuthUser? _mapFirebaseUser(firebase_auth.User? user) {
    if (user == null) {
      return null;
    }

    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class DemoAuthService implements AuthService {
  const DemoAuthService();

  static const _demoUser = AuthUser(
    uid: 'local-demo-user',
    email: 'demo@kxwave.local',
    displayName: 'KX Listener',
  );

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(_demoUser);

  @override
  Future<AuthUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'local-demo-user', email: email.trim());
  }

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return AuthUser(uid: 'local-demo-user', email: email.trim());
  }

  @override
  Future<AuthUser> signInWithGoogle() async => _demoUser;

  @override
  Future<void> signOut() async {}
}
