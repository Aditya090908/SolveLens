import 'package:material_ui/material_ui.dart';

/// Phase 1 theme configuration for SolveLens.
///
/// Light and dark themes share the same purple/blue/pink brand ramp.
/// The active theme is selected by the Android system theme via
/// `ThemeMode.system` in `main.dart`. No manual switch in Phase 1.
class SolveLensTheme {
  const SolveLensTheme._();

  // Brand ramp: purple / blue / pink.
  static const Color brandPurple = Color(0xFF7C3AED);
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandPink = Color(0xFFEC4899);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandPurple, brandBlue, brandPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brandPurple,
      brightness: Brightness.light,
    );
    const Color primary = Color(0xFF1A1C22);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFAF9FD),
      textTheme: _textTheme(
        primary: primary,
        secondary: const Color(0xFF6B7280),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x4D7C3AED),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fill: Colors.white.withValues(alpha: 0.7),
        hint: const Color(0xFF6B7280),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: brandPurple,
      brightness: Brightness.dark,
    );
    const Color primary = Color(0xFFF3F4F6);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0A0F24),
      textTheme: _textTheme(
        primary: primary,
        secondary: const Color(0xFF9CA3AF),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: Color(0x4D7C3AED),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fill: const Color(0xFF141B33).withValues(alpha: 0.8),
        hint: const Color(0xFF9CA3AF),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }

  static TextTheme _textTheme({
    required Color primary,
    required Color secondary,
  }) {
    final TextTheme base = Typography.material2021().englishLike;
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: primary,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(color: primary, height: 1.5),
      bodyMedium: base.bodyMedium?.copyWith(color: secondary, height: 1.5),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fill,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: brandPurple, width: 1.5),
      ),
    );
  }
}
