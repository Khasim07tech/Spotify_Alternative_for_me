import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/navigation/openwave_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.openwave.openwave.audio',
    androidNotificationChannelName: 'OpenWave playback',
    androidNotificationChannelDescription: 'Music playback controls',
    androidNotificationOngoing: true,
  );
  await FirebaseBootstrap.initialize();
  runApp(const ProviderScope(child: OpenWaveApp()));
}
