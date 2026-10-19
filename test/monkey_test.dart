// Widget-level "monkey": random taps and drags on every lesson (and from the home screen), failing on any
// exception or overflow. Replaces the emulator monkey, whose software renderer segfaults on this host.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/lessons.dart';

import 'helpers.dart';

const _size = Size(412, 915);

/// [events] random gestures with a fixed seed: mostly taps, some scroll drags, the odd system back.
Future<void> monkey(WidgetTester tester, int seed, int events) async {
  final rnd = math.Random(seed);
  // Keep the full report (it names the widget and file:line) for the failure message.
  String? report;
  final orig = FlutterError.onError;
  FlutterError.onError = (d) {
    report ??= d.toString();
    orig?.call(d);
  };
  addTearDown(() => FlutterError.onError = orig);
  for (var i = 0; i < events; i++) {
    final p = Offset(rnd.nextDouble() * _size.width, rnd.nextDouble() * _size.height);
    final r = rnd.nextDouble();
    final String what;
    if (r < 0.75) {
      what = 'tap';
      await tester.tapAt(p);
    } else if (r < 0.97) {
      what = 'drag';
      await tester.dragFrom(p, Offset((rnd.nextDouble() - 0.5) * 300, (rnd.nextDouble() - 0.5) * 900));
    } else {
      what = 'back';
      await tester.binding.handlePopRoute();
    }
    await tester.pump(const Duration(milliseconds: 60));
    final e = tester.takeException();
    if (e != null) fail('event $i ($what at $p): ${report ?? e}');
  }
}

void main() {
  for (final (i, l) in allLessons.indexed) {
    testWidgets('monkey: ${l.id}', (tester) async {
      await pumpApp(tester, home: Builder(builder: l.builder), size: _size);
      await monkey(tester, 1000 + i, 120);
    });
  }

  for (final seed in [42, 4242, 7]) {
    testWidgets('monkey: whole app from the home screen (seed $seed)', (tester) async {
      await pumpApp(tester, size: _size);
      await monkey(tester, seed, 800);
    });
  }

  testWidgets('monkey: whole app at large text in light mode', (tester) async {
    await pumpApp(tester, size: _size, brightness: Brightness.light, textScale: 1.3);
    await monkey(tester, 99, 800);
  });
}
