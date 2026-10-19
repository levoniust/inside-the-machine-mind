import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_beyond_text.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_beyond_text: switching to voice and stepping the agent loop', (tester) async {
    await pumpApp(tester, home: const S3BeyondTextScreen());
    await tapVisible(tester, find.byKey(const ValueKey('beyond-chop')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Put it back together'), findsOneWidget);
    await tapVisible(tester, find.text('A voice'));
    await pumpFrames(tester, 3);
    expect(find.byKey(const ValueKey('beyond-caption-sound')), findsOneWidget);
    for (var i = 0; i < 4; i++) {
      await tapVisible(tester, find.byTooltip('Next step'));
    }
    expect(find.text('5 / 5'), findsOneWidget);
    expectNoErrors(tester);
  });
}
