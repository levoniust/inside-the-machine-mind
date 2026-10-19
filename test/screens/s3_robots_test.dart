import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_robots.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_robots: stepping the loop and switching tasks updates the caption', (tester) async {
    await pumpApp(tester, home: const S3RobotsScreen());
    await scrollTo(tester, find.byKey(const ValueKey('robot-caption-0')));
    expect(find.textContaining('crumpled shirt'), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Next step'));
    await tapVisible(tester, find.byTooltip('Next step'));
    await pumpFrames(tester, 3);
    expect(find.textContaining('motor commands'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('robot-task-2')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('robot-caption-0')));
    expect(find.textContaining('Three blocks'), findsOneWidget);
    expectNoErrors(tester);
  });
}
