import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/library.dart';
import 'core/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.load();
  await Library.instance.init();
  runApp(MachineMindApp(progress: progress));
}
