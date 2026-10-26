import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Who makes what: the AI industry as a stack of layers, from chip factories up to the apps; tap a layer for its players.
class LWhoMakesScreen extends StatelessWidget {
  const LWhoMakesScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_who_makes',
    children: [
      _Stack(),
      FactCard(
        value: '534 customers',
        label: 'TSMC, the first dedicated chip foundry, only builds chips others design',
        factId: 'IND-TSMC',
      ),
      FactCard(value: '9,216 chips', label: 'in one pod of Google\'s own AI chip, the Ironwood TPU', factId: 'IND-TPU'),
    ],
  );
}

const _layers = [
  (
    'Apps',
    'ChatGPT, Claude, Gemini, Meta AI, Copilot, and thousands of products built on their APIs or on open models.',
  ),
  (
    'Open-source tools',
    'The engines and front-ends anyone can run: llama.cpp, Ollama, vLLM, MLX, Open WebUI, Hugging Face libraries.',
  ),
  (
    'Model makers',
    'Closed frontier labs (OpenAI, Anthropic, Google, Meta) and open-weight publishers (DeepSeek, Alibaba Qwen, Moonshot, Zhipu, Google Gemma).',
  ),
  (
    'Clouds and datacenters',
    'Where the GPUs live and are rented by the hour: the big clouds (Amazon, Microsoft, Google) and specialist GPU clouds.',
  ),
  (
    'Chip designers',
    'NVIDIA and AMD sell AI chips to everyone; Google (TPU) and Amazon (Trainium) also design their own for their clouds; Apple designs the chips in Macs.',
  ),
  (
    'Chip factories',
    'Designing a chip is not making it. Foundries such as TSMC manufacture the chips that other companies design.',
  ),
];

class _Stack extends StatefulWidget {
  const _Stack();

  @override
  State<_Stack> createState() => _StackState();
}

class _StackState extends State<_Stack> {
  int _sel = 4;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(10);
    return DemoCard(
      title: 'The AI industry, layer by layer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _layers.length; i++)
            GestureDetector(
              key: ValueKey('layer-$i'),
              onTap: () => setState(() => _sel = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 6.0 * i, vertical: 2),
                padding: const EdgeInsets.symmetric(vertical: Gap.s, horizontal: Gap.m),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: i == _sel ? 0.45 : 0.08 + 0.05 * i),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accent.withValues(alpha: 0.6)),
                ),
                child: Text(
                  _layers[i].$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          const SizedBox(height: Gap.m),
          Text(_layers[_sel].$2, key: const ValueKey('layer-desc')),
          const SizedBox(height: Gap.xs),
          Text(
            'Each layer depends on the one below it: no apps without models, no models without datacenters, no datacenters without chips.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
