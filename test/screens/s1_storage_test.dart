import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_storage.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_storage renders and the load race runs to completion', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen());
    expect(find.text('Race: load a 16 GB model'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('race-start')));
    await tester.pump(const Duration(seconds: 11)); // slowest drive: 80 s real / 8 = 10 s
    await tester.pump();
    expect(find.textContaining('done in'), findsNWidgets(4));
    expectNoErrors(tester);
  });

  testWidgets('s1_storage has no overflow at large text and in light mode', (tester) async {
    await pumpApp(tester, home: const S1StorageScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
