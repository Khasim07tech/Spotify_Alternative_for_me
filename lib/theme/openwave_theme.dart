import 'package:flutter/material.dart';

class OpenWaveTheme {
  const OpenWaveTheme._();

  static const _green = Color(0xFF1ED760);
  static const _aqua = Color(0xFF22D3EE);
  static const _background = Color(0xFF080A0F);
  static const _surface = Color(0xFF10131A);
  static const _surfaceHigh = Color(0xFF171B24);
  static const _text = Color(0xFFF8FAFC);
  static const _mutedText = Color(0xFFB7C0CC);

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _green,
      secondary: _aqua,
      surface: _surface,
      surfaceContainerHighest: _surfaceHigh,
      onSurface: _text,
      onSurfaceVariant: _mutedText,
      outline: const Color(0xFF334155),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          height: 1.08,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4, letterSpacing: 0),
        bodyMedium: TextStyle(fontSize: 14, height: 1.35, letterSpacing: 0),
        labelLarge: TextStyle(
          fontSize: 14,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ).apply(
        bodyColor: _text,
        displayColor: _text,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: _surface,
        indicatorColor: _green.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? _text : _mutedText,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? _green : _mutedText,
            size: selected ? 25 : 23,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _green, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
