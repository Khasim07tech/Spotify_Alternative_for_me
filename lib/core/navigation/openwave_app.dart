import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import '../../theme/openwave_theme.dart';

class OpenWaveApp extends StatelessWidget {
  const OpenWaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KX Wave',
      debugShowCheckedModeBanner: false,
      theme: OpenWaveTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
