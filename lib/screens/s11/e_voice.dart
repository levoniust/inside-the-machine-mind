import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Talking to AI: the relay of interpreters (ears → brain → mouth) vs one model that hears and speaks, "What survives
/// the relay?", and voice safety. Facts VOX-*, SPCH-* (GPT-4o system card, Whisper, Windows voices, Piper).
class EVoiceScreen extends StatelessWidget {
  const EVoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(11);
    return LessonScaffold(
      lessonId: 'e_voice',
      children: [
        const _Relay(),
        const _WhatSurvives(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: 'Preset voices only',
                label: 'after a test model sometimes copied the user\'s own voice',
                factId: 'VOX-PRESETS',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'Take the mic',
                label: 'you can cut in at any time; rude between people, normal with AI',
                factId: 'VOX-INTERRUPT',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Relay extends StatefulWidget {
  const _Relay();

  @override
  State<_Relay> createState() => _RelayState();
}

class _RelayState extends State<_Relay> {
  bool _oneModel = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    Widget stage(IconData icon, String name, String what, Color col) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(Gap.s),
        decoration: BoxDecoration(
          color: col.withValues(alpha: 0.14),
          border: Border.all(color: col),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: col),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            Text(
              what,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textDim, fontSize: 11),
            ),
          ],
        ),
      ),
    );
    final arrow = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.arrow_forward, size: 16, color: c.textDim),
    );
    return DemoCard(
      title: 'A relay of interpreters',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Relay')),
              ButtonSegment(value: true, label: Text('One model')),
            ],
            selected: {_oneModel},
            onSelectionChanged: (s) => setState(() => _oneModel = s.first),
          ),
          const SizedBox(height: Gap.m),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _oneModel
                ? Row(
                    key: const ValueKey('voice-one'),
                    children: [stage(Icons.graphic_eq, 'One model', 'hears, thinks and speaks', accent)],
                  )
                : Row(
                    key: const ValueKey('voice-relay'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      stage(Icons.hearing, 'Ears', 'speech → text\n(e.g. Whisper)', c.cyan),
                      arrow,
                      stage(Icons.psychology_outlined, 'Brain', 'text → text\n(the chat model)', accent),
                      arrow,
                      stage(Icons.record_voice_over_outlined, 'Mouth', 'text → speech\n(e.g. Piper)', c.amber),
                    ],
                  ),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            _oneModel
                ? 'Newer voice modes use one [[multimodal]] model that takes in sound and gives out sound directly. '
                      'No hand-offs: GPT-4o can answer in as little as 232 milliseconds, about as fast as a person.'
                : 'The classic way: three separate models pass the job along like interpreters. Each one waits for the '
                      'one before it to finish, and the middle one only ever sees plain text.',
            key: ValueKey('voice-explain-$_oneModel'),
          ),
          const SizedBox(height: Gap.s),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: '232 ms', label: 'fastest spoken reply (320 ms average)', factId: 'VOX-FAST'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(
                  value: 'Ears that translate',
                  label: 'Whisper also turns other languages into English',
                  factId: 'VOX-WHISPER-TRANSLATE',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// The game: what reaches the brain in the relay? Speech-to-text writes down words, so anything that isn't words is lost.

class _Clue {
  const _Clue(this.what, this.survives, this.why);
  final String what, why;
  final bool survives;
}

const _clues = [
  _Clue('The words you said', true, 'That\'s exactly what speech-to-text writes down.'),
  _Clue(
    'Your sarcastic tone: "Oh, great idea."',
    false,
    'Written down, "great idea" looks sincere. The tone stays behind.',
  ),
  _Clue('That you sound out of breath', false, 'Breathing isn\'t a word, so it isn\'t in the text.'),
  _Clue('A question asked in French', true, 'Whisper writes French, or translates it into English.'),
  _Clue(
    'Two people talking at once',
    false,
    'Plain text doesn\'t say who said what unless an extra tool labels speakers.',
  ),
  _Clue('A dog barking in the background', false, 'Not words, so the brain never hears it.'),
];

class _WhatSurvives extends StatefulWidget {
  const _WhatSurvives();

  @override
  State<_WhatSurvives> createState() => _WhatSurvivesState();
}

class _WhatSurvivesState extends State<_WhatSurvives> {
  final _pick = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final right = _pick.entries.where((e) => _clues[e.key].survives == e.value).length;
    return DemoCard(
      title: 'What survives the relay?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('In the relay, the brain only gets the text the ears wrote. Does each thing reach it?'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _clues.length; i++) ...[
            Text(_clues[i].what, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(
              children: [
                for (final yes in [true, false]) ...[
                  if (!yes) const SizedBox(width: Gap.s),
                  Expanded(
                    child: ChoiceChip(
                      key: ValueKey('voice-$i-$yes'),
                      label: Text(yes ? 'Reaches the brain' : 'Lost'),
                      selected: _pick[i] == yes,
                      selectedColor: (_clues[i].survives == yes ? accent : c.amber).withValues(alpha: 0.3),
                      onSelected: (_) => setState(() => _pick[i] = yes),
                    ),
                  ),
                ],
              ],
            ),
            if (_pick[i] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${p == _clues[i].survives ? 'Right' : 'Not quite'}: ${_clues[i].why}',
                  key: ValueKey('voice-why-$i'),
                  style: TextStyle(color: p == _clues[i].survives ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_pick.length == _clues.length)
            Text(
              '$right of ${_clues.length}. A model that hears sound directly can, in principle, pick up tone and '
              'background; the relay keeps only the words.',
              key: const ValueKey('voice-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
