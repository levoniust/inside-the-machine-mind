import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Health, money and legal questions: a well-read friend vs your doctor, and "Ask it or ask a person?" for eight
/// situations. Facts ADV-* (WHO guidance, Anthropic's usage policy).
class EAdviceScreen extends StatelessWidget {
  const EAdviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(5);
    return LessonScaffold(
      lessonId: 'e_advice',
      children: [
        const _Friend(),
        const _AskWho(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: 'Automation bias',
                label: 'trusting the AI so much that you stop catching its mistakes',
                factId: 'ADV-WHO-AUTOMATION',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'High-risk',
                label: 'legal, medical and money advice, in Anthropic\'s own rules for businesses',
                factId: 'ADV-AUP',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Friend extends StatelessWidget {
  const _Friend();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    Widget col(IconData icon, String title, List<String> items, Color color) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(Gap.s),
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            for (final i in items)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $i', style: const TextStyle(fontSize: 13)),
              ),
          ],
        ),
      ),
    );
    return DemoCard(
      title: 'A well-read friend, not your doctor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'A chatbot is like a friend who has read a lot: great for explaining words and helping you prepare. But it '
            'hasn\'t examined you, seen your papers or your contract, and it can sound sure while being wrong '
            '([[hallucination]]).',
          ),
          const SizedBox(height: Gap.s),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                col(Icons.thumb_up_alt_outlined, 'Good for', const [
                  'explaining a word or a form',
                  'listing questions to ask',
                  'summarizing a long letter',
                  'practising a hard conversation',
                ], accent),
                const SizedBox(width: Gap.s),
                col(Icons.person_outline, 'Ask a person', const [
                  'diagnosis, or changing a medicine',
                  'what to do in your legal case',
                  'where to put your savings',
                  'anything urgent',
                ], c.amber),
              ],
            ),
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'False, biased, incomplete',
            label: 'documented risks of AI answers about health, says the WHO',
            factId: 'ADV-WHO-RISK',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

enum _Who { ai, prepare, person }

class _Case {
  const _Case(this.text, this.best, this.why);
  final String text, why;
  final _Who best;
}

const _cases = [
  _Case(
    'What does "HbA1c" mean on my blood test?',
    _Who.ai,
    'Explaining a term is what it\'s good at. Still ask your doctor what YOUR number means.',
  ),
  _Case(
    'I have chest pain and my left arm feels numb, right now.',
    _Who.person,
    'Possible emergency: call emergency services. Don\'t type, don\'t wait.',
  ),
  _Case('What does "adjusted gross income" mean on my tax form?', _Who.ai, 'A definition: fine to ask.'),
  _Case(
    'Should I claim my spare room as a home office on my taxes?',
    _Who.prepare,
    'Advice on your own taxes is high-risk: use the AI to understand the rules, then check with a tax pro.',
  ),
  _Case(
    'My landlord kept my deposit. What are my rights?',
    _Who.prepare,
    'Rules differ by place. Let it explain the basics and draft questions, then ask a legal aid office or tenant group.',
  ),
  _Case(
    'I feel fine. Can I stop my blood pressure pills?',
    _Who.person,
    'Changing a medicine is a decision for your doctor, never a chatbot.',
  ),
  _Case(
    'Help me list questions to ask the surgeon about my knee.',
    _Who.ai,
    'Preparing for the appointment is a great use.',
  ),
  _Case(
    'Which crypto fund should I move my savings into?',
    _Who.person,
    'A personal investment pick is high-risk advice. Talk to a licensed adviser.',
  ),
];

class _AskWho extends StatefulWidget {
  const _AskWho();

  @override
  State<_AskWho> createState() => _AskWhoState();
}

class _AskWhoState extends State<_AskWho> {
  final _pick = <int, _Who>{};

  static const _labels = {
    _Who.ai: 'Ask the AI',
    _Who.prepare: 'AI to prepare, person decides',
    _Who.person: 'Ask a person',
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final right = _pick.entries.where((e) => _cases[e.key].best == e.value).length;
    return DemoCard(
      title: 'Ask it or ask a person?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _cases.length; i++) ...[
            Text('${i + 1}. ${_cases[i].text}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final w in _Who.values)
                  ChoiceChip(
                    key: ValueKey('adv-$i-${w.name}'),
                    label: Text(_labels[w]!),
                    selected: _pick[i] == w,
                    selectedColor: (_cases[i].best == w ? accent : c.amber).withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _pick[i] = w),
                  ),
              ],
            ),
            if (_pick[i] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${p == _cases[i].best ? 'Yes' : 'Better: "${_labels[_cases[i].best]}"'}. ${_cases[i].why}',
                  key: ValueKey('adv-why-$i'),
                  style: TextStyle(color: p == _cases[i].best ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_pick.length == _cases.length)
            Text(
              'Good calls: $right of ${_cases.length}. Use it to understand and prepare; let a qualified person make '
              'the call on your body, your case and your money.',
              key: const ValueKey('adv-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'Symptoms',
            label: 'looking into symptoms is one of five uses the WHO expects',
            factId: 'ADV-WHO-USES',
          ),
        ],
      ),
    );
  }
}
