import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Thinking before answering: mental arithmetic vs working it out on paper, what the research measured, and
/// "Think or blurt?" for eight everyday questions. Facts THK-* (CoT, DeepSeek-R1, test-time compute), TIER-XAI/AMAZON.
class EThinkingScreen extends StatelessWidget {
  const EThinkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(11);
    return LessonScaffold(
      lessonId: 'e_thinking',
      children: [
        const _OnPaper(),
        const _ThinkOrBlurt(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: 'Effort dial',
                label: 'Amazon\'s Nova 2 Lite lets you set thinking off, low, medium or high',
                factId: 'TIER-AMAZON',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'Configurable',
                label: 'xAI\'s Grok 4.7 also lets you choose how much it reasons',
                factId: 'TIER-XAI',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OnPaper extends StatelessWidget {
  const _OnPaper();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    return DemoCard(
      title: 'In your head, or on paper?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Asked "what\'s 7 × 8?" you just know it. Asked "what\'s 47 × 86?" you reach for paper. A [[model]] writes '
            'one [[token]] at a time, so writing its steps down first is its version of paper: each step becomes '
            'something it can read before the next one.',
          ),
          const SizedBox(height: Gap.m),
          Text('What happened when models showed their work:', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          CompareBars(
            color: accent,
            items: [
              BarItem('2022: math word problems, answer straight away', 17.9, display: '17.9%', color: c.textDim),
              BarItem('…with the steps written out first', 56.9, display: '56.9%', color: accent),
              BarItem('2025: math contest, before reasoning training', 15.6, display: '15.6%', color: c.textDim),
              BarItem('…after it learned to think at length', 77.9, display: '77.9%', color: accent),
            ],
          ),
          const SizedBox(height: Gap.s),
          const TermText(
            'Today\'s "thinking" or "reasoning" models do this by themselves: they write a hidden scratchpad, then the '
            'answer. The price is time and [[tokens|token]]: every step is written out, so you wait longer.',
          ),
          const SizedBox(height: Gap.s),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: '17.9 → 56.9%', label: 'chain of thought, 2022', factId: 'THK-COT'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: '15.6 → 77.9%', label: 'DeepSeek-R1-Zero on AIME', factId: 'THK-R1'),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'Beat a 14× bigger model',
            label: 'extra thinking on problems a small model can partly solve; on the hardest ones, size still wins',
            factId: 'THK-TTC',
          ),
        ],
      ),
    );
  }
}

class _Q {
  const _Q(this.text, this.think, this.why);
  final String text, why;

  /// True = worth thinking first; false = a quick answer is enough.
  final bool think;
}

const _qs = [
  _Q(
    'What\'s the capital of Australia?',
    false,
    'A single fact: either it knows it or it doesn\'t. Thinking just adds a wait.',
  ),
  _Q(
    'Plan a 3-day trip that fits a \$600 budget, with train times that connect.',
    true,
    'Many steps that must all fit together: exactly where working it out pays.',
  ),
  _Q('Give me a synonym for "happy".', false, 'Instant. Nothing to work out.'),
  _Q(
    'A bat and a ball cost \$1.10. The bat costs \$1 more than the ball. What does the ball cost?',
    true,
    'The quick, "obvious" answer (10 cents) is wrong; it\'s 5 cents. Trick questions reward a second look.',
  ),
  _Q('Translate "good morning" into Spanish.', false, '"Buenos días": a lookup, not a puzzle.'),
  _Q(
    'Find the bug: my spreadsheet total is off by exactly 100.',
    true,
    'Debugging means checking one step after another.',
  ),
  _Q('Write a two-line birthday message for my aunt.', false, 'Creative and short; thinking rarely makes it nicer.'),
  _Q(
    'Ana is free 9-11, Ben 10-12, Cy 8-10:30. When can all three meet for half an hour?',
    true,
    'Overlaps across three people: easy to slip in your head, easy on paper. (10:00-10:30.)',
  ),
];

class _ThinkOrBlurt extends StatefulWidget {
  const _ThinkOrBlurt();

  @override
  State<_ThinkOrBlurt> createState() => _ThinkOrBlurtState();
}

class _ThinkOrBlurtState extends State<_ThinkOrBlurt> {
  final _pick = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final right = _pick.entries.where((e) => _qs[e.key].think == e.value).length;
    return DemoCard(
      title: 'Think or blurt?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('For each question, would you switch thinking on?'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _qs.length; i++) ...[
            Text('${i + 1}. ${_qs[i].text}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: Gap.xs),
            Row(
              children: [
                for (final think in [false, true]) ...[
                  if (think) const SizedBox(width: Gap.s),
                  Expanded(
                    child: ChoiceChip(
                      key: ValueKey('think-$i-$think'),
                      avatar: Icon(think ? Icons.psychology_outlined : Icons.bolt, size: 16),
                      label: Text(think ? 'Think first' : 'Quick answer'),
                      selected: _pick[i] == think,
                      selectedColor: (_qs[i].think == think ? accent : c.amber).withValues(alpha: 0.3),
                      onSelected: (_) => setState(() => _pick[i] = think),
                    ),
                  ),
                ],
              ],
            ),
            if (_pick[i] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: Gap.xs),
                child: Text(
                  '${p == _qs[i].think ? 'Yes' : 'Hmm'}: ${_qs[i].why}',
                  key: ValueKey('think-why-$i'),
                  style: TextStyle(color: p == _qs[i].think ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_pick.length == _qs.length)
            Text(
              'Good calls: $right of ${_qs.length}. Rule of thumb: think for puzzles, plans and checking; '
              'answer fast for facts, short writing and quick swaps.',
              key: const ValueKey('think-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
