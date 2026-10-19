import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_tiny_model.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_tiny_model: stepping through ends with "blue"', (tester) async {
    await pumpApp(tester, home: const S3TinyModelScreen());
    expect(find.text('1 · Tokens'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tapVisible(tester, find.byTooltip('Next step'));
      await pumpFrames(tester, 8);
    }
    expect(find.text('7 · Probabilities'), findsOneWidget);
    expect(find.text('“why is the sky blue”'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_tiny_model: every step renders at large text in light mode', (tester) async {
    await pumpApp(tester, home: const S3TinyModelScreen(), textScale: 1.3, brightness: Brightness.light);
    for (var i = 0; i < 6; i++) {
      await tapVisible(tester, find.byTooltip('Next step'));
      await pumpFrames(tester, 8);
      expectNoErrors(tester);
    }
  });
}
