import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/glossary.dart';
import 'package:machine_mind/screens/s2/s2_decoder.dart';

import '../helpers.dart';

void main() {
  test('every decoder term exists in the glossary', () {
    for (final t in decoderTerms) {
      expect(findTerm(t), isNotNull, reason: t);
    }
  });

  testWidgets('s2_decoder: flipping a card and "flip all" update the counter', (tester) async {
    await pumpApp(tester, home: const S2DecoderScreen());
    await tapVisible(tester, find.byKey(const ValueKey('decoder-0')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('going to school'), findsOneWidget);
    expect(find.text('1 / 16 decoded'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('decoder-all')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('16 / 16 decoded'), findsOneWidget);
    expectNoErrors(tester);
  });
}
