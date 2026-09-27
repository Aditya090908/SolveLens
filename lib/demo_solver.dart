/// Phase 2 deterministic local demo responder for SolveLens.
///
/// This is NOT an AI model, API call, backend, or math solver. It recognizes
/// a few explicitly defined demo inputs and returns canned answers so the
/// conversation UI can be exercised end to end.
///
/// Phase 3 will replace [solveDemo] with a real AI service call. Keep this
/// file dependency-free (no Flutter imports) so the swap is a one-line
/// change at the call site.
String solveDemo(String input) {
  final String normalized = input
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '');

  if (normalized == '2x+3=7') {
    return 'x = 2';
  }
  if (normalized == '2+2') {
    return '4';
  }
  return 'Demo mode: I received your question. '
      'Real AI solving will be connected in a later phase.';
}
