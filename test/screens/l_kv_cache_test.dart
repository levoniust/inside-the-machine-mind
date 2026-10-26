import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s6/l_kv_cache.dart';

import '../helpers.dart';

String _kvText(WidgetTester t) =>
    (t.widget<Text>(find.descendant(of: find.byKey(const ValueKey('kv-gb')), matching: find.textContaining('GB'))))
        .data!;

void main() {
  testWidgets('next token grows the strip; KV cache = 1.07 GB for Llama 3.1 8B at 8k in f16', (tester) async {
    await pumpApp(tester, home: const LKvCacheScreen());
    expect(find.text('3 tokens × 6 layers × (K + V) = 36 vectors kept'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('kv-add')));
    await tester.pump();
    expect(find.text('4 tokens × 6 layers × (K + V) = 48 vectors kept'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('kv-gb')), 300);
    expect(_kvText(tester), '1.07 GB');
  });

  testWidgets('every head keeping its own K/V makes it 4× bigger; q8_0 roughly halves it', (tester) async {
    await pumpApp(tester, home: const LKvCacheScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('kv-fullheads')), 300);
    await tester.ensureVisible(find.byKey(const ValueKey('kv-fullheads')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('kv-fullheads')));
    await tester.pump();
    expect(_kvText(tester), '4.29 GB');
    await tester.tap(find.byKey(const ValueKey('kv-fullheads')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('kv-type-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('kv-type-1')));
    await tester.pump();
    expect(_kvText(tester), '0.57 GB');
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LKvCacheScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
