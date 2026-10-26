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

  testWidgets('s3_intro: after the packet lands, every reply token goes through the layers', (tester) async {
    await pumpApp(tester, home: const S3IntroScreen());
    final handle = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('waits on the right', caseSensitive: false)), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('intro-send')));
    // 300 ms in: the first token (500 ms each) is part-way up the layers and nothing is out yet.
    await pumpFrames(tester, 6);
    expect(find.bySemanticsLabel(RegExp('Making token 1 of 8: [1-4] of 5 layers lit')), findsOneWidget);
    expect(find.text('Air'), findsNothing);
    // 1.3 s in: tokens 1 and 2 are out, the third is in the layers.
    await pumpFrames(tester, 20);
    expect(find.text('Air'), findsOneWidget);
    expect(find.text(' scat'), findsOneWidget);
    expect(find.text('ters'), findsNothing);
    expect(find.text('Token 3 of 8: going through the layers…'), findsOneWidget);
    // Past 4 s: the short reply is complete.
    await pumpFrames(tester, 60);
    expect(find.text('Reply: 8 tokens'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('reply is done: 8 tokens')), findsOneWidget);
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
