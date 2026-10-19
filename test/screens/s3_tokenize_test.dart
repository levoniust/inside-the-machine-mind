import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_tokenize.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_tokenize: typing updates the token count', (tester) async {
    await pumpApp(tester, home: const S3TokenizeScreen());
    await scrollTo(tester, find.byKey(const ValueKey('tok-count')));
    expect(find.descendant(of: find.byKey(const ValueKey('tok-count')), matching: find.text('6')), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('tok-input')));
    await tester.enterText(find.byKey(const ValueKey('tok-input')), 'unbelievably');
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('tok-count')));
    expect(find.descendant(of: find.byKey(const ValueKey('tok-count')), matching: find.text('3')), findsOneWidget);
    expectNoErrors(tester);
  });
}
