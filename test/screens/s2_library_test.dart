import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/s2/s2_library.dart';

import '../helpers.dart';

void main() {
  test('15T tokens take about 257,000 years to read', () => expect(yearsToRead(15e12), closeTo(256849, 100)));

  testWidgets('s2_library: choosing a source changes the description', (tester) async {
    await pumpApp(tester, home: const S2LibraryScreen());
    await scrollTo(tester, find.byKey(const ValueKey('library-text-0')));
    expect(find.textContaining('Common Crawl'), findsWidgets);
    await tapVisible(tester, find.byKey(const ValueKey('library-2')));
    await pumpFrames(tester, 3);
    await scrollTo(tester, find.byKey(const ValueKey('library-text-2')));
    expect(find.textContaining('open-source'), findsOneWidget);
    // The cards at the bottom follow the chosen source (Dolma's Table 1).
    await scrollTo(tester, find.byKey(const ValueKey('library-size-2')));
    expect(find.text('411 billion'), findsOneWidget);
    expect(find.text('2.5 trillion'), findsNothing);
    await tapVisible(tester, find.byKey(const ValueKey('library-1')));
    await pumpFrames(tester, 3);
    expect(find.text('20 GB'), findsOneWidget);
    expect(find.text('6 billion'), findsOneWidget);
    expectNoErrors(tester);
  });
}
