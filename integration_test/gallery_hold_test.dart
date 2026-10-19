// Opens the gallery on a device and holds it for 25 s so a screenshot can be taken (visual check of WebP decoding).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:machine_mind/app/app.dart';
import 'package:machine_mind/core/progress.dart';
import 'package:machine_mind/screens/extras/egg_gallery_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('hold gallery', (t) async {
    await t.pumpWidget(MachineMindApp(progress: ProgressStore(), home: const EggGalleryScreen()));
    for (var i = 0; i < 250; i++) {
      await t.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(find.text('The 3060 Gallery'), findsOneWidget);
  });
}
