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

  testWidgets('s3_intro: the chip wakes up and lights its layer bars after the packet lands', (tester) async {
    await pumpApp(tester, home: const S3IntroScreen());
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('waits on the right', caseSensitive: false)), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('intro-send')));
    // ~350 ms in: the wake-up (1100 ms for five layers) is running but not finished.
    await pumpFrames(tester, 6);
    expect(find.bySemanticsLabel(RegExp('waking up', caseSensitive: false)), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('all 5 layers', caseSensitive: false)), findsNothing);
    // Well past the 1100 ms wake-up: every layer is lit.
    await pumpFrames(tester, 21);
    expect(find.bySemanticsLabel(RegExp('awake: all 5 layers', caseSensitive: false)), findsOneWidget);
    handle.dispose();
    expectNoErrors(tester);
  });

  testWidgets('s3_intro: the stops ahead highlight in sequence after the packet arrives', (tester) async {
    await pumpApp(tester, home: const S3IntroScreen());
    expect(find.byIcon(Icons.check), findsNothing);
    expect(find.byKey(const ValueKey('preview-replay')), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('intro-send')));
    await scrollTo(tester, find.byKey(const ValueKey('preview-stop-0')));
    // Let the first walk finish (~1500 ms for five stops).
    await pumpFrames(tester, 34);
    expect(find.byIcon(Icons.check), findsNWidgets(5));
    expect(find.text('Five stops, one word at a time.'), findsOneWidget);

    // Walk again gives a deterministic pass: the highlight restarts at stop 1 on tap.
    await tapVisible(tester, find.byKey(const ValueKey('preview-replay')));
    expect(find.text('Following your question: Chopped into tokens…'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    await pumpFrames(tester, 9); // ~500 ms in: stop 2 is lit, stop 1 is done
    expect(find.text('Following your question: Turned into coordinates…'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await pumpFrames(tester, 26); // well past 1500 ms: all five are done
    expect(find.byIcon(Icons.check), findsNWidgets(5));
    expect(find.text('Five stops, one word at a time.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_intro: no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(tester, home: const S3IntroScreen(), size: const Size(360, 740), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester, 2);
    await tapVisible(tester, find.byKey(const ValueKey('intro-send')));
    await scrollTo(tester, find.byKey(const ValueKey('preview-stop-4')));
    await pumpFrames(tester, 8); // mid-walk: a stop is highlighted, a check has appeared
    expect(find.textContaining('Following your question:'), findsOneWidget);
    await pumpFrames(tester, 30); // run the walk to its end
    expect(find.byIcon(Icons.check), findsNWidgets(5));
    expectNoErrors(tester);
  });
}
