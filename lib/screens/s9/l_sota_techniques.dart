import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Tricks everyone uses now: flip cards, each with what it is, where you see it and the paper behind it.
class LSotaTechniquesScreen extends StatelessWidget {
  const LSotaTechniquesScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_sota_techniques',
    children: [
      _Cards(),
      FactCard(
        value: 'MoE + ~1M tokens',
        label: 'the shape of almost every big open-weight release in 2026',
        factId: 'SOTA-OPEN-TREND',
      ),
    ],
  );
}

const _tricks = [
  (
    'Thinking before answering',
    'Reasoning models write a long hidden chain of thought, check themselves and only then answer: '
        'they spend compute at answer time instead of only in training.',
    'The "thinking" modes in chat apps; open models with a <think> section.',
    'DeepSeek-R1; test-time compute scaling',
  ),
  (
    'Mixture of experts everywhere',
    'Huge total size, small active part: a router sends each token to a few experts. Big knowledge, '
        'moderate cost per token.',
    'Nearly every large open-weight model of 2026 (DeepSeek, Qwen, Kimi, GLM).',
    'Mixtral; DeepSeek-V3',
  ),
  (
    'Million-token context',
    'Whole codebases or books in one prompt, thanks to cheaper attention and smarter KV caches.',
    'Gemini 4 Argon, DeepSeek-V4.1, Qwen3.8 and Kimi K3 all reach about a million tokens.',
    'FlashAttention; YaRN; KIVI',
  ),
  (
    'Guess ahead, check fast',
    'Draft heads or a small draft model propose several tokens; the big model checks them in one pass.',
    'Multi-token-prediction (MTP) heads in DeepSeek and Qwen models; llama.cpp and vLLM use them.',
    'Speculative decoding; Medusa; DeepSeek-V3',
  ),
  (
    'Fewer bits',
    '8-bit and 4-bit numbers for training and serving, not just for home users. Less memory, more speed.',
    'FP8 training, FP4 formats on new datacenter chips, GGUF quants at home.',
    'GPTQ; AWQ; QLoRA; DeepSeek-V3',
  ),
  (
    'Agents with tools',
    'Models that plan, call tools (search, code, files) and read the results in a loop, often through the '
        'Model Context Protocol (MCP).',
    'Coding agents, "computer use", assistants that browse and act.',
    'ReAct; Toolformer',
  ),
];

class _Cards extends StatefulWidget {
  const _Cards();

  @override
  State<_Cards> createState() => _CardsState();
}

class _CardsState extends State<_Cards> {
  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(9);
    return DemoCard(
      title: 'Six tricks, one tap each',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _tricks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: InkWell(
                key: ValueKey('trick-$i'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(Gap.s),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: _open.contains(i) ? 0.12 : 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_tricks[i].$1, style: const TextStyle(fontWeight: FontWeight.w800)),
                      if (_open.contains(i)) ...[
                        const SizedBox(height: 4),
                        Text(_tricks[i].$2),
                        const SizedBox(height: 4),
                        Text('Where you see it: ${_tricks[i].$3}', style: const TextStyle(fontSize: 13)),
                        Text('On the paper shelf: ${_tricks[i].$4}', style: TextStyle(fontSize: 13, color: c.textDim)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
