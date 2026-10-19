import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_science.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_science: tapping a field shows its story', (tester) async {
    await pumpApp(tester, home: const S3ScienceScreen());
    await scrollTo(tester, find.byKey(const ValueKey('science-headline')));
    expect(find.text('200 million+ protein structures, free'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('science-1')));
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('science-headline')));
    expect(find.text('10-day forecast in under a minute'), findsOneWidget);
    expectNoErrors(tester);
  });
}
