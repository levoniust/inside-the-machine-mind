import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 5 · Lesson 5: AI at school and work.
/// A sorting game: eight scenario cards, each with a "Fine", "Depends — check the rules"
/// or "Not OK" pile. One card at a time, three buttons, feedback per pick, then the next
/// card. Ends with a score and three habits.
class ESchoolWorkScreen extends StatelessWidget {
  const ESchoolWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      lessonId: 'e_school_work',
      children: [
        DemoCard(
          title: 'Sort the scenarios',
          child: const _SortingGame(),
        ),
        const _HabitCards(),
      ],
    );
  }
}

enum _Pile { fine, depends, notOk }

class _Scenario {
  const _Scenario(this.text, this.pile, this.why);
  final String text;
  final _Pile pile;
  final String why;
}

const _scenarios = [
  _Scenario('Ask AI to explain a maths step you\'re stuck on', _Pile.fine,
      'It helps you understand your own thinking — you still did the work.'),
  _Scenario('Paste the whole essay question and hand in the answer', _Pile.notOk,
      'You handed in someone else\'s thinking instead of your own.'),
  _Scenario('Use it to draft, then rewrite in your own words and say so', _Pile.depends,
      'Helpful if the rules allow it — but you must say you used it.'),
  _Scenario('Paste customer data into a public chatbot', _Pile.notOk,
      'Customer details would go to an outside company\'s servers, which can break privacy law and your contract.'),
  _Scenario('Ask for practice quiz questions before a test', _Pile.fine,
      'Practising with extra questions is studying, not cheating.'),
  _Scenario('Use it to translate an email to a colleague', _Pile.depends,
      'Usually fine, but check your workplace rules about pasting work text into AI apps.'),
  _Scenario('Let it write your job application\'s personal statement', _Pile.depends,
      'It can draft, but you must make it sound like you.'),
  _Scenario('Ask it to check grammar on your own text', _Pile.fine,
      'You wrote it; it just polished the words.'),
];

class _SortingGame extends StatefulWidget {
  const _SortingGame();

  @override
  State<_SortingGame> createState() => _SortingGameState();
}

class _SortingGameState extends State<_SortingGame> {
  int _index = 0;
  int _score = 0;
  _Pile? _picked; // the pile the user chose for the current card
  bool _showScore = false;

  _Scenario get _card => _scenarios[_index];

  void _pick(_Pile pile) {
    if (_picked != null) return;
    setState(() {
      _picked = pile;
      if (pile == _card.pile) _score++;
    });
  }

  void _next() {
    setState(() {
      _picked = null;
      _index++;
      _showScore = _index >= _scenarios.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    if (_showScore) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PileRow(label: 'Fine', count: _count(_Pile.fine), color: c.lime),
          const SizedBox(height: Gap.s),
          _PileRow(label: 'Depends — check the rules', count: _count(_Pile.depends), color: c.amber),
          const SizedBox(height: Gap.s),
          _PileRow(label: 'Not OK', count: _count(_Pile.notOk), color: c.red),
          const SizedBox(height: Gap.l),
          Center(
            child: Text('You got $_score of ${_scenarios.length} right.',
                style: AppText.mono.copyWith(fontSize: 18, fontWeight: FontWeight.w800, color: accent)),
          ),
          const SizedBox(height: Gap.m),
          Center(
            child: OutlinedButton(
              key: const ValueKey('sort-restart'),
              onPressed: () => setState(() {
                _index = 0;
                _score = 0;
                _picked = null;
                _showScore = false;
              }),
              child: const Text('Sort again'),
            ),
          ),
        ],
      );
    }

    final card = _card;
    final picked = _picked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Card ${_index + 1} of ${_scenarios.length}',
            textAlign: TextAlign.center,
            style: AppText.mono.copyWith(fontSize: 12, color: c.textDim)),
        const SizedBox(height: Gap.s),
        Semantics(
          label: 'Scenario card: ${card.text}',
          child: Container(
            padding: const EdgeInsets.all(Gap.l),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.line),
            ),
            child: Text(card.text,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
        ),
        const SizedBox(height: Gap.l),
        if (picked == null) ...[
          Row(
            children: [
              Expanded(child: _pileButton(c, _Pile.fine, 'Fine')),
              const SizedBox(width: Gap.s),
              Expanded(child: _pileButton(c, _Pile.depends, 'Depends: check the rules')),
              const SizedBox(width: Gap.s),
              Expanded(child: _pileButton(c, _Pile.notOk, 'Not OK')),
            ],
          ),
        ] else ...[
          _feedback(c, card, picked),
          const SizedBox(height: Gap.m),
          Center(
            child: FilledButton(
              key: const ValueKey('sort-next'),
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: _next,
              child: Text(_index + 1 >= _scenarios.length ? 'See the result' : 'Next card'),
            ),
          ),
        ],
      ],
    );
  }

  int _count(_Pile pile) =>
      _scenarios.where((s) => s.pile == pile).length;

  Widget _pileButton(AppColors c, _Pile pile, String label) {
    final color = switch (pile) {
      _Pile.fine => c.lime,
      _Pile.depends => c.amber,
      _Pile.notOk => c.red,
    };
    return OutlinedButton(
      key: ValueKey('sort-$pile'),
      style: OutlinedButton.styleFrom(foregroundColor: color),
      onPressed: () => _pick(pile),
      child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
    );
  }

  Widget _feedback(AppColors c, _Scenario card, _Pile picked) {
    final correct = picked == card.pile;
    final color = correct ? c.lime : c.red;
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.close, color: color, size: 20),
              const SizedBox(width: Gap.xs),
              Expanded(
                child: Text(
                  correct ? 'Right pile.' : 'Wrong pile — the right pile is "${_pileName(card.pile)}."',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(card.why, style: TextStyle(color: c.textDim)),
        ],
      ),
    );
  }
}

String _pileName(_Pile pile) => switch (pile) {
  _Pile.fine => 'Fine',
  _Pile.depends => 'Depends — check the rules',
  _Pile.notOk => 'Not OK',
};

class _PileRow extends StatelessWidget {
  const _PileRow({required this.label, required this.count, required this.color});
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text('$count', style: AppText.mono.copyWith(color: color, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

/// The three habits to keep after the last card is sorted.
class _HabitCards extends StatelessWidget {
  const _HabitCards();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    return DemoCard(
      title: 'Three habits to keep',
      child: Column(
        children: [
          _habit(c, 'Check the rules first', 'Before you use AI, find out what is allowed — at school, at work, or for a contract.', Icons.rule, accent),
          const SizedBox(height: Gap.s),
          _habit(c, 'Say when you used it', 'If AI helped, tell the person who reads your work. Honesty keeps it a partner, not a secret.', Icons.chat_bubble_outline, accent),
          const SizedBox(height: Gap.s),
          _habit(c, 'You\'re responsible for what you hand in', 'If it goes out the door, it\'s yours — check it, own it, and stand by it.', Icons.check_box, accent),
        ],
      ),
    );
  }

  Widget _habit(AppColors c, String title, String body, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: c.surfaceHi,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: Gap.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(color: c.textDim, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
