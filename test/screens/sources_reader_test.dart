import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dart:io';

import 'package:machine_mind/core/library.dart';
import 'package:machine_mind/screens/extras/source_doc_screen.dart';
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

  testWidgets('without the library plug-in the reader offers to get it', (tester) async {
    await pumpApp(tester, home: const SourceDocScreen(sourceId: 'SRC-TRANSFORMER'));
    Library.instance.useDirectory(Directory('build/no-library-here'));
    await pumpFrames(tester);
    expect(Library.instance.installed, isFalse);
    expect(find.byKey(const ValueKey('library-download')), findsOneWidget);
    expect(find.byKey(const ValueKey('open-pdf')), findsNothing);
    Library.instance.useDirectory(Directory('library'));
    await pumpFrames(tester, 20);
    expect(find.textContaining('SOURCE COPY — SRC-TRANSFORMER', findRichText: true), findsOneWidget);
    expectNoErrors(tester);
  });
}
