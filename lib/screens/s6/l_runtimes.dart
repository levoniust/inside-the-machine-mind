import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// The engines: the stack (model file → engine → API → front-end) and a filterable grid of the main local engines,
/// with each one's own description (facts RT-*).
class LRuntimesScreen extends StatelessWidget {
  const LRuntimesScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 'l_runtimes', children: [_Stack(), _Grid()]);
}

class _Stack extends StatelessWidget {
  const _Stack();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    Widget layer(String title, String sub, Color color) => Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Flexible(
            child: Text(
              sub,
              textAlign: TextAlign.right,
              style: AppText.mono.copyWith(fontSize: 11, color: c.textDim),
            ),
          ),
        ],
      ),
    );
    return DemoCard(
      title: 'Four layers between you and the weights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          layer('Front-end: the chat you see', 'Open WebUI, LM Studio chat…', c.cyan),
          layer('API: a common plug', 'OpenAI-compatible HTTP', c.violet),
          layer('Engine: does the math', 'llama.cpp, vLLM, MLX…', accent),
          layer('Model file: the weights', 'GGUF, safetensors, EXL3, MLX', c.amber),
          const SizedBox(height: Gap.s),
          Text(
            'Because most engines speak the same OpenAI-style API, you can swap the engine underneath without changing the chat app on top.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Engine {
  const _Engine(this.name, this.quote, this.format, this.hardware, this.bestFor, this.tags, this.factId);
  final String name, quote, format, hardware, bestFor, factId;
  final Set<String> tags;
}

const _engines = [
  _Engine(
    'llama.cpp',
    '"LLM inference in C/C++"',
    'GGUF',
    'NVIDIA, AMD, Apple, Vulkan, CPU',
    'Maximum control on almost any hardware; mixing GPU and CPU',
    {'mac', 'nvidia', 'cpu', 'tinker'},
    'RT-LLAMACPP',
  ),
  _Engine(
    'Ollama',
    '"Start building with open models"',
    'its library, or import GGUF / safetensors',
    'macOS, Windows, Linux',
    'The easiest start: one command to download and run',
    {'mac', 'nvidia', 'cpu', 'easy'},
    'RT-OLLAMA',
  ),
  _Engine(
    'LM Studio',
    '"with MLX and llama.cpp under the hood"',
    'GGUF and MLX from Hugging Face',
    'Windows, macOS, Linux desktop',
    'A friendly desktop app with a built-in chat and server',
    {'mac', 'nvidia', 'easy'},
    'RT-LMSTUDIO',
  ),
  _Engine(
    'vLLM',
    '"Easy, fast, and cheap LLM serving for everyone"',
    'safetensors (Hugging Face), several quant formats',
    'NVIDIA, AMD, Intel GPUs and more',
    'Serving many users or agents at once',
    {'nvidia', 'serve'},
    'RT-VLLM',
  ),
  _Engine(
    'ExLlamaV3',
    '"running local LLMs on modern consumer GPUs"',
    'EXL3',
    'NVIDIA GPUs',
    'Squeezing the most out of NVIDIA cards, multi-GPU',
    {'nvidia', 'tinker'},
    'RT-EXLLAMA',
  ),
  _Engine(
    'MLX LM',
    '"generating text and fine-tuning … on Apple silicon"',
    'MLX (from Hugging Face)',
    'Apple silicon Macs',
    'Macs, including LoRA fine-tuning',
    {'mac', 'tinker'},
    'RT-MLX',
  ),
];

const _filters = [
  ('all', 'All'),
  ('mac', 'I have a Mac'),
  ('nvidia', 'One NVIDIA GPU'),
  ('cpu', 'CPU only'),
  ('serve', 'Many users'),
  ('easy', 'Easiest start'),
];

class _Grid extends StatefulWidget {
  const _Grid();

  @override
  State<_Grid> createState() => _GridState();
}

class _GridState extends State<_Grid> {
  String _f = 'all';
  int? _open;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'The engines',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (final (id, label) in _filters)
                ChoiceChip(
                  key: ValueKey('rt-filter-$id'),
                  label: Text(label),
                  selected: _f == id,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _f = id),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          for (var i = 0; i < _engines.length; i++)
            Builder(
              builder: (context) {
                final e = _engines[i];
                final match = _f == 'all' || e.tags.contains(_f);
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: match ? 1 : 0.35,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Gap.s),
                    child: InkWell(
                      key: ValueKey('rt-$i'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _open = _open == i ? null : i),
                      child: Container(
                        padding: const EdgeInsets.all(Gap.s),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: match && _f != 'all' ? accent : c.line),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  e.name,
                                  style: AppText.mono.copyWith(fontWeight: FontWeight.w800, color: accent),
                                ),
                                const SizedBox(width: Gap.s),
                                Expanded(child: Text(e.bestFor, style: const TextStyle(fontSize: 13))),
                              ],
                            ),
                            if (_open == i) ...[
                              const SizedBox(height: Gap.xs),
                              Text(
                                'In its own words: ${e.quote}',
                                style: TextStyle(fontStyle: FontStyle.italic, color: c.textDim, fontSize: 13),
                              ),
                              Text('Model files: ${e.format}', style: const TextStyle(fontSize: 13)),
                              Text('Runs on: ${e.hardware}', style: const TextStyle(fontSize: 13)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          Text(
            'Descriptions from each project\'s own README or website, Oct 2026. Tap an engine for details.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
