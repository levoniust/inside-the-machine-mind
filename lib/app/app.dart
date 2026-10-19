import 'package:flutter/material.dart';

import '../core/progress.dart';
import '../screens/home/home_screen.dart';
import 'theme.dart';

class MachineMindApp extends StatelessWidget {
  const MachineMindApp({super.key, required this.progress, this.home});

  final ProgressStore progress;

  /// Override the first screen (tests).
  final Widget? home;

  @override
  Widget build(BuildContext context) => AppScope(
        progress: progress,
        child: MaterialApp(
          title: 'Inside the Machine Mind',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          home: home ?? const HomeScreen(),
        ),
      );
}
