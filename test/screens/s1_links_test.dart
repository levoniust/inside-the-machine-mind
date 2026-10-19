import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_links.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_links: choosing SATA shows its speed', (tester) async {
    await pumpApp(tester, home: const S1LinksScreen());
    await tapVisible(tester, find.byKey(const ValueKey('link-0')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('link-speed')));
    expect(find.text('0.6 GB/s'), findsWidgets);
    expectNoErrors(tester);
  });
}
