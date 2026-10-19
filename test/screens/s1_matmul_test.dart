import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/app/theme.dart';
import 'package:machine_mind/screens/s1/s1_matmul.dart';

import '../helpers.dart';

/// The lime the active row×column pair is painted with.
Color _lit(WidgetTester tester) {
  final c = AppColors.of(tester.element(find.byKey(const ValueKey('mm-a-1-0'))));
  return c.lime.withValues(alpha: 0.9);
}

Color _cellColor(WidgetTester tester, String key) =>
    (tester.widget<Container>(find.byKey(ValueKey(key))).decoration! as BoxDecoration).color!;

void main() {
  test('matrix product values', () {
    expect(cellValue(0, 0), 2 * 1 + 0 * 0 + 1 * 4);
    expect(cellValue(1, 2), 1 * 0 + 3 * 3 + 2 * 1);
  });

  testWidgets('s1_matmul: tapping a cell shows the working', (tester) async {
    await pumpApp(tester, home: const S1MatmulScreen());
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-5')));
    await pumpFrames(tester, 2);
    expect(find.text('1×0 + 3×3 + 2×1 = 11'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('mm-all')));
    expect(find.textContaining('27 / 27'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_matmul: with reduce motion the answer appears at once, no counting', (tester) async {
    await pumpApp(tester, home: const S1MatmulScreen()); // animations: false => reduce motion
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-5')));
    expect(find.text('1×0 + 3×3 + 2×1 = 11'), findsOneWidget);
    expect(find.text('Pair 1 of 3 - running total'), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('mm-cell-5')), matching: find.text('11')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_matmul: with animations the dot product counts through the pairs one by one', (tester) async {
    await pumpApp(tester, home: const S1MatmulScreen(), animations: true);
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-5'))); // row 2 × column 3
    final lit = _lit(tester);

    // First pair only (1×0): it lights up in both grids, and the running total shows just it.
    expect(find.text('1×0 = 0'), findsOneWidget);
    expect(find.text('Pair 1 of 3 - running total'), findsOneWidget);
    expect(_cellColor(tester, 'mm-a-1-0'), lit);
    expect(_cellColor(tester, 'mm-b-0-2'), lit);
    expect(_cellColor(tester, 'mm-a-1-1'), isNot(lit));
    expect(_cellColor(tester, 'mm-b-1-2'), isNot(lit));
    expect(find.textContaining('Cells done: 0 / 9'), findsOneWidget);

    // 250 ms later the second pair takes over and the first falls back to its row/column guide.
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('1×0 + 3×3 = 9'), findsOneWidget);
    expect(find.text('Pair 2 of 3 - running total'), findsOneWidget);
    expect(_cellColor(tester, 'mm-a-1-1'), lit);
    expect(_cellColor(tester, 'mm-b-1-2'), lit);
    expect(_cellColor(tester, 'mm-a-1-0'), isNot(lit));
    expect(_cellColor(tester, 'mm-b-0-2'), isNot(lit));

    // Once all three 250 ms pairs are done, the value and the count are revealed.
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    expect(find.text('1×0 + 3×3 + 2×1 = 11'), findsOneWidget);
    expect(find.textContaining('running total'), findsNothing);
    expect(find.descendant(of: find.byKey(const ValueKey('mm-cell-5')), matching: find.text('11')), findsOneWidget);
    expect(find.textContaining('Cells done: 1 / 9'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_matmul: tapping another cell mid-count still counts the first one', (tester) async {
    await pumpApp(tester, home: const S1MatmulScreen(), animations: true);
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-0')));
    await tester.pump(const Duration(milliseconds: 300)); // mid-count
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-4')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Cells done: 2 / 9'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('mm-cell-0')), matching: find.text('${cellValue(0, 0)}')),
        findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_matmul: "Fill in the rest" stops a running count and finishes everything at once', (tester) async {
    await pumpApp(tester, home: const S1MatmulScreen(), animations: true);
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-5')));
    expect(find.text('1×0 = 0'), findsOneWidget); // mid-count
    await tapVisible(tester, find.byKey(const ValueKey('mm-all')));
    expect(find.textContaining('27 / 27'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1×0 + 3×3 + 2×1 = 11'), findsOneWidget); // no half-count left behind
    expect(find.textContaining('Pair '), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s1_matmul: mid-count frames fit a 360 dp phone at text scale 1.3 in light mode', (tester) async {
    await pumpApp(tester,
        home: const S1MatmulScreen(),
        size: const Size(360, 740),
        textScale: 1.3,
        brightness: Brightness.light,
        animations: true);
    await tapVisible(tester, find.byKey(const ValueKey('mm-cell-5')));
    await pumpFrames(tester, 4);
    expect(find.byKey(const ValueKey('mm-work')), findsOneWidget);
    expectNoErrors(tester);
  });
}
