import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_power_cooling.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_power_cooling: heat chain and PUE presets', (tester) async {
    await pumpApp(tester, home: const S1PowerCoolingScreen());
    await tapVisible(tester, find.text('Heat out'));
    await tapVisible(tester, find.byKey(const ValueKey('pc-stage-3')));
    await pumpFrames(tester, 3);
    expect(find.text('Cooling towers'), findsOneWidget);
    await tapVisible(tester, find.text('Best sites ~1.1'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('pc-overhead')));
    expect(find.textContaining('0.10 W more'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_power_cooling: flow follows the side; play/pause controls it', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, home: const S1PowerCoolingScreen());

    // Power side: spark legend + accessibility label for the dot flow.
    expect(find.textContaining('power sparks zip in'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('electricity dots flowing', caseSensitive: false)), findsOneWidget);
    // pumpApp sets reduce-motion, so the loop starts paused (static dots).
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);

    await tapVisible(tester, find.text('Heat out'));
    await pumpFrames(tester, 3);
    expect(find.textContaining('heat blobs drift out'), findsOneWidget);
    expect(find.textContaining('power sparks zip in'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('heat blobs drifting', caseSensitive: false)), findsOneWidget);

    // Play starts the loop, pause stops it again.
    await tapVisible(tester, find.byKey(const ValueKey('pc-flow-toggle')));
    await pumpFrames(tester, 4);
    expect(find.byIcon(Icons.pause), findsOneWidget);
    await tapVisible(tester, find.byKey(const ValueKey('pc-flow-toggle')));
    await pumpFrames(tester, 4);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expectNoErrors(tester);
    handle.dispose();
  });

  testWidgets('s1_power_cooling: flow fits a 360 dp phone', (tester) async {
    await pumpApp(tester, home: const S1PowerCoolingScreen(), size: const Size(360, 780));
    await tapVisible(tester, find.text('Heat out'));
    await pumpFrames(tester, 3);
    expect(find.textContaining('heat blobs drift out'), findsOneWidget);
    expect(find.byKey(const ValueKey('pc-flow-toggle')), findsOneWidget);
    // The dots overlay must not eat taps meant for the stage boxes.
    await tapVisible(tester, find.byKey(const ValueKey('pc-stage-2')));
    await pumpFrames(tester, 3);
    expect(find.text('Chillers'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_power_cooling: no errors at text scale 1.3 in light mode', (tester) async {
    await pumpApp(tester, home: const S1PowerCoolingScreen(), textScale: 1.3, brightness: Brightness.light);
    await tapVisible(tester, find.text('Heat out'));
    await pumpFrames(tester, 3);
    expect(find.textContaining('heat blobs drift out'), findsOneWidget);
    expect(find.byKey(const ValueKey('pc-flow-toggle')), findsOneWidget);
    expectNoErrors(tester);
  });
}
