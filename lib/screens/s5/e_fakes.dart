import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Fakes and scams: three little comic strips (a cloned-voice call, a celebrity ad, an official-looking
/// email). Tap the red flags in each panel; every story ends with one habit. Facts FAKE-* (FTC + FBI IC3,
/// as of Oct 2026).
class EFakesScreen extends StatelessWidget {
  const EFakesScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 'e_fakes',
        children: [_StoryFinder(), _Habits(), _Stats()],
      );
}

class _Beat {
  const _Beat(this.text, this.reveal, {this.isFlag = false});
  final String text, reveal;
  final bool isFlag;
}

class _Story {
  const _Story(this.title, this.icon, this.scene, this.beats, this.habit);
  final String title;
  final IconData icon;
  final String scene;
  final List<_Beat> beats;
  final String habit;
}

const _stories = [
  _Story(
    'The worried call',
    Icons.call,
    '2 a.m. Grandma\'s phone rings. The voice is terrified: her grandson is in trouble abroad and needs money tonight.',
    [
      _Beat('The voice sounds exactly like her grandson.',
          'That is the trick, not the proof — a few seconds of recording is enough to [[voice clone]] someone.'),
      _Beat('"You have to act tonight."', 'Pressure to act now is the classic move. A real emergency can wait for a call back.',
          isFlag: true),
      _Beat('"Don\'t tell anyone in the family yet."', 'A request for secrecy stops you from checking the story with anyone.',
          isFlag: true),
      _Beat('"Buy gift cards and read me the codes."',
          'Gift cards, wires and crypto are how scammers take money you can\'t get back.', isFlag: true),
    ],
    'Hang up, then call him back on the number already in your phone.',
  ),
  _Story(
    'The celebrity ad',
    Icons.smart_display,
    'A video ad shows a famous actor recommending an investment app — her face, voice and wink look perfectly real.',
    [
      _Beat('Her face and voice look completely real.',
          'A face and voice are exactly what AI can fake now. Looking real proves nothing.'),
      _Beat('"Guaranteed to double your money."', 'Guaranteed profit does not exist. A promised guarantee is itself the red flag.',
          isFlag: true),
      _Beat('"The banks hate this — act before it disappears."', 'Secrecy plus a countdown: pressure dressed up as an insider tip.',
          isFlag: true),
      _Beat('The link says "invest-actra.com", not the company\'s real site.',
          'One wrong letter means it is not the real site. Type the address yourself instead of clicking.', isFlag: true),
    ],
    'Search for the offer yourself — on the company\'s real site, never through their link.',
  ),
  _Story(
    'The official email',
    Icons.mail,
    'An email from the electric company: "Final notice — pay today or your power is cut off."',
    [
      _Beat('The logo and formatting are perfect.',
          'Perfect writing and logos are free now — AI writes convincing fake messages in any language.'),
      _Beat('"Your power will be cut in one hour."', 'Threats on a deadline are pressure, not procedure. Real utilities send bills in the post too.',
          isFlag: true),
      _Beat('The sender address is not from the company\'s domain.',
          'Check the actual address, not the display name. A company\'s name can be typed as anything.', isFlag: true),
      _Beat('"Click here to pay the late fee right now."', 'An urgent link leads to a fake payment page. Open your account yourself.',
          isFlag: true),
    ],
    'Call the number on your paper bill or the official site — never the one printed in the message.',
  ),
];

class _StoryFinder extends StatefulWidget {
  const _StoryFinder();

  @override
  State<_StoryFinder> createState() => _StoryFinderState();
}

class _StoryFinderState extends State<_StoryFinder> {
  int _story = 0;
  final Set<String> _found = {}; // "s-b" for flagged beats the user spotted
  final Set<String> _tapped = {}; // every beat tapped (flags + bait), so reveals stay open

  String _id(int b) => '$_story-$b';

  int _flagsFound(int s) => _stories[s].beats.asMap().entries.where((e) => e.value.isFlag && _found.contains('$s-${e.key}')).length;

  void _tap(int i, _Beat beat) {
    final id = _id(i);
    setState(() {
      _tapped.add(id);
      if (beat.isFlag) _found.add(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final s = _stories[_story];
    final flags = s.beats.where((b) => b.isFlag).length;
    final done = _flagsFound(_story);
    return DemoCard(
      title: 'Spot the red flags',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var i = 0; i < _stories.length; i++)
                ChoiceChip(
                  key: ValueKey('fake-story-$i'),
                  avatar: Icon(_stories[i].icon, size: 18, color: _story == i ? accent : c.textDim),
                  label: Text(_stories[i].title),
                  selected: _story == i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _story = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(s.scene, style: TextStyle(color: c.textDim, fontStyle: FontStyle.italic)),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < s.beats.length; i++) _beatRow(context, i, s.beats[i]),
          const SizedBox(height: Gap.s),
          Text(
            done == flags ? 'All $flags red flags found in this story.' : 'Red flags found here: $done of $flags',
            key: ValueKey('fake-progress'),
            style: TextStyle(fontWeight: FontWeight.w700, color: done == flags ? c.lime : c.textDim, fontSize: 13),
          ),
          if (done == flags)
            Container(
              key: ValueKey('fake-habit-$_story'),
              margin: const EdgeInsets.only(top: Gap.s),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.lime),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.self_improvement, color: c.lime, size: 20),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Habit to keep', style: TextStyle(fontWeight: FontWeight.w700)),
                        Text(s.habit, style: const TextStyle(fontSize: 13.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _beatRow(BuildContext context, int i, _Beat beat) {
    final c = AppColors.of(context);
    final id = _id(i);
    final tapped = _tapped.contains(id);
    final found = _found.contains(id);
    final color = tapped ? (beat.isFlag ? c.red : c.textDim) : c.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: InkWell(
        key: ValueKey('fake-beat-$id'),
        borderRadius: BorderRadius.circular(10),
        onTap: () => _tap(i, beat),
        child: Container(
          padding: const EdgeInsets.all(Gap.s),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: tapped ? color : c.line, width: found ? 1.4 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                tapped ? (beat.isFlag ? Icons.warning_amber_rounded : Icons.do_not_disturb_alt) : Icons.touch_app_outlined,
                color: color,
                size: 20,
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(beat.text, style: TextStyle(color: color)),
                    if (tapped)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: TermText(
                          beat.isFlag ? 'Red flag: ${beat.reveal}' : beat.reveal,
                          style: TextStyle(color: color, fontSize: 12.5, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Habits extends StatelessWidget {
  const _Habits();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const items = [
      ('A family safe word', 'Agree on a word only your real family knows — no AI on earth can guess it. The FBI recommends it.', 'FAKE-SAFEWORD'),
      ('Hang up and call back', 'Whatever the story, call the person on a number you already have. The voice was never the proof.', 'FAKE-VOICE'),
      ('Watch how you are asked to pay', 'Gift cards, wire transfers and crypto: money sent that way is almost impossible to get back.', 'FAKE-PAYMENT'),
      ('Never share sensitive details with online strangers', 'Not with people you met only online or over the phone — however believable they sound.', 'FAKE-GENAI'),
    ];
    return DemoCard(
      title: 'Four habits no AI can beat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (title, detail, factId) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: c.lime, size: 20),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(detail, style: TextStyle(color: c.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Where this comes from',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.info_outline, size: 20, color: c.textDim),
                    onPressed: () => showFactSource(context, factId),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'How big is this?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: FactCard(
                  value: r'$3.5 billion',
                  label: 'Reported lost to imposter scams in 2025',
                  factId: 'FAKE-STAT',
                ),
              ),
              SizedBox(width: Gap.m),
              Expanded(
                child: FactCard(
                  value: '1 in 3',
                  label: 'fraud reports in 2025 were about someone pretending to be a person or company — the most-reported category',
                  factId: 'FAKE-STAT',
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Generative AI lets criminals write and voice these messages faster, and send them to far more people. '
            'The defence has stayed stubbornly manual: stop, verify, call back.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
