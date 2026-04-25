import 'package:flutter/material.dart';

import '../utils/custom_route_transitions.dart';
import 'app_fonts.dart';

class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required FontOption fontOption,
    required double fontScale,
  }) {
    final Color seedColor = brightness == Brightness.dark
        ? const Color(0xFF8B9DFF)
        : const Color(0xFF5468FF);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final ThemeData baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontOption.fontFamily,
    );

    final TextTheme scaledTextTheme = baseTheme.textTheme.copyWith(
      displayLarge: _scale(baseTheme.textTheme.displayLarge, fontScale),
      displayMedium: _scale(baseTheme.textTheme.displayMedium, fontScale),
      displaySmall: _scale(baseTheme.textTheme.displaySmall, fontScale),
      headlineLarge: _scale(baseTheme.textTheme.headlineLarge, fontScale),
      headlineMedium: _scale(baseTheme.textTheme.headlineMedium, fontScale),
      headlineSmall: _scale(baseTheme.textTheme.headlineSmall, fontScale),
      titleLarge: _scale(baseTheme.textTheme.titleLarge, fontScale),
      titleMedium: _scale(baseTheme.textTheme.titleMedium, fontScale),
      titleSmall: _scale(baseTheme.textTheme.titleSmall, fontScale),
      bodyLarge: _scale(baseTheme.textTheme.bodyLarge, fontScale),
      bodyMedium: _scale(baseTheme.textTheme.bodyMedium, fontScale),
      bodySmall: _scale(baseTheme.textTheme.bodySmall, fontScale),
      labelLarge: _scale(baseTheme.textTheme.labelLarge, fontScale),
      labelMedium: _scale(baseTheme.textTheme.labelMedium, fontScale),
      labelSmall: _scale(baseTheme.textTheme.labelSmall, fontScale),
    );

    return baseTheme.copyWith(
      scaffoldBackgroundColor: brightness == Brightness.dark
          ? const Color(0xFF0B1020)
          : const Color(0xFFF7F8FC),
      textTheme: scaledTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: brightness == Brightness.dark ? 0 : 1,
        shadowColor: Colors.black.withOpacity(brightness == Brightness.dark ? 0.0 : 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : colorScheme.outline.withOpacity(0.12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withOpacity(0.04)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: brightness == Brightness.dark
            ? const Color(0xFF121826)
            : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      chipTheme: baseTheme.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.12),
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: OpenClawPageTransitionsBuilder(),
          TargetPlatform.iOS: OpenClawPageTransitionsBuilder(),
          TargetPlatform.linux: OpenClawPageTransitionsBuilder(),
          TargetPlatform.macOS: OpenClawPageTransitionsBuilder(),
          TargetPlatform.windows: OpenClawPageTransitionsBuilder(),
        },
      ),
    );
  }

  static TextStyle? _scale(TextStyle? style, double scale) {
    if (style == null || style.fontSize == null) {
      return style;
    }

    return style.copyWith(fontSize: style.fontSize! * scale);
  }
}
