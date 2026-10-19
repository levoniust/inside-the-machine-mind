import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_intro.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_intro: pressing send sends the question', (tester) async {
    await pumpApp(tester, home: const S3IntroScreen());
    expect(find.text('Why is the sky blue?'), findsWidgets);
    await tapVisible(tester, find.byKey(const ValueKey('intro-send')));
    await pumpFrames(tester, 4);
    expect(find.text('Message sent…'), findsOneWidget);
    expectNoErrors(tester);
  });
}
