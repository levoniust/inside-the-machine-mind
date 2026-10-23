import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/extras/sources_screen.dart';

import '../helpers.dart';

void main() {
  testWidgets('sources list offers a readable copy per source', (tester) async {
    await pumpApp(tester, home: const SourcesScreen());
    expect(find.textContaining('Tap any source to read a copy'), findsOneWidget);
    // The list is lazy: scroll the transformer entry into view before expecting it.
    await scrollTo(tester, find.byKey(const ValueKey('source-SRC-TRANSFORMER')));
    expect(find.byKey(const ValueKey('source-SRC-TRANSFORMER')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('tapping a source opens its bundled copy', (tester) async {
    await pumpApp(tester, home: const SourcesScreen());
    await tapVisible(tester, find.byKey(const ValueKey('source-SRC-TRANSFORMER')));
    await pumpFrames(tester, 20);
    // The copied document begins with its provenance header.
    expect(find.textContaining('SOURCE COPY — SRC-TRANSFORMER', findRichText: true), findsOneWidget);
    expect(find.text('offline copy'), findsOneWidget);
    // This paper ships with its original PDF, so the reader offers it.
    expect(find.byKey(const ValueKey('open-pdf')), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('reader works at large text in light mode', (tester) async {
    await pumpApp(tester, home: const SourcesScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
