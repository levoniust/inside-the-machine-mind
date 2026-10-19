import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_frontier.dart';

import '../helpers.dart';

void main() {
  testWidgets('s3_frontier: zoom levels change the caption; MoE toggle changes the experts', (tester) async {
    await pumpApp(tester, home: const S3FrontierScreen());
    expect(find.byKey(const ValueKey('frontier-caption-model')), findsOneWidget);
    await tapVisible(tester, find.text('Cluster'));
    await pumpFrames(tester, 4);
    expect(find.byKey(const ValueKey('frontier-caption-cluster')), findsOneWidget);
    await tapVisible(tester, find.text('Layer'));
    await pumpFrames(tester, 4);
    expect(find.byKey(const ValueKey('frontier-caption-layer')), findsOneWidget);
    await scrollTo(tester, find.byKey(const ValueKey('frontier-moe-caption')));
    expect(find.textContaining('Only 2 of 8'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('frontier-moe')));
    await pumpFrames(tester, 4);
    expect(find.text('Every expert works on every token.'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_frontier: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S3FrontierScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
