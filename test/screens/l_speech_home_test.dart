import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_speech_home.dart';

import '../helpers.dart';

void main() {
  testWidgets('l_speech_home: picking a Whisper size updates its numbers', (tester) async {
    await pumpApp(tester, home: const LSpeechHomeScreen());
    await scrollTo(tester, find.byKey(const ValueKey('speech-size-turbo')));
    await tapVisible(tester, find.byKey(const ValueKey('speech-size-turbo')));
    await tester.pump();
    expect(find.text('809M'), findsOneWidget);
    expect(find.byKey(const ValueKey('speech-note-turbo')), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('speech-size-large')));
    await tester.pump();
    expect(find.text('~10 GB'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_speech_home: answering all four needs explains each and scores', (tester) async {
    await pumpApp(tester, home: const LSpeechHomeScreen());
    const picks = [1, 1, 2, 0];
    for (var n = 0; n < picks.length; n++) {
      await scrollTo(tester, find.byKey(ValueKey('speech-need-$n-${picks[n]}')));
      await tapVisible(tester, find.byKey(ValueKey('speech-need-$n-${picks[n]}')));
      await tester.pump();
      expect(find.byKey(ValueKey('speech-why-$n')), findsOneWidget);
    }
    expect(find.textContaining('Large wants ~10 GB'), findsOneWidget);
    expect(find.text('Best setups: 3 of 4.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('l_speech_home has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const LSpeechHomeScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
