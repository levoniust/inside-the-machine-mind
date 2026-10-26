import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Prompt, retrieve or train? Three yes/no questions light a path to prompting, RAG or fine-tuning (LoRA);
/// four scenarios answer them for you; a cost ladder compares the three.
class LWhichCustomScreen extends StatelessWidget {
  const LWhichCustomScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_which_custom', children: [_Tree(), _Ladder()]);
}

enum _Pick { prompt, rag, finetune }

const _questions = [
  'Does it need knowledge it doesn\'t have (your documents, recent facts)?',
  'Does it need a new skill, style or output format, every single time?',
];

const _scenarios = [
  ('Answer questions about my company handbook', [true, false]),
  ('Always reply as JSON in my exact format', [false, true]),
  ('Summarise this one article', [false, false]),
  ('Talk like a pirate for a party', [false, false]),
];

class _Tree extends StatefulWidget {
  const _Tree();

  @override
  State<_Tree> createState() => _TreeState();
}

class _TreeState extends State<_Tree> {
  final List<bool?> _a = [null, null];

  _Pick? get _result {
    if (_a[0] == true) return _Pick.rag;
    if (_a[0] == false && _a[1] == true) return _Pick.finetune;
    if (_a[0] == false && _a[1] == false) return _Pick.prompt;
    return null;
  }

  void _answer(int q, bool v) => setState(() {
    _a[q] = v;
    if (q == 0 && v) _a[1] = null; // RAG decided; the second question no longer matters
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final r = _result;
    final (title, body) = switch (r) {
      _Pick.rag => (
        'Retrieval (RAG)',
        'Keep the model as it is and hand it the right pages at question time: your documents are '
            'split into chunks, the closest ones are found and pasted into the prompt. Update the documents, not the model.',
      ),
      _Pick.finetune => (
        'Fine-tune (LoRA)',
        'Teach the behaviour itself with examples, so it happens every time without a long '
            'prompt. A LoRA adapter on a home GPU is usually enough.',
      ),
      _Pick.prompt => (
        'Just prompt it',
        'Write clear instructions (and an example or two) in the prompt or system prompt. '
            'Free, instant and easy to change. Try this first, always.',
      ),
      null => ('', ''),
    };
    Widget q(int i) {
      final enabled = i == 0 || _a[0] == false;
      return Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Padding(
          padding: const EdgeInsets.only(bottom: Gap.s),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${i + 1}. ${_questions[i]}', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: Gap.xs),
              Wrap(
                spacing: Gap.s,
                children: [
                  for (final v in [true, false])
                    ChoiceChip(
                      key: ValueKey('wc-q$i-${v ? 'yes' : 'no'}'),
                      label: Text(v ? 'Yes' : 'No'),
                      selected: _a[i] == v,
                      selectedColor: accent.withValues(alpha: 0.3),
                      onSelected: enabled ? (_) => _answer(i, v) : null,
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return DemoCard(
      title: 'Answer two questions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          q(0),
          q(1),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              for (final p in _Pick.values)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: Gap.s),
                    decoration: BoxDecoration(
                      color: r == p ? accent : c.surfaceHi,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: r == p ? accent : c.line),
                    ),
                    child: Text(
                      switch (p) {
                        _Pick.prompt => 'Prompt',
                        _Pick.rag => 'RAG',
                        _Pick.finetune => 'Fine-tune',
                      },
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w800, color: r == p ? c.bg : c.textDim),
                    ),
                  ),
                ),
            ],
          ),
          if (r != null) ...[
            const SizedBox(height: Gap.s),
            Text(
              title,
              key: const ValueKey('wc-result'),
              style: TextStyle(fontWeight: FontWeight.w800, color: accent),
            ),
            const SizedBox(height: 4),
            Text(body),
          ],
          const SizedBox(height: Gap.m),
          Text('Or try a scenario:', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var i = 0; i < _scenarios.length; i++)
                ActionChip(
                  key: ValueKey('wc-scenario-$i'),
                  label: Text(_scenarios[i].$1),
                  onPressed: () => setState(() {
                    _a[0] = _scenarios[i].$2[0];
                    _a[1] = _scenarios[i].$2[0] ? null : _scenarios[i].$2[1];
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Ladder extends StatelessWidget {
  const _Ladder();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const rows = [
      (
        'Prompt',
        'minutes',
        'nothing but your words',
        'The model forgets it next chat unless it is in the system prompt',
      ),
      ('RAG', 'hours', 'your documents + an embedding model', 'Answers only as good as the passages it finds'),
      ('Fine-tune', 'days', 'hundreds+ of good examples + a GPU', 'Changes behaviour, but is a poor way to add facts'),
    ];
    return DemoCard(
      title: 'What each one costs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.section(7).withValues(alpha: 0.2 + 0.25 * i),
                    ),
                    child: Text('${i + 1}', style: AppText.mono.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${rows[i].$1} · ${rows[i].$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text('Needs: ${rows[i].$3}', style: const TextStyle(fontSize: 13)),
                        Text('Catch: ${rows[i].$4}', style: TextStyle(fontSize: 13, color: c.textDim)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Text(
            'Climb the ladder only as far as you need: most problems are solved on the first rung.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
