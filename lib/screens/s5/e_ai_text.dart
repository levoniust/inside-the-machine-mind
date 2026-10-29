import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Was this written by AI?: how detectors guess and why they fail, "Detector roulette" (six texts; you and a made-up
/// detector that behaves like the tested ones both guess), and what works instead. Facts DET-*.
class EAiTextScreen extends StatelessWidget {
  const EAiTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(5);
    return LessonScaffold(
      lessonId: 'e_ai_text',
      children: [
        const _HowTheyGuess(),
        const _Roulette(),
        const _WhatWorks(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '61%',
                label: 'of essays by non-native English writers wrongly flagged as AI, on average',
                factId: 'DET-TOEFL',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'Paraphrase',
                label: 'rewording AI text sharply cuts detection, watermarks included',
                factId: 'DET-PARAPHRASE',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HowTheyGuess extends StatelessWidget {
  const _HowTheyGuess();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: 'Guessing who baked the cake',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'An AI detector is like guessing who baked a cake from its taste. It looks for text that is very '
            '"predictable", the kind of word choices a [[model]] would make. Smooth, plain, expected wording scores as '
            'AI; quirky wording scores as human.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'The trouble: plenty of people write plainly, especially in a second language, and anyone can ask an AI to '
            'write quirkier. So the taste test fails both ways.',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Text {
  const _Text(this.text, this.ai, this.detector, this.reveal);
  final String text, reveal;
  final bool ai;

  /// The made-up detector's "% AI" score.
  final int detector;
}

const _texts = [
  _Text(
    'In my country, many students study English hard. I think the exam is important because it decides the future. '
        'So I study every day.',
    false,
    88,
    'A person, writing in their second language. Plain wording looks "predictable", so it got flagged.',
  ),
  _Text(
    'Honestly the bus was SO late again lol, missed half of first period and mr k just gave me a look',
    false,
    5,
    'A person. Typos and slang read as human; the detector got this one.',
  ),
  _Text(
    'Photosynthesis is the process by which plants convert light energy into chemical energy, producing glucose and '
        'oxygen from carbon dioxide and water.',
    true,
    94,
    'AI, untouched. Detectors are best at exactly this.',
  ),
  _Text(
    'Plants are basically solar-powered sugar factories: they grab sunlight, breathe in CO2, slurp up water, and '
        'out comes sugar, plus the oxygen we breathe.',
    true,
    12,
    'AI, then reworded by another AI. Paraphrasing sinks detection.',
  ),
  _Text(
    'The tenant shall pay rent on the first day of each month. Late payment shall incur a fee as set out in '
        'Section 4.',
    false,
    81,
    'A person copying a standard lease clause. Formulaic text looks machine-like.',
  ),
  _Text(
    'Twilight spilled its amber ink across the harbour, and the gulls, those quarrelsome poets, argued over the '
        'last of the light.',
    true,
    20,
    'AI, asked to "use more literary language". A simple prompt fooled it.',
  ),
];

class _Roulette extends StatefulWidget {
  const _Roulette();

  @override
  State<_Roulette> createState() => _RouletteState();
}

class _RouletteState extends State<_Roulette> {
  final _guess = <int, bool>{}; // true = guessed AI

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final done = _guess.length == _texts.length;
    final you = _guess.entries.where((e) => e.value == _texts[e.key].ai).length;
    final det = _texts.where((t) => (t.detector >= 50) == t.ai).length;
    return DemoCard(
      title: 'Detector roulette',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Six short texts. Guess: person or AI? Then see what a detector said, and the truth.'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _texts.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                border: Border.all(color: c.line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('"${_texts[i].text}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 6),
                  if (!_guess.containsKey(i))
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: ValueKey('det-$i-human'),
                            onPressed: () => setState(() => _guess[i] = false),
                            child: const Text('A person'),
                          ),
                        ),
                        const SizedBox(width: Gap.s),
                        Expanded(
                          child: OutlinedButton(
                            key: ValueKey('det-$i-ai'),
                            onPressed: () => setState(() => _guess[i] = true),
                            child: const Text('AI'),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Row(
                      children: [
                        Text('Detector: ', style: TextStyle(color: c.textDim)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _texts[i].detector / 100,
                              minHeight: 8,
                              color: (_texts[i].detector >= 50) == _texts[i].ai ? accent : c.red,
                              backgroundColor: c.surfaceHi,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${_texts[i].detector}% AI', style: AppText.mono.copyWith(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_guess[i] == _texts[i].ai ? 'You got it' : 'Not this time'}. ${_texts[i].reveal}',
                      key: ValueKey('det-reveal-$i'),
                      style: TextStyle(color: _guess[i] == _texts[i].ai ? accent : c.amber),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: Gap.s),
          ],
          if (done)
            Text(
              'You: $you of ${_texts.length}. The detector: $det of ${_texts.length}, and it accused two people. '
              'A score like "88% AI" sounds precise; it isn\'t proof.',
              key: const ValueKey('det-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
          const SizedBox(height: Gap.xs),
          Text(
            'The detector here is made up, but it fails in the ways the tested detectors did.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WhatWorks extends StatelessWidget {
  const _WhatWorks();

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(5);
    const tips = [
      ('Talk about the work', 'Ask the writer to explain a choice or a source. People who did the work can.'),
      ('Look at the history', 'Drafts, notes and version history show how a text grew.'),
      (
        'Watermarks, where they exist',
        'A model can hide a statistical pattern in its word choices that a checker can find later. It only works if the maker adds it, and rewording can wash it out.',
      ),
      ('Never punish on a score alone', 'A detector\'s number is a hint, not evidence.'),
    ];
    return DemoCard(
      title: 'What works better',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (t, d) in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: accent),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(d),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const FactCard(value: '"Green" words', label: 'how one text watermark works', factId: 'DET-WATERMARK'),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'One prompt',
            label: '"use richer words" slipped AI text past detectors',
            factId: 'DET-PROMPT',
          ),
        ],
      ),
    );
  }
}
