// Safety net for every lesson screen (including future ones): renders each lesson on a tall screen in
// dark mode, then light mode at large text, and fails on exceptions, overflows or leftover markup.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/lessons.dart';

import 'helpers.dart';

void main() {
  for (final l in allLessons) {
    for (final (mode, scale) in [(Brightness.dark, 1.0), (Brightness.light, 1.3)]) {
      testWidgets('${l.id} renders cleanly (${mode.name}, text ×$scale)', (tester) async {
        await pumpApp(tester, home: Builder(builder: l.builder), size: const Size(412, 3000), brightness: mode, textScale: scale);
        await pumpFrames(tester, 6);
        expectNoErrors(tester);
        final raw = find.byWidgetPredicate((w) {
          final text = w is RichText ? w.text.toPlainText() : (w is Text ? (w.data ?? w.textSpan?.toPlainText() ?? '') : '');
          return text.contains('[[') || text.contains(']]') || text.contains('**');
        });
        expect(raw, findsNothing, reason: 'raw [[term]] or **bold** markup visible in ${l.id}');
      });
    }
  }
}
