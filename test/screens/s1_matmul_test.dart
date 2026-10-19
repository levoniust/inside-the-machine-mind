import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_matmul.dart';

import '../helpers.dart';

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
}
