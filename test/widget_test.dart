import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solvelens/app_theme.dart';
import 'package:solvelens/home_screen.dart';
import 'package:solvelens/main.dart';

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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    expect(find.text('SolveLens'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('shows headline, supporting text, and input controls when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SolveLensApp());
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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '2x + 3 = 7');
    await tester.pump();

    expect(find.text('2x + 3 = 7'), findsOneWidget);
  });

  testWidgets('text input uses send action and multiline config', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    final TextField field = tester.widget(find.byType(TextField));
    expect(field.textInputAction, TextInputAction.send);
    expect(field.maxLines, 4);
    expect(field.minLines, 1);
  });

  testWidgets('submitting adds user message, analyzing, then demo result',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');

    // User message appears immediately alongside the analyzing state.
    expect(find.text('2x + 3 = 7'), findsOneWidget);
    expect(find.text('Analyzing...'), findsOneWidget);

    // Input clears right after successful submission.
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty);

    // Deterministic local demo answer replaces the analyzing state.
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Analyzing...'), findsNothing);
    expect(find.text('x = 2'), findsOneWidget);
    expect(find.text('Demo · local result'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('input clears after submission', (WidgetTester tester) async {
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    expect(tester.widget<TextField>(find.byType(TextField)).controller?.text,
        isEmpty);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('empty and whitespace input creates no message but clears',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SolveLensApp());
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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    // Second analyzing state appears while the first answer stays visible.
    expect(find.text('Analyzing...'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('x = 2'), findsOneWidget);

    await _submitWithKeyboardAction(tester, 'what is pi?');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Demo mode: I received your question. '
        'Real AI solving will be connected in a later phase.',
      ),
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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();
    expect(find.text('What can I solve for you today?'), findsOneWidget);

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pump(const Duration(milliseconds: 800));
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
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'x^2 + 5');
    await tester.pump();

    expect(find.text('x^2 + 5'), findsOneWidget);
  });

  testWidgets('dark theme conversation shows demo answer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SolveLensTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('x = 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plus, microphone, and settings buttons are no-op taps', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SolveLensApp());
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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pump(const Duration(milliseconds: 800));
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
    await tester.pumpWidget(const SolveLensApp());
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
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        theme: SolveLensTheme.dark(),
        themeMode: ThemeMode.dark,
        home: const HomeScreen(),
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

    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    await _submitWithKeyboardAction(tester, '2x + 3 = 7');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    await _submitWithKeyboardAction(tester, '2 + 2');
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('x = 2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
