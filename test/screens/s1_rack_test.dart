import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s1/s1_rack.dart';

import '../helpers.dart';

void main() {
  testWidgets('s1_rack: switching to air cooling changes the caption', (tester) async {
    await pumpApp(tester, home: const S1RackScreen());
    await scrollTo(tester, find.byKey(const ValueKey('rack-caption')));
    expect(find.textContaining('Cold liquid'), findsOneWidget);
    await tapVisible(tester, find.text('Air cooling'));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('rack-caption')));
    expect(find.textContaining('Fans alone'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_rack: tapping a tray in the drawing names its kind', (tester) async {
    await pumpApp(tester, home: const S1RackScreen());
    final drawing = find.byKey(const ValueKey('rack-drawing'));
    await scrollTo(tester, drawing);
    final topLeft = tester.getTopLeft(drawing);
    expect(find.textContaining('Tap a tray'), findsOneWidget);
    // The drawing is 220x400: middle band (y≈200) = switch trays, top row (y≈12) = compute trays.
    await tester.tapAt(topLeft + const Offset(110, 199));
    await pumpFrames(tester, 3);
    expect(find.textContaining('wiring that joins'), findsOneWidget);
    await tester.tapAt(topLeft + const Offset(110, 12));
    await pumpFrames(tester, 3);
    expect(find.textContaining('workhorse'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('s1_rack: legend chips select and deselect the tray kind', (tester) async {
    await pumpApp(tester, home: const S1RackScreen());
    final chip = find.byKey(const ValueKey('rack-legend-switch'));
    await scrollTo(tester, chip);
    await tapVisible(tester, chip);
    expect(find.textContaining('wiring that joins'), findsOneWidget);
    // Tapping the same selection again clears it.
    await tapVisible(tester, chip);
    expect(find.textContaining('Tap a tray'), findsOneWidget);
    expect(find.textContaining('wiring that joins'), findsNothing);
    expectNoErrors(tester);
  });

  testWidgets('s1_rack: no errors at text scale 1.3, light', (tester) async {
    await pumpApp(tester, home: const S1RackScreen(), textScale: 1.3, brightness: Brightness.light);
    await scrollTo(tester, find.byKey(const ValueKey('rack-drawing')));
    await scrollTo(tester, find.byKey(const ValueKey('rack-legend-compute')));
    await scrollTo(tester, find.byKey(const ValueKey('rack-tray-caption')));
    expectNoErrors(tester);
  });

  testWidgets('s1_rack: fits a 360 dp phone and everything scrolls clean', (tester) async {
    await pumpApp(tester, home: const S1RackScreen(), size: const Size(360, 740));
    await scrollTo(tester, find.byKey(const ValueKey('rack-drawing')));
    await scrollTo(tester, find.byKey(const ValueKey('rack-legend-compute')));
    await scrollTo(tester, find.byKey(const ValueKey('rack-tray-caption')));
    await scrollTo(tester, find.textContaining('13.4 TB'));
    await scrollTo(tester, find.textContaining('130 TB/s'));
    expectNoErrors(tester);
  });
}
