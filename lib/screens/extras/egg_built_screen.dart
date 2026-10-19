import 'package:flutter/material.dart';

/// Easter egg 1: "How This App Was Built". Filled with real build stats at the end of the project.
class EggBuiltScreen extends StatelessWidget {
  const EggBuiltScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Bit\'s secret logbook')),
        body: const Center(child: Text('How this app was built: coming soon.')),
      );
}
