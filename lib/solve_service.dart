/// Phase 3 AI solve service boundary (Flutter side).
///
/// Implementations call the server proxy or a fake for tests. No provider API
/// keys in the client.
enum SolveErrorKind {
  network,
  timeout,
  invalidResponse,
  serverError,
  clientError,
}

class SolveFailure {
  const SolveFailure({required this.kind, required this.userMessage});

  final SolveErrorKind kind;
  final String userMessage;
}

class SolveSuccess {
  const SolveSuccess(this.answer);

  final String answer;
}

sealed class SolveOutcome {
  const SolveOutcome();
}

class SolveOk extends SolveOutcome {
  const SolveOk(this.success);

  final SolveSuccess success;
}

class SolveErr extends SolveOutcome {
  const SolveErr(this.failure);

  final SolveFailure failure;
}

abstract class SolveService {
  Future<SolveOutcome> solve(String question);
}
