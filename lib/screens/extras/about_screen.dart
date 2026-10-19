import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(Gap.l),
              children: [
                const Center(child: BitAvatar(size: 96, mood: BitMood.happy)),
                const SizedBox(height: Gap.l),
                Text('Inside the Machine Mind', style: t.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: Gap.s),
                Text(
                  'An interactive journey through how large language models are built: the hardware they live on, '
                  'how they are trained, and how they answer. Free, offline, open source (MIT).',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textDim),
                ),
                const SizedBox(height: Gap.xl),
                Text('Credits', style: t.titleLarge),
                const SizedBox(height: Gap.s),
                const Text('Built with Flutter. Facts are cited on the Sources page; numbers were checked in October 2026 '
                    'and the field moves fast.'),
                const SizedBox(height: Gap.s),
                const Text('Gallery images were generated with Qwen-Image 2.1 (Qwen Research License, non-commercial).'),
                const SizedBox(height: Gap.xl),
                Container(
                  padding: const EdgeInsets.all(Gap.l),
                  decoration: BoxDecoration(
                    color: c.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.amber.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'Psst… Bit gets excited when you tap it a lot. And some chips on the home board do more than blink.',
                    style: TextStyle(color: c.amber),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                Center(child: Text('github.com/levoniust/inside-the-machine-mind', style: TextStyle(color: c.textDim))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
