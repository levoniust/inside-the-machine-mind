// Renders screens to PNG with real fonts for visual review (not a pass/fail golden test).
// Run:  flutter test tool/screenshots/shots_test.dart --update-goldens [--dart-define=SHOTS=s1_storage,home]
// Output: tool/screenshots/out/<name>.png  (git-ignored)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/app/app.dart';
import 'package:machine_mind/content/lessons.dart';
import 'package:machine_mind/core/progress.dart';
import 'package:machine_mind/screens/home/home_screen.dart';
import 'package:machine_mind/screens/home/section_hub.dart';

const _only = String.fromEnvironment('SHOTS');
const _light = bool.fromEnvironment('LIGHT');

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '${Platform.environment['HOME']}/opt/flutter';
  final dir = '$flutterRoot/bin/cache/artifacts/material_fonts';
  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final file = File(f.startsWith('/') ? f : '$dir/$f');
      if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
    }
    await loader.load();
  }
  await load('Roboto', ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Black.ttf', 'Roboto-Italic.ttf']);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
  await load('monospace', ['/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf', '/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf']);
}

void main() {
  setUpAll(_loadFonts);

  final targets = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'hub1': () => const SectionHub(number: 1),
    'hub2': () => const SectionHub(number: 2),
    'hub3': () => const SectionHub(number: 3),
    for (final l in allLessons) l.id: () => Builder(builder: l.builder),
  };
  final wanted = _only.isEmpty ? targets.keys.toSet() : _only.split(',').toSet();

  for (final e in targets.entries.where((e) => wanted.contains(e.key))) {
    testWidgets('shot ${e.key}', (tester) async {
      const size = Size(412, 2600);
      tester.view.physicalSize = size * 1.5;
      tester.view.devicePixelRatio = 1.5;
      tester.platformDispatcher.platformBrightnessTestValue = _light ? Brightness.light : Brightness.dark;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: true, platformBrightness: _light ? Brightness.light : Brightness.dark),
        child: MachineMindApp(progress: ProgressStore(), home: e.value()),
      ));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await expectLater(find.byType(MachineMindApp), matchesGoldenFile('out/${e.key}${_light ? '_light' : ''}.png'));
    });
  }
}
