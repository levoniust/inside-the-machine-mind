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

  testWidgets('s3_robots: camera inset shows during See and Check, hidden during Understand and Act',
      (tester) async {
    await pumpApp(tester, home: const S3RobotsScreen());
    await scrollTo(tester, find.byKey(const ValueKey('robot-cam-inset')));
    expect(find.byKey(const ValueKey('robot-cam-inset')), findsOneWidget);
    await tapVisible(tester, find.byTooltip('Next step')); // Understand
    await pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('robot-cam-inset')), findsNothing);
    await tapVisible(tester, find.byTooltip('Next step')); // Act
    await pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('robot-cam-inset')), findsNothing);
    await tapVisible(tester, find.byTooltip('Next step')); // Check
    await pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('robot-cam-inset')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_robots: every task runs the loop without errors in light mode at text scale 1.3',
      (tester) async {
    await pumpApp(tester, home: const S3RobotsScreen(), brightness: Brightness.light, textScale: 1.3);
    for (final task in const ['robot-task-0', 'robot-task-1', 'robot-task-2']) {
      await tapVisible(tester, find.byKey(ValueKey(task)));
      await pumpFrames(tester, 3);
      expect(find.byKey(const ValueKey('robot-cam-inset')), findsOneWidget); // See
      for (var step = 0; step < 3; step++) {
        await tapVisible(tester, find.byTooltip('Next step'));
        await pumpFrames(tester, 3);
      }
      // After three steps we are on Check, where the camera looks again.
      expect(find.byKey(const ValueKey('robot-caption-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('robot-cam-inset')), findsOneWidget);
    }
    expectNoErrors(tester);
  });

  testWidgets('s3_robots: the loop runs on a 360 dp phone without errors', (tester) async {
    await pumpApp(tester, home: const S3RobotsScreen(), size: const Size(360, 740));
    for (final task in const ['robot-task-0', 'robot-task-1', 'robot-task-2']) {
      await tapVisible(tester, find.byKey(ValueKey(task)));
      await pumpFrames(tester, 3);
      for (var step = 0; step < 3; step++) {
        await tapVisible(tester, find.byTooltip('Next step'));
        await pumpFrames(tester, 3);
      }
      expect(find.byKey(const ValueKey('robot-caption-3')), findsOneWidget);
    }
    expectNoErrors(tester);
  });
}
