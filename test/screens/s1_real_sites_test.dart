import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_real_sites.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_real_sites: next button pages through the sites', (tester) async {
    await pumpApp(tester, home: const S1RealSitesScreen());
    expect(find.text('Colossus 1'), findsWidgets);
    for (var i = 0; i < 2; i++) {
      await tapVisible(tester, find.byKey(const ValueKey('sites-next')));
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.text('Abilene, Texas (OpenAI & Oracle)'), findsOneWidget);
    expectNoErrors(tester);
  });
}
