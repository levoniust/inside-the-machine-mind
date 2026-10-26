import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Teaching by example: the exact Llama 3.1 chat template as tappable blocks (verified from its tokenizer_config.json),
/// one JSONL training row, and "spot the bad example".
class LDatasetsScreen extends StatelessWidget {
  const LDatasetsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_datasets', children: [_Template(), _Jsonl(), _SpotBad()]);
}

class _Block {
  const _Block(this.label, this.raw, this.kind);
  final String label, raw;
  final int kind; // 0 special token, 1 system, 2 user, 3 assistant
}

const _blocks = [
  _Block('start of text', '<|begin_of_text|>', 0),
  _Block('system header', '<|start_header_id|>system<|end_header_id|>\n\n', 0),
  _Block('system text', 'You are a helpful assistant who answers in one short paragraph.', 1),
  _Block('end of turn', '<|eot_id|>', 0),
  _Block('user header', '<|start_header_id|>user<|end_header_id|>\n\n', 0),
  _Block('user text', 'Why is the sky blue?', 2),
  _Block('end of turn', '<|eot_id|>', 0),
  _Block('assistant header', '<|start_header_id|>assistant<|end_header_id|>\n\n', 0),
  _Block('assistant text', 'Sunlight is scattered by the air, and blue light scatters the most…', 3),
  _Block('end of turn', '<|eot_id|>', 0),
];

class _Template extends StatefulWidget {
  const _Template();

  @override
  State<_Template> createState() => _TemplateState();
}

class _TemplateState extends State<_Template> {
  int _sel = 5;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Color col(int k) => [c.textDim, c.violet, c.cyan, c.section(7)][k];
    return DemoCard(
      title: 'What the model actually sees (Llama 3.1)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (var i = 0; i < _blocks.length; i++)
                InkWell(
                  key: ValueKey('tpl-$i'),
                  onTap: () => setState(() => _sel = i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: col(_blocks[i].kind).withValues(alpha: i == _sel ? 0.4 : 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: col(_blocks[i].kind)),
                    ),
                    child: Text(_blocks[i].label, style: const TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: Text(
              _blocks[_sel].raw.replaceAll('\n', '↵'),
              key: const ValueKey('tpl-raw'),
              style: AppText.mono.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Grey blocks are special tokens the model learned as markers. Every model family has its own template; '
            'feeding a model the wrong one quietly makes its answers worse.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _Jsonl extends StatelessWidget {
  const _Jsonl();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'One training example (one line of JSONL)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: Text(
              '{"messages": [\n'
              '  {"role": "system", "content": "Answer as a friendly bike mechanic."},\n'
              '  {"role": "user", "content": "My chain keeps slipping."},\n'
              '  {"role": "assistant", "content": "Usually a worn chain or cassette. Check the chain with a wear gauge first…"}\n'
              ']}',
              style: AppText.mono.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'A fine-tuning dataset is hundreds or thousands of lines like this. The training tool wraps each one in the '
            'model\'s chat template, and the model learns to write the assistant part.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SpotBad extends StatefulWidget {
  const _SpotBad();

  @override
  State<_SpotBad> createState() => _SpotBadState();
}

class _SpotBadState extends State<_SpotBad> {
  static const _rows = [
    (
      'user: "How do I fix a flat tyre?"',
      'assistant: "Remove the wheel, lever the tyre off, find the hole, patch or replace the tube, refit."',
    ),
    (
      'user: "How tight should my pedals be?"',
      'assistant: "As tight as you can possibly make them, the tighter the better."',
    ),
    ('user: "What does a derailleur do?"', 'assistant: "It moves the chain between gears when you shift."'),
  ];
  static const _bad = 1;
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Spot the bad training example',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: InkWell(
                key: ValueKey('bad-$i'),
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _picked = i),
                child: Container(
                  padding: const EdgeInsets.all(Gap.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _picked != null && i == _bad ? c.red : (_picked == i ? c.amber : c.line)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_rows[i].$1, style: AppText.mono.copyWith(fontSize: 12)),
                      Text(_rows[i].$2, style: AppText.mono.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          if (_picked != null)
            Text(
              _picked == _bad
                  ? 'Right. Over-tightening pedals damages threads; a model trained on this would learn to give wrong advice confidently.'
                  : 'That one is fine. Look again: one answer is confidently wrong, and the model would learn it.',
              key: const ValueKey('bad-result'),
              style: TextStyle(fontWeight: FontWeight.w700, color: _picked == _bad ? c.lime : c.amber),
            ),
          const SizedBox(height: Gap.xs),
          Text(
            'Garbage in, garbage out: a few bad rows teach mistakes as faithfully as good rows teach skills.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
