import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/screens/extras/egg_gallery_screen.dart';

import '../helpers.dart';

void main() {
  test('gallery manifest lists 18 images that exist as assets', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final d = await GalleryData.load(rootBundle);
    expect(d.images.length, 18);
    for (final i in d.images) {
      expect((await rootBundle.load(i.file)).lengthInBytes, greaterThan(10000));
      expect(i.prompt, isNotEmpty);
    }
  });

  testWidgets('gallery opens a picture with its prompt', (tester) async {
    await pumpApp(tester, home: const EggGalleryScreen());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await pumpFrames(tester, 10);
    expect(find.byKey(const ValueKey('gallery-0')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('gallery-0')));
    await pumpFrames(tester, 20);
    expect(find.text('What it was asked to draw:'), findsOneWidget);
    expectNoErrors(tester);
  });
}
