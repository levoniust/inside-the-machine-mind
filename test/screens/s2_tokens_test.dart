import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_tokens.dart';

import '../helpers.dart';

void main() {
  testWidgets('s2_tokens: merging reduces the token count', (tester) async {
    await pumpApp(tester, home: const S2TokensScreen());
    await scrollTo(tester, find.byKey(const ValueKey('bpe-count')));
    final before = (tester.widget(find.descendant(of: find.byKey(const ValueKey('bpe-count')), matching: find.byType(Text)).last) as Text).data;
    await tapVisible(tester, find.byKey(const ValueKey('bpe-auto')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('bpe-count')));
    final after = (tester.widget(find.descendant(of: find.byKey(const ValueKey('bpe-count')), matching: find.byType(Text)).last) as Text).data;
    expect(int.parse(after!), lessThan(int.parse(before!)));
    expectNoErrors(tester);
  });
}
