import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 5 · Lesson 2: Asking well.
///
/// A "before / after" prompt builder. The user starts from the laziest request
/// ("write an email") and toggles chips that add detail. The mock answer card
/// changes as chips are added (pre-written answers, no live AI). A second card
/// is a checklist of three tips.
class EAskingScreen extends StatefulWidget {
  const EAskingScreen({super.key});

  @override
  State<EAskingScreen> createState() => _EAskingScreenState();
}

class _EAskingScreenState extends State<EAskingScreen> {
  final Set<_Chip> _selected = <_Chip>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    return LessonScaffold(
      lessonId: 'e_asking',
      children: [
        _PromptBuilder(
          accent: accent,
          selected: _selected,
          onToggle: (chip) {
            setState(() {
              if (_selected.contains(chip)) {
                _selected.remove(chip);
              } else {
                _selected.add(chip);
              }
            });
          },
        ),
        const _ChecklistCard(),
      ],
    );
  }
}

/// A toggleable detail chip.
class _Chip {
  const _Chip(this.id, this.label);
  final String id;
  final String label;
}

const _kChips = <_Chip>[
  _Chip('audience', "Who it's for"),
  _Chip('goal', 'Goal'),
  _Chip('tone', 'Tone'),
  _Chip('length', 'Length'),
  _Chip('example', 'An example'),
  _Chip('avoid', 'What to avoid'),
];

/// The prompt text being built above the answer.
String _promptFor(Set<_Chip> selected) {
  final base = 'Write an email';
  if (selected.isEmpty) return base;
  final parts = <String>[base];
  for (final chip in _kChips) {
    if (selected.contains(chip)) {
      parts.add(_chipClause(chip));
    }
  }
  return parts.join(', ');
}

String _chipClause(_Chip chip) => switch (chip.id) {
  'audience' => 'for my manager',
  'goal' => 'to get a meeting this week',
  'tone' => 'in a warm, professional tone',
  'length' => 'in two short paragraphs',
  'example' => 'like the last email I sent you',
  'avoid' => 'without jargon or exclamation marks',
  _ => '',
};

/// The mock answer is assembled from the chips that are on, so each detail visibly changes it.
/// (Pre-written pieces, no live AI and no facts.)
String _answerFor(Set<_Chip> selected) {
  bool on(String id) => selected.any((c) => c.id == id);
  final subject = on('goal') ? 'Subject: 20 minutes this week?' : 'Subject: Quick note';
  final hello = on('audience') ? 'Hi Sam,' : 'Hi there,';
  final warm = on('tone') ? 'I hope your week is going well. ' : '';
  final ask = on('goal')
      ? 'Could we meet for a short chat this week to plan the next steps? Thursday or Friday morning would suit me.'
      : (on('avoid')
            ? 'I wanted to get in touch about the project.'
            : 'Just circling back to touch base and leverage some synergies on the project!!');
  final example = on('example') ? 'Like last time: summary first, then the question.\n\n' : '';
  final body = on('length')
      ? '$example$warm$ask\n\nLet me know what works for you.'
      : '$example$warm$ask Let me know what you think, any feedback is welcome, and also happy to discuss other things '
            'if anything else comes up on your side, no rush at all${on('avoid') ? '.' : '!!'}';
  final bye = on('tone') ? 'Warm regards,\nAlex' : 'Thanks,\nAlex';
  return '$subject\n\n$hello\n\n$body\n\n$bye';
}

class _PromptBuilder extends StatelessWidget {
  const _PromptBuilder({required this.accent, required this.selected, required this.onToggle});

  final Color accent;
  final Set<_Chip> selected;
  final void Function(_Chip) onToggle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prompt = _promptFor(selected);
    final answer = _answerFor(selected);
    return DemoCard(
      title: 'Ask it to be more specific',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Start with the laziest request — "write an email." Tap the chips to add detail. The preview answer below changes as you go.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          // The prompt being built.
          Container(
            padding: const EdgeInsets.all(Gap.m),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.edit_note, size: 18, color: accent),
                const SizedBox(width: Gap.s),
                Expanded(
                  child: Text(prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.m),
          // The chips.
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (final chip in _kChips)
                _ChipButton(
                  chip: chip,
                  selected: selected.contains(chip),
                  accent: accent,
                  onToggle: () => onToggle(chip),
                ),
            ],
          ),
          const SizedBox(height: Gap.l),
          // The mock answer.
          _AnswerCard(accent: accent, answer: answer, count: selected.length),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({required this.chip, required this.selected, required this.accent, required this.onToggle});

  final _Chip chip;
  final bool selected;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = selected ? accent : c.line;
    final bg = selected ? accent.withValues(alpha: 0.12) : c.surfaceHi;
    return GestureDetector(
      key: ValueKey('chip-${chip.id}'),
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? Icons.check : Icons.add, size: 14, color: selected ? accent : c.textDim),
            const SizedBox(width: 4),
            Text(chip.label, style: TextStyle(color: selected ? accent : c.text, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({required this.accent, required this.answer, required this.count});

  final Color accent;
  final String answer;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.l),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.email_outlined, size: 18, color: accent),
              const SizedBox(width: Gap.s),
              Expanded(
                child: Text(
                  count == 0
                      ? 'The model is guessing — it has no idea who this is for.'
                      : 'The model now has more to go on, so it guesses less.',
                  style: TextStyle(color: c.textDim, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(answer, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ChecklistCard extends StatefulWidget {
  const _ChecklistCard();

  @override
  State<_ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<_ChecklistCard> {
  final List<bool> _checked = [false, false, false];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final tips = <String>[
      'Ask it to ask you questions first — let it fill the gaps before it writes.',
      'Ask for sources, then open them — do not trust an answer just because it sounds right.',
      'Say what you already tried — so it does not repeat what you already know.',
    ];
    return DemoCard(
      title: 'A few habits that help',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A small checklist you can keep in your head. Tap through it when you are ready.',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          for (var i = 0; i < tips.length; i++)
            CheckboxListTile(
              key: ValueKey('checklist-$i'),
              title: Text(tips[i]),
              dense: true,
              value: _checked[i],
              activeColor: accent,
              onChanged: (v) {
                setState(() {
                  _checked[i] = v ?? false;
                });
              },
            ),
        ],
      ),
    );
  }
}
