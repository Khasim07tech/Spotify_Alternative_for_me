import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openwave/core/navigation/openwave_app.dart';

void main() {
  testWidgets('OpenWave launches into the foundation shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: OpenWaveApp()));

    expect(find.text('OpenWave'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('Good evening'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });
}
