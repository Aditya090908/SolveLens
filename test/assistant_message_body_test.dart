import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solvelens/assistant_message_body.dart';

void main() {
  group('AssistantMessageBody widget', () {
    Future<void> pumpBody(
      WidgetTester tester,
      String data, {
      List<String> mustNotAppearAsRawText = const <String>[],
      int? expectedMathCount,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AssistantMessageBody(data: data),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Parser Error'), findsNothing);
      for (final String fragment in mustNotAppearAsRawText) {
        expect(find.textContaining(fragment), findsNothing);
      }
      if (expectedMathCount != null) {
        expect(find.byType(Math), findsNWidgets(expectedMathCount));
      }
    }

    testWidgets('acceptance: two inline roots', (WidgetTester tester) async {
      await pumpBody(
        tester,
        r'$x=2$ or $x=3$',
        mustNotAppearAsRawText: <String>[r'$x=2$', r'$x=3$'],
        expectedMathCount: 2,
      );
    });

    testWidgets('acceptance: bold roots line', (WidgetTester tester) async {
      const String data = r'**Roots:** $x=2$ or $x=3$';
      await pumpBody(
        tester,
        data,
        mustNotAppearAsRawText: <String>[r'$x=2$', r'$x=3$'],
        expectedMathCount: 2,
      );
      expect(find.textContaining('Roots:'), findsOneWidget);
      expect(find.textContaining(' or '), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
    });

    testWidgets('acceptance: bold wrapped math value', (
      WidgetTester tester,
    ) async {
      await pumpBody(
        tester,
        r'The value is **$3$**.',
        mustNotAppearAsRawText: <String>[r'$3$'],
        expectedMathCount: 1,
      );
    });

    testWidgets('acceptance: spaced implies between math', (
      WidgetTester tester,
    ) async {
      await pumpBody(
        tester,
        r'$a=1$ implies $b=2$',
        expectedMathCount: 2,
      );
      expect(find.textContaining(r'$'), findsNothing);
    });

    testWidgets('acceptance: display math blocks', (WidgetTester tester) async {
      await pumpBody(
        tester,
        r'''
Before
$$
x+1
$$
After''',
        expectedMathCount: 1,
      );
      await pumpBody(
        tester,
        r'\[y=2\]',
        expectedMathCount: 1,
      );
    });

    testWidgets('malformed math shows plain text not parser error', (
      WidgetTester tester,
    ) async {
      await pumpBody(tester, r'broken $x^2 tail');
      expect(find.textContaining('Parser Error'), findsNothing);
    });

    testWidgets('fake quadratic answer shape', (WidgetTester tester) async {
      final String data =
          '${r'Factor: $x^2 - 5x + 6 = (x-2)(x-3) = 0$'}\n${r'- **Roots:** $x=2$ or $x=3$'}';
      await pumpBody(
        tester,
        data,
        mustNotAppearAsRawText: <String>[r'$x=2$', r'$x=3$'],
      );
      expect(find.byType(Math), findsNWidgets(3));
    });

    testWidgets('pixel cubic parser regression fixture', (
      WidgetTester tester,
    ) async {
      final String fixture = File(
        'test/fixtures/gemini_cubic_parser_regression.txt',
      ).readAsStringSync();
      for (var i = 0; i < 3; i++) {
        await pumpBody(tester, fixture);
      }
    });

    testWidgets('legacy verbose cubic fixture', (WidgetTester tester) async {
      final String fixture = File(
        'test/fixtures/gemini_cubic_underdetermined_response.txt',
      ).readAsStringSync();
      await pumpBody(tester, fixture);
    });

    testWidgets('gemini_cubic_run_4 full fixture', (WidgetTester tester) async {
      final String fixture = File(
        'test/fixtures/gemini_cubic_run_4.txt',
      ).readAsStringSync();
      await pumpBody(
        tester,
        fixture,
        mustNotAppearAsRawText: <String>[r'$3$'],
      );
    });

    testWidgets('markdown bullet with math', (WidgetTester tester) async {
      await pumpBody(
        tester,
        r'- Item: $x^2$',
        expectedMathCount: 1,
      );
    });
  });
}
