/// Phase 3 runtime configuration (non-secret values only).
///
/// API keys must never be passed via `--dart-define` or stored in the app.
class SolveLensConfig {
  const SolveLensConfig._();

  /// Base URL of the SolveLens proxy (no trailing slash), e.g.
  /// `http://10.0.2.2:8080` on Android emulator → host.
  static const String apiBaseUrl = String.fromEnvironment(
    'SOLVELENS_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// When true, [FakeSolveService] is used (tests and optional local UI work).
  static const bool useFakeSolver = bool.fromEnvironment(
    'SOLVELENS_USE_FAKE_SOLVER',
    defaultValue: false,
  );

  static const Duration solveTimeout = Duration(seconds: 30);
}
