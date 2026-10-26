import 'package:flutter/material.dart';

import '../core/progress.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/lab_home.dart';
import '../screens/home/welcome_screen.dart';
import 'theme.dart';

class MachineMindApp extends StatelessWidget {
  const MachineMindApp({super.key, required this.progress, this.home});

  final ProgressStore progress;

  /// Override the first screen (tests).
  final Widget? home;

  @override
  Widget build(BuildContext context) => AppScope(
    progress: progress,
    child: ListenableBuilder(
      listenable: progress,
      builder: (context, _) => MaterialApp(
        title: 'Inside the Machine Mind',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light),
        darkTheme: buildTheme(Brightness.dark),
        themeMode: const [ThemeMode.system, ThemeMode.dark, ThemeMode.light][progress.theme],
        // "Reduce motion" in Settings turns off looping animations app-wide (same as the system setting).
        builder: (context, child) => progress.reduceMotion
            ? MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!)
            : child!,
        home: home ?? const RootScreen(),
      ),
    ),
  );
}

/// First screen: the first-launch question, then the front door or (for enthusiasts) the Lab.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) => switch (AppScope.progress(context).audience) {
    0 => const WelcomeScreen(),
    2 => const LabHome(asRoot: true),
    _ => const HomeScreen(),
  };
}
