import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_runtimes.dart';

import '../helpers.dart';

double _opacity(WidgetTester t, int i) => t
    .widget<AnimatedOpacity>(find.ancestor(of: find.byKey(ValueKey('rt-$i')), matching: find.byType(AnimatedOpacity)))
    .opacity;

void main() {
  testWidgets('the Mac filter dims vLLM and ExLlamaV3; tapping an engine shows its own words', (tester) async {
    await pumpApp(tester, home: const LRuntimesScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('rt-filter-mac')), 300);
    await tester.ensureVisible(find.byKey(const ValueKey('rt-filter-mac')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rt-filter-mac')));
    await tester.pump();
    expect(_opacity(tester, 3), lessThan(1)); // vLLM
    expect(_opacity(tester, 4), lessThan(1)); // ExLlamaV3
    expect(_opacity(tester, 5), 1); // MLX LM
    await tester.ensureVisible(find.byKey(const ValueKey('rt-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rt-0')));
    await tester.pump();
    expect(find.textContaining('LLM inference in C/C++'), findsOneWidget);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LRuntimesScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
