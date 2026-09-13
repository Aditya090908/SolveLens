import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:solvelens/app_theme.dart';
import 'package:solvelens/home_screen.dart';
import 'package:solvelens/main.dart';

void main() {
  testWidgets('shows branding and settings button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SolveLensApp());
    await tester.pumpAndSettle();

    expect(find.text('SolveLens'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('shows headline, supporting text, and input controls', (
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
}
