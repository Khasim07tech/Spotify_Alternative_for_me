import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static bool get isConfigured {
    return DefaultFirebaseOptions.android.apiKey !=
        'replace-with-firebase-android-api-key';
  }

  static bool get isInitialized => Firebase.apps.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      if (kDebugMode) {
        debugPrint('Firebase skipped: using local demo auth.');
      }
      return;
    }
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: ${error.message}');
      }
      rethrow;
    }
  }
}
