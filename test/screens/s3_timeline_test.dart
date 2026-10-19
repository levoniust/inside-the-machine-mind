import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_timeline.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_timeline: tapping milestones and "Later" changes the story card', (tester) async {
    await pumpApp(tester, home: const S3TimelineScreen());
    await scrollTo(tester, find.byKey(const ValueKey('timeline-title')));
    expect(find.text('AlphaGo\'s Move 37'), findsWidgets);
    await tapVisible(tester, find.byKey(const ValueKey('timeline-later')));
    await pumpFrames(tester, 8);
    expect(find.text('The Transformer'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('timeline-0')));
    await pumpFrames(tester, 8);
    expect(find.text('Deep Blue beats Kasparov'), findsOneWidget);
    expectNoErrors(tester);
  });
}
