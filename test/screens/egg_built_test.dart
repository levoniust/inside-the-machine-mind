import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/extras/egg_built_screen.dart';

import '../helpers.dart';

void main() {
  testWidgets('build-story egg shows the team and stats', (tester) async {
    await pumpApp(tester, home: const EggBuiltScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await pumpFrames(tester, 6);
    expect(find.text('The team'), findsOneWidget);
    expect(find.textContaining('Qwen3.8-Flash-Next', findRichText: true), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('build-story egg: large text + light mode', (tester) async {
    await pumpApp(tester, home: const EggBuiltScreen(), textScale: 1.3, brightness: Brightness.light);
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await pumpFrames(tester, 6);
    expectNoErrors(tester);
  });
}
