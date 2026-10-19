import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_answer.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_answer shows the full answer and opens the finale', (tester) async {
    await pumpApp(tester, home: const S3AnswerScreen());
    await pumpFrames(tester);
    expect(find.textContaining('scatter short blue waves', findRichText: true), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('to-finale')));
    await pumpFrames(tester, 20);
    expect(find.byKey(const ValueKey('finale-quote')), findsOneWidget);
    expect(find.text('CERTIFIED CURIOUS HUMAN'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_answer: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S3AnswerScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
