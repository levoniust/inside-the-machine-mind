import 'package:flutter/material.dart';

/// Color tokens for the "circuit board" look. Read them with `AppColors.of(context)`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.surfaceHi,
    required this.line,
    required this.text,
    required this.textDim,
    required this.cyan,
    required this.magenta,
    required this.violet,
    required this.lime,
    required this.amber,
    required this.red,
    required this.isDark,
  });

  final Color bg;
  final Color surface;
  final Color surfaceHi;
  final Color line;
  final Color text;
  final Color textDim;
  final Color cyan;
  final Color magenta;
  final Color violet;
  final Color lime;
  final Color amber;
  final Color red;
  final bool isDark;

  static const dark = AppColors(
    bg: Color(0xFF070B12),
    surface: Color(0xFF0E1520),
    surfaceHi: Color(0xFF152131),
    line: Color(0xFF22324A),
    text: Color(0xFFE8F1FF),
    textDim: Color(0xFF8DA2BF),
    cyan: Color(0xFF22E4FF),
    magenta: Color(0xFFFF3DCB),
    violet: Color(0xFF8B6CFF),
    lime: Color(0xFF9BFF5A),
    amber: Color(0xFFFFB547),
    red: Color(0xFFFF5A6A),
    isDark: true,
  );

  static const light = AppColors(
    bg: Color(0xFFF6F8FB),
    surface: Color(0xFFFFFFFF),
    surfaceHi: Color(0xFFEEF2F7),
    line: Color(0xFFD5DEE9),
    text: Color(0xFF0C1626),
    textDim: Color(0xFF4D5E75),
    cyan: Color(0xFF0098B8),
    magenta: Color(0xFFC2189A),
    violet: Color(0xFF5B3FD6),
    lime: Color(0xFF3D9A12),
    amber: Color(0xFFB86E00),
    red: Color(0xFFC62838),
    isDark: false,
  );

  static AppColors of(BuildContext context) => Theme.of(context).extension<AppColors>() ?? dark;

  /// Accent color for a track number (1 hardware, 2 training, 3 inference; 4-5 Everyday; 6-10 Lab; 0 extras).
  Color section(int n) => switch (n) {
    1 || 4 || 10 => cyan,
    2 || 7 => violet,
    3 || 9 => magenta,
    6 => lime,
    _ => amber,
  };

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surfaceHi: l(surfaceHi, other.surfaceHi),
      line: l(line, other.line),
      text: l(text, other.text),
      textDim: l(textDim, other.textDim),
      cyan: l(cyan, other.cyan),
      magenta: l(magenta, other.magenta),
      violet: l(violet, other.violet),
      lime: l(lime, other.lime),
      amber: l(amber, other.amber),
      red: l(red, other.red),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Spacing scale (4-pt grid).
class Gap {
  static const double xs = 4, s = 8, m = 12, l = 16, xl = 24, xxl = 32, huge = 48;
}

/// Shared text styles that aren't covered by the Material text theme.
class AppText {
  static const mono = TextStyle(fontFamily: 'monospace', fontFeatures: [FontFeature.tabularFigures()]);
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: c.cyan,
      brightness: brightness,
      surface: c.surface,
      primary: c.cyan,
      secondary: c.magenta,
      tertiary: c.violet,
      error: c.red,
    ),
    scaffoldBackgroundColor: c.bg,
    extensions: [c],
  );
  final t = base.textTheme.apply(bodyColor: c.text, displayColor: c.text);
  return base.copyWith(
    textTheme: t.copyWith(
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, height: 1.45),
    ),
    appBarTheme: AppBarTheme(backgroundColor: c.bg, foregroundColor: c.text, elevation: 0, scrolledUnderElevation: 0),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.cyan,
      inactiveTrackColor: c.surfaceHi,
      thumbColor: c.cyan,
      overlayColor: c.cyan.withValues(alpha: 0.15),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: c.text,
        side: BorderSide(color: c.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    dividerColor: c.line,
  );
}
