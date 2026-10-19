import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/progress.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.load();
  runApp(MachineMindApp(progress: progress));
}
