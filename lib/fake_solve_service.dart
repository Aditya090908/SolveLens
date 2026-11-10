import 'solve_service.dart';

/// Deterministic local solver for widget tests and optional dev (no network).
class FakeSolveService implements SolveService {
  FakeSolveService({
    this.artificialDelay = Duration.zero,
    this.onSolve,
  });

  final Duration artificialDelay;
  final Future<SolveOutcome> Function(String question)? onSolve;

  static String _normalize(String question) =>
      question.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');

  static bool _isCubicSymmetricSystem(String normalized) {
    return normalized.contains('a+b+c=0') &&
        normalized.contains('a²+b²+c²=6') &&
        normalized.contains('a³+b³+c³');
  }

  @override
  Future<SolveOutcome> solve(String question) async {
    if (onSolve != null) {
      return onSolve!(question);
    }
    if (artificialDelay > Duration.zero) {
      await Future<void>.delayed(artificialDelay);
    }
    final String normalized = _normalize(question);

    if (normalized == '2x+3=7') {
      return SolveOk(
        const SolveSuccess(
          r'''$x=2$
- Subtract 3: $2x=4$
- Divide by 2: $x=2$''',
        ),
      );
    }
    if (normalized == 'x²-5x+6=0' || normalized == 'x^2-5x+6=0') {
      return SolveOk(
        const SolveSuccess(
          r'''Factor: $x^2 - 5x + 6 = (x-2)(x-3) = 0$
- **Roots:** $x=2$ or $x=3$''',
        ),
      );
    }
    if (_isCubicSymmetricSystem(normalized)) {
      return SolveOk(
        const SolveSuccess(
          r'**Not uniquely determined:** $a^3+b^3+c^3=3abc$, but $abc$ is not '
          r'fixed by $a+b+c=0$ and $a^2+b^2+c^2=6$ alone.',
        ),
      );
    }
    if (normalized == '2+2') {
      return SolveOk(const SolveSuccess('4'));
    }
    return SolveOk(
      SolveSuccess(
        'Fake AI: I received your question. '
        'Connect the real proxy for live answers.',
      ),
    );
  }
}
