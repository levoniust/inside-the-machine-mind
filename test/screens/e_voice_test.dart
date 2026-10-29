import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_voice.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_voice: switching to one model replaces the relay', (tester) async {
    await pumpApp(tester, home: const EVoiceScreen());
    await scrollTo(tester, find.byKey(const ValueKey('voice-relay')));
    await tapVisible(tester, find.text('One model'));
    await pumpFrames(tester);
    expect(find.byKey(const ValueKey('voice-one')), findsOneWidget);
    expect(find.byKey(const ValueKey('voice-explain-true')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_voice: judging every clue explains it and scores', (tester) async {
    await pumpApp(tester, home: const EVoiceScreen());
    const survives = [true, false, false, true, false, false];
    for (var i = 0; i < survives.length; i++) {
      final pick = i == 1 ? true : survives[i];
      await scrollTo(tester, find.byKey(ValueKey('voice-$i-$pick')));
      await tapVisible(tester, find.byKey(ValueKey('voice-$i-$pick')));
      await tester.pump();
      expect(find.byKey(ValueKey('voice-why-$i')), findsOneWidget);
    }
    expect(find.textContaining('5 of 6'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_voice has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EVoiceScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
