import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';
import 'config.dart';
import 'fake_solve_service.dart';
import 'home_screen.dart';
import 'remote_solve_service.dart';
import 'solve_service.dart';

SolveService createDefaultSolveService() {
  if (SolveLensConfig.useFakeSolver) {
    return FakeSolveService();
  }
  return RemoteSolveService();
}

void main() {
  runApp(SolveLensApp(solveService: createDefaultSolveService()));
}

/// Root widget for SolveLens.
///
/// System light/dark themes; Phase 3 routes questions through [SolveService]
/// (remote proxy by default, fake when configured for tests).
class SolveLensApp extends StatelessWidget {
  const SolveLensApp({super.key, required this.solveService});

  final SolveService solveService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolveLens',
      theme: SolveLensTheme.light(),
      darkTheme: SolveLensTheme.dark(),
      themeMode: ThemeMode.system,
      home: HomeScreen(solveService: solveService),
    );
  }
}
