import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solvelens/app_theme.dart';
import 'package:solvelens/fake_solve_service.dart';
import 'package:solvelens/home_screen.dart';
import 'package:solvelens/main.dart';
import 'package:solvelens/solve_service.dart';

Widget _testApp({SolveService? solveService}) {
  return SolveLensApp(
    solveService:
        solveService ??
        FakeSolveService(
          artificialDelay: const Duration(milliseconds: 50),
        ),
  );
}

/// Submits [text] through the keyboard send action, mirroring real UX
/// (type, then press Enter/submit) rather than calling state directly.
Future<void> _submitWithKeyboardAction(
  WidgetTester tester,
  String text,
) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pump();
}

void main() {
  testWidgets('shows branding and settings button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('SolveLens'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('shows headline, supporting text, and input controls when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.text('What can I solve for you today?'), findsOneWidget);
    expect(
      find.text('Ask a question, take a photo, or use your voice.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Ask anything...'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.mic_outlined), findsOneWidget);
  });

  testWidgets('text input accepts and displays typed text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2x + 3 = 7');
    await tester.pump();

    expect(find.text('2x + 3 = 7'), findsOneWidget);
  });

  testWidgets('text input uses send action and multiline config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    final TextField field = tester.widget(find.byType(TextField));
    expect(field.textInputAction, TextInputAction.send);
    expect(field.maxLines, 4);
    expect(field.minLines, 1);
  });

  testWidgets('submitting adds user message, analyzing, then AI result',
      (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pump();

    // User message appears immediately alongside the analyzing state.
    expect(find.text('2x + 3 = 7'), findsOneWidget);
    expect(find.text('Analyzing...'), findsOneWidget);

    // Input clears right after successful submission.
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty);

    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(find.text('Analyzing...'), findsNothing);
    expect(find.textContaining('Subtract 3'), findsOneWidget);
    expect(find.text('SolveLens AI'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('input clears after submission', (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty);

    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('ignores additional submit while analyzing', (
    WidgetTester tester,
  ) async {
    final Completer<SolveOutcome> pending = Completer<SolveOutcome>();
    await tester.pumpWidget(
      _testApp(
        solveService: FakeSolveService(
          onSolve: (_) => pending.future,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    expect(find.text('Analyzing...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ignored');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();

    expect(find.text('ignored'), findsNothing);
    expect(find.text('2 + 2'), findsOneWidget);

    pending.complete(const SolveOk(SolveSuccess('4')));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('empty and whitespace input creates no message but clears',
      (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '   ');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty);
    expect(find.text('Analyzing...'), findsNothing);
    expect(find.byType(ListView), findsNothing);
    // Still in the empty state.
    expect(find.text('What can I solve for you today?'), findsOneWidget);

    await _submitWithKeyboardAction(tester, '');
    expect(find.text('Analyzing...'), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('multiple messages can be submitted and scrolled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pump();
    // Second analyzing state appears while the first answer stays visible.
    expect(find.text('Analyzing...'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(find.textContaining('Subtract 3'), findsWidgets);

    await _submitWithKeyboardAction(tester, 'what is pi?');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Fake AI: I received your question.'),
      findsOneWidget,
    );

    // Conversation is scrollable and newest content is reachable.
    expect(find.byType(ListView), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('hero hides once conversation starts', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    expect(find.text('What can I solve for you today?'), findsOneWidget);

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pumpAndSettle();
    expect(find.text('What can I solve for you today?'), findsNothing);
  });

  testWidgets('text input accepts typed text in dark theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SolveLensTheme.dark(),
        themeMode: ThemeMode.dark,
        home: HomeScreen(solveService: FakeSolveService()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'x^2 + 5');
    await tester.pump();

    expect(find.text('x^2 + 5'), findsOneWidget);
  });

  testWidgets('dark theme conversation shows fake AI answer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SolveLensTheme.dark(),
        themeMode: ThemeMode.dark,
        home: HomeScreen(solveService: FakeSolveService()),
      ),
    );
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pumpAndSettle();

    expect(find.textContaining('Subtract 3'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows solve error in assistant bubble', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        solveService: FakeSolveService(
          onSolve: (_) async => SolveErr(
            SolveFailure(
              kind: SolveErrorKind.network,
              userMessage: 'Network failed for test.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, 'hello');
    await tester.pumpAndSettle();

    expect(find.text('Network failed for test.'), findsOneWidget);
    expect(find.text('Analyzing...'), findsNothing);
  });

  testWidgets('plus, microphone, and settings buttons are no-op taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.mic_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('What can I solve for you today?'), findsOneWidget);
  });

  testWidgets('plus, mic, settings stay present and inert after messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.mic_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.mic_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('has no drawer, app bar, or hamburger menu control', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.menu), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(Drawer), findsNothing);
    final Scaffold scaffold = tester.widget(find.byType(Scaffold));
    expect(scaffold.drawer, isNull);
    expect(scaffold.appBar, isNull);
  });

  testWidgets('builds in light and dark themes without overflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: SolveLensTheme.dark(),
        themeMode: ThemeMode.dark,
        home: HomeScreen(solveService: FakeSolveService()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('What can I solve for you today?'), findsOneWidget);
  });

  testWidgets('conversation does not overflow on a small phone screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pumpAndSettle();
    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pumpAndSettle();

    expect(find.textContaining('Subtract 3'), findsWidgets);
    expect(find.text('4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('regression: linear, quadratic, and underdetermined answers',
      (WidgetTester tester) async {
    await tester.pumpWidget(_testApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pumpAndSettle();
    expect(find.textContaining('Subtract 3'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _submitWithKeyboardAction(tester, 'x² - 5x + 6 = 0');
    await tester.pumpAndSettle();
    expect(find.textContaining('Roots:'), findsOneWidget);
    expect(find.textContaining(r'$x=3$'), findsNothing);
    expect(find.textContaining(r'$x=2$'), findsNothing);
    expect(tester.takeException(), isNull);

    await _submitWithKeyboardAction(
      tester,
      'a + b + c = 0; a² + b² + c² = 6. Find a³ + b³ + c³',
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Not uniquely'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
