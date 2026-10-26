import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s7/l_merging.dart';

import '../helpers.dart';

String _note(WidgetTester t, String key) => t.widget<Text>(find.byKey(ValueKey(key))).data!;

void main() {
  testWidgets('merge methods change the explanation; λ appears for task arithmetic', (tester) async {
    await pumpApp(tester, home: const LMergingScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('merge-note')), 300);
    expect(_note(tester, 'merge-note'), startsWith('Average'));
    expect(find.byKey(const ValueKey('merge-t')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('merge-arithmetic')));
    await tester.pump();
    expect(_note(tester, 'merge-note'), startsWith('Task arithmetic'));
    expect(find.byKey(const ValueKey('merge-t')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('merge-negate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('merge-negate')));
    await tester.pump();
    expect(_note(tester, 'merge-note'), startsWith('Negation'));
  });

  testWidgets('TIES / DARE toggle', (tester) async {
    await pumpApp(tester, home: const LMergingScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('merge-sparsify-note')), 300);
    expect(_note(tester, 'merge-sparsify-note'), startsWith('TIES'));
    await tester.ensureVisible(find.byKey(const ValueKey('merge-sparsify')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('DARE'));
    await tester.pump();
    expect(_note(tester, 'merge-sparsify-note'), startsWith('DARE'));
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LMergingScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
