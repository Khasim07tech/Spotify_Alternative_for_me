import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/openwave_app.dart';

void main() {
  runApp(const ProviderScope(child: OpenWaveApp()));
}
