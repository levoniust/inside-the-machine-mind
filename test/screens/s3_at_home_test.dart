import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s3/s3_at_home.dart';

import '../helpers.dart';

void main() {
  test('70B at 8-bit fits a DGX Spark at ~3.9 tokens/s; 405B at 16-bit fits nothing', () {
    final spark = HomeRun(devices[4], 70e9, 8);
    expect(spark.fits, isTrue);
    expect(spark.tokensPerSecond, closeTo(3.9, 0.1));
    for (final d in devices) {
      expect(HomeRun(d, 405e9, 16).fits, isFalse);
    }
    expect(HomeRun(devices[0], 8e9, 4).tokensPerSecond, closeTo(234, 1));
  });

  testWidgets('s3_at_home: switching device and model changes the verdict', (tester) async {
    await pumpApp(tester, home: const S3AtHomeScreen());
    await scrollTo(tester, find.byKey(const ValueKey('home-verdict')));
    expect(find.textContaining('It fits!'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('home-device-0'))); // RTX 3090, 24 GB
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('home-verdict')));
    expect(find.textContaining('Doesn\'t fit'), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('home-model-1'))); // 8B
    await pumpFrames(tester, 4);
    await scrollTo(tester, find.byKey(const ValueKey('home-verdict')));
    expect(find.textContaining('It fits!'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s3_at_home: large text + light mode', (tester) async {
    await pumpApp(tester, home: const S3AtHomeScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
