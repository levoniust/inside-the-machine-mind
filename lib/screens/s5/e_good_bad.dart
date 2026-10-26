import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Confident guesses: what chatbots are great at vs where to watch out (flip cards), then "Spot the made-up fact":
/// three rounds of four sentences in a chat bubble; three are true (verified facts), one is invented.
class EGoodBadScreen extends StatelessWidget {
  const EGoodBadScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'e_good_bad', children: [_Cards(), _SpotTheFake()]);
}

class _Card {
  const _Card(this.title, this.example, this.why, {required this.good});
  final String title, example, why;
  final bool good;
}

const _cards = [
  _Card(
    'First drafts',
    '"Write a friendly note asking my neighbour to move their car."',
    'Wording is what it learned best: it has seen millions of notes, letters and emails.',
    good: true,
  ),
  _Card(
    'Summaries',
    '"Give me the 5 main points of this long article."',
    'Everything it needs is right there in what you pasted, so it has less to guess.',
    good: true,
  ),
  _Card('Ideas', '"20 names for a bake sale."', 'Lots of plausible options fast; you pick the good ones.', good: true),
  _Card(
    'Explaining',
    '"Explain compound interest like I\'m 12."',
    'Re-wording a well-known idea is a strength. Still check the details.',
    good: true,
  ),
  _Card(
    'Exact facts and numbers',
    '"What year did this small town get its library?"',
    'It produces the most likely-sounding answer, not a looked-up one. Rare facts are where it guesses.',
    good: false,
  ),
  _Card(
    'Quotes, sources and links',
    '"Give me 3 studies that prove this."',
    'It can invent titles, authors and links that look perfect. Always open the source.',
    good: false,
  ),
  _Card(
    'Recent news',
    '"What happened in the news this morning?"',
    'It only knows what was in its training data, unless the app searches the web for it.',
    good: false,
  ),
  _Card(
    'Big personal decisions',
    'Health, money, legal problems.',
    'Useful to prepare questions; the decision belongs with you and a real expert.',
    good: false,
  ),
];

class _Cards extends StatefulWidget {
  const _Cards();

  @override
  State<_Cards> createState() => _CardsState();
}

class _CardsState extends State<_Cards> {
  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget column(bool good) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            good ? 'Great at' : 'Watch out',
            style: TextStyle(fontWeight: FontWeight.w800, color: good ? c.lime : c.amber),
          ),
          const SizedBox(height: Gap.xs),
          for (var i = 0; i < _cards.length; i++)
            if (_cards[i].good == good)
              Padding(
                padding: const EdgeInsets.only(bottom: Gap.xs),
                child: InkWell(
                  key: ValueKey('gb-card-$i'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(Gap.s),
                    decoration: BoxDecoration(
                      color: (good ? c.lime : c.amber).withValues(alpha: _open.contains(i) ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: (good ? c.lime : c.amber).withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_cards[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (_open.contains(i)) ...[
                          const SizedBox(height: 4),
                          Text(
                            _cards[i].example,
                            style: TextStyle(fontStyle: FontStyle.italic, color: c.textDim, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(_cards[i].why, style: const TextStyle(fontSize: 13)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
    return DemoCard(
      title: 'Tap a card to see why',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          column(true),
          const SizedBox(width: Gap.s),
          column(false),
        ],
      ),
    );
  }
}

class _Round {
  const _Round(this.topic, this.lines, this.fake, this.why);
  final String topic;
  final List<String> lines;
  final int fake;
  final String why;
}

// True lines are verified facts (TR-TRANSFORMER, TR-BACKPROP, TR-GPT3, DC-HOME-KW, DC-WATER-VS-AIR, DC-IEA,
// TR-TOKEN-WORDS, TR-READING, TR-PHI3). The made-up line in each round copies the classic shape of a hallucination.
const _rounds = [
  _Round(
    'A bit of AI history',
    [
      'The Transformer, the design behind today\'s chatbots, was introduced in a 2017 paper called "Attention Is All You Need".',
      'The first chatbot to pass the Turing test was Microsoft\'s Clippy, in a 2001 trial at Stanford University.',
      'Backpropagation, the way neural networks learn from their mistakes, was made popular by a 1986 paper in the journal Nature.',
      'GPT-3, released in 2020, had 175 billion parameters.',
    ],
    1,
    'A famous name, a precise year and a respected university make it sound solid, but no such trial happened. '
        'Specific details are not proof: check them.',
  ),
  _Round(
    'Power and datacenters',
    [
      'An average U.S. home uses about 10,500 kWh of electricity a year.',
      'Water carries about 3,500 times more heat than the same volume of air, which is why the hottest server racks are liquid-cooled.',
      'Since 2024, U.S. law requires every AI datacenter to run entirely on solar power.',
      'Data centres used about 1.5% of the world\'s electricity in 2024.',
    ],
    2,
    'A sweeping rule ("every", "entirely", "by law") with no source is a red flag. A real law would be easy to find; '
        'this one does not exist.',
  ),
  _Round(
    'Words and tokens',
    [
      'One token is roughly three quarters of an English word.',
      'As Albert Einstein wrote in 1931: "A machine that can talk will never be able to lie."',
      'Reading 15 trillion tokens at 250 words per minute, 8 hours a day, would take about 250,000 years.',
      'Phi-3-mini, a model with 3.8 billion parameters, is small enough to run on a phone.',
    ],
    1,
    'Quotes from famous people are a favourite for made-up text: they sound wise and are hard to check from memory. '
        'Search for the exact quote and a real source.',
  ),
];

class _SpotTheFake extends StatefulWidget {
  const _SpotTheFake();

  @override
  State<_SpotTheFake> createState() => _SpotTheFakeState();
}

class _SpotTheFakeState extends State<_SpotTheFake> {
  int _round = 0, _score = 0;
  int? _picked;

  bool get _finished => _round >= _rounds.length;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    if (_finished) {
      return DemoCard(
        title: 'Spot the made-up fact',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You found $_score of ${_rounds.length}',
              key: const ValueKey('gb-score'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: Gap.s),
            const BitSays(
              lines: [
                'The habit that beats every made-up fact: check names, numbers, quotes and links before you use them.',
              ],
              mood: BitMood.happy,
            ),
            const SizedBox(height: Gap.s),
            OutlinedButton(
              onPressed: () => setState(() {
                _round = 0;
                _score = 0;
                _picked = null;
              }),
              child: const Text('Play again'),
            ),
          ],
        ),
      );
    }
    final r = _rounds[_round];
    return DemoCard(
      title: 'Spot the made-up fact · ${_round + 1} / ${_rounds.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'A chatbot told you this about "${r.topic}". One sentence is invented. Which one?',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < r.lines.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: InkWell(
                      key: ValueKey('gb-line-$i'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: _picked != null
                          ? null
                          : () => setState(() {
                              _picked = i;
                              if (i == r.fake) _score++;
                            }),
                      child: Container(
                        padding: const EdgeInsets.all(Gap.s),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _picked == null
                              ? null
                              : i == r.fake
                              ? c.red.withValues(alpha: 0.15)
                              : i == _picked
                              ? c.amber.withValues(alpha: 0.12)
                              : null,
                          border: Border.all(color: _picked != null && i == r.fake ? c.red : c.line),
                        ),
                        child: Text(r.lines[i]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_picked != null) ...[
            const SizedBox(height: Gap.s),
            Text(
              _picked == r.fake ? 'You caught it!' : 'That one is true. The invented one is marked in red.',
              key: const ValueKey('gb-result'),
              style: TextStyle(fontWeight: FontWeight.w800, color: _picked == r.fake ? c.lime : c.amber),
            ),
            const SizedBox(height: 4),
            Text(r.why),
            const SizedBox(height: Gap.s),
            FilledButton(
              key: const ValueKey('gb-next'),
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
              onPressed: () => setState(() {
                _round++;
                _picked = null;
              }),
              child: Text(_round + 1 < _rounds.length ? 'Next round' : 'See my score'),
            ),
          ],
        ],
      ),
    );
  }
}
