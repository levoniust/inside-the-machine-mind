import 'package:flutter/material.dart';

/// Easter egg 2: "The 3060 Gallery". Images generated on Vault's RTX 3060.
class EggGalleryScreen extends StatelessWidget {
  const EggGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('The 3060 Gallery')),
        body: const Center(child: Text('Gallery: coming soon.')),
      );
}
