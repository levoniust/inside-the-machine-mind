import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// How to keep up: why you need filters (the flood of papers), a weekly routine checklist, and the shelf method.
class LKeepUpScreen extends StatelessWidget {
  const LKeepUpScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_keep_up',
    children: [
      FactCard(
        value: '842 papers',
        label: 'in five weekdays, in just one arXiv section on language models (Oct 19-23, 2026)',
        factId: 'KEEP-ARXIV',
      ),
      _Routine(),
    ],
  );
}

const _habits = [
  (
    'Once a week: skim a curated list',
    'A daily or weekly picked list (for example Hugging Face Daily Papers) instead of the raw arXiv flood.',
  ),
  (
    'Read the release notes of your engine',
    'llama.cpp, Ollama or LM Studio changelogs tell you what you can actually use today.',
  ),
  ('Check new models on their model card', 'Size, active parameters, context, licence: the card beats the headlines.'),
  (
    'One paper a month, the shelf way',
    'Skim pass first: abstract, figures, conclusion. Go deeper only if it matters to you.',
  ),
  ('Try it yourself', 'Run a new model on your own three test prompts before believing any leaderboard.'),
  ('Follow a few good communities', 'A local-LLM forum or Discord where people post real measurements, not just hype.'),
];

class _Routine extends StatefulWidget {
  const _Routine();

  @override
  State<_Routine> createState() => _RoutineState();
}

class _RoutineState extends State<_Routine> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(10);
    return DemoCard(
      title: 'A routine that fits in an hour a week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _habits.length; i++)
            CheckboxListTile(
              key: ValueKey('keep-$i'),
              contentPadding: EdgeInsets.zero,
              activeColor: accent,
              value: _done.contains(i),
              onChanged: (v) => setState(() => v == true ? _done.add(i) : _done.remove(i)),
              title: Text(_habits[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(_habits[i].$2),
            ),
          Text(
            '${_done.length} of ${_habits.length} habits ticked',
            key: const ValueKey('keep-count'),
            style: AppText.mono.copyWith(color: accent),
          ),
          const SizedBox(height: Gap.s),
          OutlinedButton.icon(
            key: const ValueKey('keep-shelf'),
            onPressed: () => openLesson(context, 'l_paper_shelf'),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Open the paper shelf'),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'Nobody reads everything. Pick filters you trust, and spend your time on what you will actually use.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
