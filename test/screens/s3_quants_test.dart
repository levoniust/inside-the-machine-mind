import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_quants.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders the decoder and starts with a hint', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen());
    expect(find.text('Crack the filename'), findsOneWidget);
    expect(find.textContaining('Tap a piece above'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('tapping a filename piece explains it', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('quant-part-1')));
    await pumpFrames(tester);
    expect(find.textContaining('quantized'), findsWidgets);
    expect(find.byKey(const ValueKey('quant-explain')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('picking another filename clears a stale explanation', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('quant-part-3'))); // "_M" of file 0
    await pumpFrames(tester);
    expect(find.textContaining('Medium care'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('quant-file-1'))); // 3-part filename
    await pumpFrames(tester);
    expect(find.textContaining('Tap a piece above'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('size calculator does the bits-per-weight math', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen());
    // Default: 70B at Q4_K (4.5 bits/weight) → ~39 GB.
    await scrollTo(tester, find.byKey(const ValueKey('quant-calc-size')));
    expect(find.text('39 GB'), findsOneWidget);
    // IQ1_S: 1.5 bits → 70e9*1.5/8 ≈ 13 GB.
    await tapVisible(tester, find.byKey(const ValueKey('quant-calc-format-6')));
    await pumpFrames(tester);
    expect(find.text('13 GB'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('decoder ring opens a row', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen());
    await tapVisible(tester, find.byKey(const ValueKey('decoder-row-11')));
    await pumpFrames(tester);
    expect(find.textContaining('Unsloth'), findsWidgets);
    expectNoErrors(tester);
  });

  testWidgets('renders at large text in light mode', (tester) async {
    await pumpApp(tester, home: const S3QuantsScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
