import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Why answers can lean one way: a student who learned from one town's library, "Spot the lean" (five pairs of
/// example answers, one slanted), and how researchers and makers measure it. Facts BIAS-* (BBQ, Winogender).
class EBiasScreen extends StatelessWidget {
  const EBiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(5);
    return LessonScaffold(
      lessonId: 'e_bias',
      children: [
        const _Library(),
        const _SpotTheLean(),
        const _Measured(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '~77%',
                label: 'of one model\'s mistakes on unclear questions matched the stereotype',
                factId: 'BIAS-BBQ-77',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '720',
                label: 'sentences that differ only by "he", "she" or "they", to catch gender bias',
                factId: 'BIAS-WINOGENDER',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Library extends StatelessWidget {
  const _Library();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: 'A student from one town\'s library',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'Picture a student who learned everything from one town\'s library. If most books there show surgeons as '
            'men and nurses as women, the student will guess that way, even when nothing in the question says so.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'A [[model]] learns from a huge pile of human writing, so it picks up our habits too, the unfair ones '
            'included. It shows most when a question leaves something open and the model fills the gap with a '
            'stereotype.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'Try the classic riddle: a father and son are in a crash; the father dies, and at the hospital the surgeon '
            'says "I can\'t operate on this boy, he\'s my son!" How? **The surgeon is his mother.** Many people get '
            'stuck. So do models.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Pair {
  const _Pair(this.ask, this.a, this.b, this.leanIsA, this.why);
  final String ask, a, b, why;
  final bool leanIsA;
}

const _pairs = [
  _Pair(
    'Describe a nurse and an engineer starting their shift.',
    'The nurse checks the overnight charts while the engineer reviews the test results.',
    'She checks the overnight charts while he reviews the test results.',
    false,
    'Nothing said the nurse is a woman or the engineer a man. The model filled the gap from habit.',
  ),
  _Pair(
    'A 22-year-old and a 78-year-old were setting up a new phone. Who was bad with technology?',
    'The 78-year-old, probably.',
    'There\'s no way to tell from this.',
    true,
    'The question gives no clue. Guessing by age is exactly what the BBQ test catches.',
  ),
  _Pair(
    'Two identical résumés: Alex is 55, Jordan is 24. Who is the better programmer?',
    'The résumés are identical, so there\'s no basis to pick one.',
    'Jordan: younger people pick up new tools faster.',
    false,
    'Same résumé, same answer. Age wasn\'t part of the skills.',
  ),
  _Pair(
    'My neighbours, one from Sweden and one from Mexico, both got new cars. Who took out a loan?',
    'Can\'t tell; nothing here says how either paid.',
    'Probably the neighbour from Mexico.',
    false,
    'Nationality says nothing about how someone pays for a car.',
  ),
  _Pair(
    'My friend is a stay-at-home parent. Gift ideas?',
    'A spa day would let her relax.',
    'What do they enjoy? A favourite hobby or a night off are good starts.',
    true,
    'The friend could be anyone. "Her" was an assumption.',
  ),
];

class _SpotTheLean extends StatefulWidget {
  const _SpotTheLean();

  @override
  State<_SpotTheLean> createState() => _SpotTheLeanState();
}

class _SpotTheLeanState extends State<_SpotTheLean> {
  final _pick = <int, bool>{}; // true = picked answer A as the slanted one

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final right = _pick.entries.where((e) => e.value == _pairs[e.key].leanIsA).length;
    Widget answer(int i, bool isA) {
      final p = _pairs[i];
      final picked = _pick[i] == isA;
      final lean = p.leanIsA == isA;
      final shown = _pick.containsKey(i);
      return Expanded(
        child: InkWell(
          key: ValueKey('bias-$i-${isA ? 'a' : 'b'}'),
          onTap: shown ? null : () => setState(() => _pick[i] = isA),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(
              color: shown && lean ? c.amber.withValues(alpha: 0.15) : null,
              border: Border.all(color: picked ? (lean ? accent : c.red) : c.line, width: picked ? 2 : 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isA ? 'A' : 'B',
                  style: TextStyle(color: c.textDim, fontWeight: FontWeight.w800, fontSize: 12),
                ),
                Text(isA ? p.a : p.b, style: const TextStyle(fontSize: 13)),
                if (shown && lean)
                  Text(
                    'slanted',
                    style: TextStyle(color: c.amber, fontSize: 11, fontWeight: FontWeight.w800),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return DemoCard(
      title: 'Spot the lean',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Two example answers to each question. Tap the one that leans on a stereotype.'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _pairs.length; i++) ...[
            Text('${i + 1}. ${_pairs[i].ask}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  answer(i, true),
                  const SizedBox(width: Gap.s),
                  answer(i, false),
                ],
              ),
            ),
            if (_pick[i] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${p == _pairs[i].leanIsA ? 'Spotted' : 'Missed it'}: ${_pairs[i].why}',
                  key: ValueKey('bias-why-$i'),
                  style: TextStyle(color: p == _pairs[i].leanIsA ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_pick.length == _pairs.length)
            Text(
              'Spotted $right of ${_pairs.length}. The tell: the slanted answer adds a detail (gender, age, '
              'nationality) the question never gave, or "knows" something that couldn\'t be known.',
              key: const ValueKey('bias-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}

class _Measured extends StatelessWidget {
  const _Measured();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    return DemoCard(
      title: 'How it\'s measured, and what you can do',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Researchers build tests like BBQ: tens of thousands of questions where the honest answer is often '
            '"can\'t tell". Model makers run them and publish the scores, and use human feedback ([[RLHF]]) to train '
            'the lean down. It shrinks; it doesn\'t vanish.',
          ),
          const SizedBox(height: Gap.s),
          Text('Your part:', style: TextStyle(color: c.textDim)),
          for (final t in const [
            'Notice when an answer adds a gender, age or origin you never mentioned.',
            'Ask "what if they were older / a man / from somewhere else?" and compare.',
            'For decisions about people (hiring, renting, grading), don\'t let a chatbot decide.',
          ])
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Expanded(child: Text(t)),
                ],
              ),
            ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: '58,492',
            label: 'questions in the BBQ bias test, across nine areas',
            factId: 'BIAS-BBQ',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: '+3.4 points',
            label: 'more accurate when the right answer matched a stereotype',
            factId: 'BIAS-BBQ-ALIGN',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(value: 'Published', label: 'makers report bias scores in their papers', factId: 'BIAS-MAKERS'),
        ],
      ),
    );
  }
}
