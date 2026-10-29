import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s11/e_pictures.dart';

import '../helpers.dart';

void main() {
  testWidgets('e_pictures: denoising runs from static to a finished picture; prompt and seed change it', (
    tester,
  ) async {
    await pumpApp(tester, home: const EPicturesScreen());
    await scrollTo(tester, find.byKey(const ValueKey('pic-steps')));
    expect(find.textContaining('Pure static'), findsOneWidget);
    final s = tester.widget<Slider>(
      find.descendant(of: find.byKey(const ValueKey('pic-steps')), matching: find.byType(Slider)),
    );
    s.onChanged!(6);
    await tester.pump();
    expect((tester.widget<Text>(find.byKey(const ValueKey('pic-stage')))).data, startsWith('Big shapes first'));
    s.onChanged!(30);
    await tester.pump();
    expect(find.textContaining('Done: a cat'), findsOneWidget);
    await tapVisible(tester, find.text('"a lighthouse"'));
    await tester.pump();
    expect(find.textContaining('Done: a lighthouse'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('pic-seed')));
    await tester.pump();
    expect(find.text('New seed (now 2)'), findsOneWidget);
    expect(find.byKey(const ValueKey('pic-game-lighthouse-1-30')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_pictures: the undo panel steps through', (tester) async {
    await pumpApp(tester, home: const EPicturesScreen());
    await scrollTo(tester, find.byKey(const ValueKey('pic-undo-0')));
    await tapVisible(tester, find.byIcon(Icons.chevron_right).first);
    await tester.pump();
    expect(find.byKey(const ValueKey('pic-undo-1')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('e_pictures has no overflow on a small phone at large text in light mode', (tester) async {
    await pumpApp(
      tester,
      home: const EPicturesScreen(),
      size: const Size(360, 740),
      textScale: 1.3,
      brightness: Brightness.light,
    );
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
