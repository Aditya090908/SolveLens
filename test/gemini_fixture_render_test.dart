import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solvelens/assistant_message_body.dart';

void main() {
  testWidgets('Gemini cubic fixture files render without parser errors', (
    WidgetTester tester,
  ) async {
    for (var run = 1; run <= 10; run++) {
      final String fixture = File(
        'test/fixtures/gemini_cubic_run_$run.txt',
      ).readAsStringSync();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AssistantMessageBody(data: fixture),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Parser Error'), findsNothing);
    }
  });
}
