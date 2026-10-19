import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/app/app.dart';
import 'package:machine_mind/core/progress.dart';

/// Pump the app (or a single screen) with an in-memory progress store, phone size, animations off
/// so typewriter text and loops settle.
Future<ProgressStore> pumpApp(
  WidgetTester tester, {
  Widget? home,
  Size size = const Size(412, 915),
  Brightness brightness = Brightness.dark,
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);
  final store = ProgressStore();
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size, disableAnimations: true, platformBrightness: brightness, textScaler: TextScaler.linear(textScale)),
      child: MachineMindApp(progress: store, home: home),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
  return store;
}

/// Pump a few frames (looping animations never "settle", so don't use pumpAndSettle with them).
Future<void> pumpFrames(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Fail on any overflow / exception reported during the test.
void expectNoErrors(WidgetTester tester) => expect(tester.takeException(), isNull);

/// Scroll [finder] into view (building it first if the list is lazy) and tap it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 250, scrollable: find.byType(Scrollable).first);
  }
  // Center it, so the tap can't land on the bottom navigation bar.
  await tester.runAsync(() => Scrollable.ensureVisible(tester.element(finder.first), alignment: 0.5));
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(finder.first);
  await tester.pump(const Duration(milliseconds: 50));
}

/// Scroll the lesson list until [finder] is built and on screen (lists are lazy: off-screen cards don't exist yet).
Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 250, scrollable: find.byType(Scrollable).first);
  }
  await tester.runAsync(() => Scrollable.ensureVisible(tester.element(finder.first), alignment: 0.5));
  await tester.pump(const Duration(milliseconds: 50));
}
