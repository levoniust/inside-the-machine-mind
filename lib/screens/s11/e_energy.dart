import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// How much energy is one question?: "Line them up" (tap eight things from least to most energy), then a zoom-out
/// ladder in ×1000 steps from one prompt (Wh) to all U.S. energy for a year (TWh), where it adds up, and an honesty
/// card. Facts NRG-*, TR-GPT3-ENERGY.
class EEnergyScreen extends StatelessWidget {
  const EEnergyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(11);
    return LessonScaffold(
      lessonId: 'e_energy',
      children: [
        const _LineUp(),
        const _Ladder(),
        const _AddsUp(),
        const _Honesty(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '0.24 Wh',
                label: 'a typical Gemini text prompt: less than nine seconds of TV',
                factId: 'NRG-GEMINI',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '4.4%',
                label: 'of all U.S. electricity went to data centres in 2023',
                factId: 'NRG-DC-US',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One thing on the chart, with its energy in watt-hours.
class _Thing {
  const _Thing(this.name, this.wh, this.shown, this.factId);
  final String name, shown, factId;
  final double wh;
}

const _gemini = _Thing('One Gemini text prompt', 0.24, '0.24 Wh', 'NRG-GEMINI');
const _chatgpt = _Thing('One ChatGPT question', 0.34, '0.34 Wh', 'NRG-CHATGPT');
const _tv = _Thing('An hour of TV', 96, '~96 Wh', 'NRG-TV-HOUR');
const _homeDay = _Thing('A U.S. home for a day', 28800, '~29 kWh', 'NRG-HOME-DAY');
const _homeYear = _Thing('A U.S. home for a year', 10.5e6, '10.5 MWh', 'NRG-HOME-DAY');
const _whatIf = _Thing('1 billion questions (one day, what-if)', 340e6, '340 MWh', 'NRG-WHATIF');
const _gpt3 = _Thing('Training GPT-3 (2020)', 1.287e9, '~1.3 GWh', 'TR-GPT3-ENERGY');
const _dc = _Thing('All U.S. data centres for a year (2023)', 176e12, '176 TWh', 'NRG-DC-US');
const _usElec = _Thing('All U.S. electricity for a year (2025)', 4.2e15, '4,200 TWh', 'NRG-US-ELEC');
const _usAll = _Thing(
  'All U.S. energy for a year (2024): power, cars, heating, industry',
  27.6e15,
  '~27,600 TWh',
  'NRG-US-ENERGY',
);

// ---------------------------------------------------------------------------------------------------------------

const _cards = [_homeYear, _chatgpt, _usAll, _tv, _gpt3, _gemini, _dc, _homeDay, _usElec];

class _LineUp extends StatefulWidget {
  const _LineUp();

  @override
  State<_LineUp> createState() => _LineUpState();
}

class _LineUpState extends State<_LineUp> {
  final _placed = <int>[];
  int _misses = 0;
  String? _note;

  late final List<int> _order = [for (var i = 0; i < _cards.length; i++) i]
    ..sort((a, b) => _cards[a].wh.compareTo(_cards[b].wh));

  void _tap(int i) {
    setState(() {
      if (_order[_placed.length] == i) {
        _placed.add(i);
        _note = null;
      } else {
        _misses++;
        _note = 'Not yet: something left on the table uses less than "${_cards[i].name}".';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final done = _placed.length == _cards.length;
    return DemoCard(
      title: 'Line them up',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tap these from the least energy to the most.'),
          const SizedBox(height: Gap.s),
          for (final (n, i) in _placed.indexed)
            Container(
              key: ValueKey('nrg-placed-$n'),
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 6),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Text(
                    '${n + 1}. ',
                    style: TextStyle(color: accent, fontWeight: FontWeight.w800),
                  ),
                  Expanded(child: Text(_cards[i].name)),
                  Text(_cards[i].shown, style: AppText.mono.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          if (!done) ...[
            const SizedBox(height: Gap.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _cards.length; i++)
                  if (!_placed.contains(i))
                    ActionChip(key: ValueKey('nrg-card-$i'), label: Text(_cards[i].name), onPressed: () => _tap(i)),
              ],
            ),
          ],
          if (_note != null)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text(
                _note!,
                key: const ValueKey('nrg-note'),
                style: TextStyle(color: c.amber),
              ),
            ),
          if (done)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text(
                'Lined up with $_misses wrong tap${_misses == 1 ? '' : 's'}. The top and bottom are over 100 million billion '
                'times apart, too far for any normal chart. So let\'s climb a ladder.',
                key: const ValueKey('nrg-done'),
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Rung {
  const _Rung(this.unit, this.per, this.meaning, this.things);
  final String unit, meaning;

  /// Watt-hours in one of this rung's units.
  final double per;
  final List<_Thing> things;
}

const _rungs = [
  _Rung('Wh', 1, 'A watt-hour: a 1-watt light left on for an hour.', [_gemini, _chatgpt, _tv]),
  _Rung('kWh', 1e3, '1 kilowatt-hour = 1,000 Wh: the unit on your power bill.', [_tv, _homeDay]),
  _Rung('MWh', 1e6, '1 megawatt-hour = 1,000 kWh.', [_homeYear, _whatIf]),
  _Rung('GWh', 1e9, '1 gigawatt-hour = 1,000 MWh.', [_whatIf, _gpt3]),
  _Rung('TWh', 1e12, '1 terawatt-hour = 1,000 GWh: the scale of whole countries.', [_dc, _usElec, _usAll]),
];

String _fmt(double v) {
  if (v >= 100) {
    final s = v.round().toString();
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }
  return v >= 10 ? v.toStringAsFixed(1) : v.toStringAsFixed(v >= 1 ? 1 : 2);
}

class _Ladder extends StatefulWidget {
  const _Ladder();

  @override
  State<_Ladder> createState() => _LadderState();
}

class _LadderState extends State<_Ladder> {
  int _r = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final rung = _rungs[_r];
    final maxV = rung.things.map((t) => t.wh).reduce((a, b) => a > b ? a : b);
    return DemoCard(
      title: 'The zoom-out ladder',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < _rungs.length; i++) ...[
                if (i > 0) Expanded(child: Container(height: 2, color: i <= _r ? accent : c.line)),
                Container(
                  key: ValueKey('nrg-rung-$i'),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: i == _r ? accent : null,
                    border: Border.all(color: i <= _r ? accent : c.line),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _rungs[i].unit,
                    style: AppText.mono.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: i == _r ? Colors.white : c.text,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(
            rung.meaning,
            key: ValueKey('nrg-meaning-$_r'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.s),
          for (final t in rung.things) ...[
            Row(
              children: [
                Expanded(child: Text(t.name, style: const TextStyle(fontSize: 13))),
                Text(
                  '${_fmt(t.wh / rung.per)} ${rung.unit}',
                  style: AppText.mono.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 3),
            LayoutBuilder(
              builder: (context, box) => Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(6)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 12,
                    width: box.maxWidth * (t.wh / maxV).clamp(0.005, 1.0),
                    decoration: BoxDecoration(
                      color: t == _dc ? c.amber : accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.s),
          ],
          Text(
            _r == _rungs.length - 1
                ? 'Top of the ladder. Data centres (orange, all of them, not only AI) are a slice of U.S. electricity, which '
                      'is itself a slice of all the energy the country uses.'
                : 'Bars on each rung share one scale, so the small things really are that small.',
            key: ValueKey('nrg-caption-$_r'),
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('nrg-zoom-in'),
                  onPressed: _r == 0 ? null : () => setState(() => _r--),
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('÷1000'),
                ),
              ),
              const SizedBox(width: Gap.s),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('nrg-zoom-out'),
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  onPressed: _r == _rungs.length - 1 ? null : () => setState(() => _r++),
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Zoom out ×1000'),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: '4,200 TWh', label: 'all U.S. electricity, 2025', factId: 'NRG-US-ELEC'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: '~27,600 TWh', label: 'all U.S. energy, 2024', factId: 'NRG-US-ENERGY'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _AddsUp extends StatelessWidget {
  const _AddsUp();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: 'Where it adds up',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'One question is tiny: Sam Altman put a ChatGPT question at about what an oven uses in a little over one '
            'second, or an efficient bulb in a couple of minutes. But tiny × billions isn\'t tiny.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'What if a billion questions were asked every day? That\'s 340 MWh a day, about what 11,800 American homes '
            'use. And that\'s only answering: training the model comes first (GPT-3 alone took about 1.3 GWh).',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'The big trend: U.S. data centres went from 1.9% of the country\'s electricity in 2018 to 4.4% in 2023, and '
            'could reach 6.7-12% by 2028. Meanwhile Google says its own per-prompt energy fell 33× in one year.',
          ),
          SizedBox(height: Gap.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(
                  value: '~11,800 homes',
                  label: '1 billion questions a day, what-if',
                  factId: 'NRG-WHATIF',
                ),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: '0.34 Wh', label: 'ChatGPT average, says OpenAI\'s CEO', factId: 'NRG-CHATGPT'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Honesty extends StatelessWidget {
  const _Honesty();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: c.amber.withValues(alpha: 0.1),
        border: Border.all(color: c.amber),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: c.amber),
              const SizedBox(width: Gap.s),
              const Text('Read the small print', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: Gap.xs),
          const Text(
            'The per-question numbers come from the companies themselves, and they don\'t count the same things. '
            'Google\'s 0.24 Wh includes idle machines and data-centre overhead, for a "median" prompt. OpenAI\'s 0.34 Wh came in one '
            'sentence of a blog post without a method. Neither includes training. The U.S. totals are government '
            'statistics from different years (2023, 2024, 2025), so treat the chart as sizes, not exact sums.',
          ),
        ],
      ),
    );
  }
}
