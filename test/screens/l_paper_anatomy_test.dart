import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s8/l_paper_anatomy.dart';

import '../helpers.dart';

void main() {
  testWidgets('tapping a part of the page explains it; passes switch', (tester) async {
    await pumpApp(tester, home: const LPaperAnatomyScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('anat-name')), 300);
    expect(tester.widget<Text>(find.byKey(const ValueKey('anat-name'))).data, 'Abstract');
    await tester.ensureVisible(find.byKey(const ValueKey('anat-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('anat-2')));
    await tester.pump();
    expect(tester.widget<Text>(find.byKey(const ValueKey('anat-name'))).data, 'Figure 1');
    await tester.scrollUntilVisible(find.byKey(const ValueKey('anat-pass')), 300);
    await tester.ensureVisible(find.text('Deep'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deep'));
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('anat-pass-text'))).data,
      startsWith('Work through the maths'),
    );
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LPaperAnatomyScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
