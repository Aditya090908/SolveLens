import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_screen.dart';

void main() {
  runApp(const SolveLensApp());
}

/// Root widget for SolveLens Phase 1.
///
/// Visual home-screen foundation with system-selected light/dark themes.
/// No AI, navigation, or backend behavior.
class SolveLensApp extends StatelessWidget {
  const SolveLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolveLens',
      theme: SolveLensTheme.light(),
      darkTheme: SolveLensTheme.dark(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
