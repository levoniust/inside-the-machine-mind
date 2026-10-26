import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Big or small model?: every big US maker sells its models in sizes. Pick a company to see its line-up,
/// biggest first, in the maker's own words with its API price; then match everyday jobs to a size.
/// Facts TIER-* (each maker's own model and pricing pages, read 2026-10-26).
class EModelSizeScreen extends StatelessWidget {
  const EModelSizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    return LessonScaffold(
      lessonId: 'e_model_size',
      children: [
        const _Lineups(),
        const _MatchGame(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '100×',
                label: 'price gap per word written between Claude Fable 5.1 (\$50) and Claude Haiku 5.5 (from \$0.50)',
                factId: 'TIER-ANTHROPIC-HAIKU',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '100×',
                label: 'the same gap between GPT-6 Astra (\$50) and GPT-6 Luna (\$0.50)',
                factId: 'TIER-OPENAI-LUNA',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Tier {
  const _Tier(this.name, this.says, this.factId, {this.inPrice, this.outPrice, this.note});
  final String name, says, factId;

  /// API list price in US dollars per million tokens (null when the maker publishes none).
  final double? inPrice, outPrice;
  final String? note;
}

class _Maker {
  const _Maker(this.name, this.tiers, {this.footnote});
  final String name;

  /// Biggest first, as the maker lists them.
  final List<_Tier> tiers;
  final String? footnote;
}

const _makers = [
  _Maker('OpenAI', [
    _Tier('GPT-6 Astra', 'Our most capable model for the most demanding work.', 'TIER-OPENAI-ASTRA', inPrice: 10, outPrice: 50),
    _Tier('GPT-6.1 Sol', 'Near-Astra performance for complex work at a lower cost.', 'TIER-OPENAI-SOL', inPrice: 2, outPrice: 10),
    _Tier('GPT-6.1 Terra', 'A fast, efficient model for visual reasoning, precise computer use, and clear, natural writing.',
        'TIER-OPENAI-TERRA', inPrice: 1, outPrice: 5),
    _Tier('GPT-6 Luna', 'Our most efficient model for focused, high-volume tasks.', 'TIER-OPENAI-LUNA',
        inPrice: 0.1, outPrice: 0.5),
  ], footnote: 'OpenAI: start with Astra for complex reasoning and coding, Sol to balance intelligence and cost, '
      'Luna for cost-sensitive, high-volume work.'),
  _Maker('Anthropic', [
    _Tier('Claude Fable 5.1', 'For demanding reasoning and long-horizon agentic work.', 'TIER-ANTHROPIC-FABLE',
        inPrice: 10, outPrice: 50, note: 'slower'),
    _Tier('Claude Opus 5.5', 'For long-running agentic coding and knowledge work.', 'TIER-ANTHROPIC-OPUS',
        inPrice: 4, outPrice: 20, note: 'moderate speed'),
    _Tier('Claude Sonnet 5.5', 'The best combination of speed and intelligence.', 'TIER-ANTHROPIC-SONNET',
        inPrice: 2, outPrice: 10, note: 'fast'),
    _Tier('Claude Haiku 5.5', 'For high-volume, latency-sensitive tasks such as classification, extraction, and routing.',
        'TIER-ANTHROPIC-HAIKU', inPrice: 0.1, outPrice: 0.5, note: 'fastest; price "from"'),
  ], footnote: 'Anthropic: start with Opus for most work; use Fable when the job is demanding reasoning or long agent runs.'),
  _Maker('Google', [
    _Tier('Gemini 4 Argon', 'Our flagship reasoning model.', 'TIER-GOOGLE-ARGON', inPrice: 2, outPrice: 10,
        note: 'launch price until Nov 30, then \$4 / \$20'),
    _Tier('Gemini 3.8 Flash', 'Our most intelligent Flash model.', 'TIER-GOOGLE-FLASH', inPrice: 0.75, outPrice: 3.75,
        note: 'until Dec 31, then \$1.50 / \$7.50'),
    _Tier('Gemini 3.5 Flash-Lite', 'Our fastest, most cost-effective 3.5 model for high-throughput execution.', 'TIER-GOOGLE-LITE',
        inPrice: 0.3, outPrice: 2.5),
  ]),
  _Maker('xAI', [
    _Tier('Grok 4.7', 'Our flagship model for code and everything else.', 'TIER-XAI', inPrice: 2, outPrice: 6),
  ], footnote: 'xAI sells one text model and lets you turn its reasoning up or down instead of picking a size.'),
  _Maker('Meta', [
    _Tier('Muse Wonder Full', 'Offered to Muse Code subscribers.', 'TIER-META'),
    _Tier('Muse Wonder', 'Offered through the Meta Model API and Muse Code.', 'TIER-META'),
  ], footnote: 'Meta calls both "frontier models for agents", built on its earlier Muse Spark. It publishes no price per tier.'),
  _Maker('Amazon', [
    _Tier('Nova 2 Lite', 'A fast, cost-effective reasoning model for most everyday tasks.', 'TIER-AMAZON'),
  ], footnote: 'Amazon offers one current text model and lets you set its thinking effort: off, low, medium or high.'),
];

/// The price bar is on a log scale from \$0.50 to \$50 per million output tokens, so the cheap tiers stay visible.
double _barFraction(double out) => ((math.log(out) - math.log(0.5)) / (math.log(50) - math.log(0.5))).clamp(0.04, 1.0);

String _usd(double v) => v >= 1 ? '\$${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)}' : '\$${v.toStringAsFixed(2)}';

class _Lineups extends StatefulWidget {
  const _Lineups();

  @override
  State<_Lineups> createState() => _LineupsState();
}

class _LineupsState extends State<_Lineups> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final m = _makers[_sel];
    return DemoCard(
      title: 'Every maker sells sizes',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var i = 0; i < _makers.length; i++)
                ChoiceChip(
                  key: ValueKey('size-maker-$i'),
                  label: Text(_makers[i].name),
                  selected: _sel == i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _sel = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(m.tiers.length > 1 ? 'Biggest at the top, smallest at the bottom' : 'One size',
              style: TextStyle(color: c.textDim, fontSize: 12)),
          const SizedBox(height: Gap.xs),
          for (final t in m.tiers)
            Container(
              key: ValueKey('size-tier-${t.name}'),
              margin: const EdgeInsets.only(bottom: Gap.s),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.45)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('"${t.says}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                  if (t.outPrice != null) ...[
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, box) => Container(
                        height: 8,
                        width: box.maxWidth * _barFraction(t.outPrice!),
                        decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_usd(t.inPrice!)} in / ${_usd(t.outPrice!)} out per million tokens'
                      '${t.note == null ? '' : ' · ${t.note}'}',
                      style: AppText.mono.copyWith(fontSize: 12, color: c.textDim),
                    ),
                  ],
                ],
              ),
            ),
          if (m.footnote != null) Text(m.footnote!, style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.xs),
          TermText(
            'Prices are for developers, per million [[token]]s (about 750,000 words). In the chat apps you usually pay a monthly '
            'plan instead. From each maker\'s own pages.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

enum _Size { small, middle, big }

const _sizeLabels = {_Size.small: 'Small & fast', _Size.middle: 'Middle', _Size.big: 'Biggest'};

class _Job {
  const _Job(this.job, this.ok, this.why);
  final String job, why;

  /// Sizes that make sense (the first is the best fit).
  final List<_Size> ok;
}

const _jobs = [
  _Job('Sort 10,000 customer emails into folders', [_Size.small],
      'Simple and repeated thousands of times: the small, fast tier is made for exactly this (Anthropic\'s words for Haiku: '
      '"classification, extraction, and routing"). The biggest would cost up to 100 times more.'),
  _Job('Fix the spelling in a text message', [_Size.small],
      'Quick and easy. A small model answers almost instantly; a giant one adds wait and cost for no gain.'),
  _Job('Plan a week of meals from what is in the fridge', [_Size.middle, _Size.small],
      'A bit of reasoning, nothing extreme. A middle model is the sweet spot; a small one usually copes too.'),
  _Job('Read a 60-page contract and flag the risky parts', [_Size.middle, _Size.big],
      'Long reading and careful judgement: a middle model does well, and the biggest is worth it if a mistake would be costly. '
      'Either way, have a person check anything that matters.'),
  _Job('Build and test a whole app, working on its own for hours', [_Size.big],
      'Long, many-step work is what the flagships are sold for (Anthropic: "long-horizon agentic work"; OpenAI: '
      '"the most demanding work").'),
];

class _MatchGame extends StatefulWidget {
  const _MatchGame();

  @override
  State<_MatchGame> createState() => _MatchGameState();
}

class _MatchGameState extends State<_MatchGame> {
  final _picks = <int, _Size>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final good = [for (final e in _picks.entries) if (_jobs[e.key].ok.contains(e.value)) e.key].length;
    return DemoCard(
      title: 'Match the job to the size',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _jobs.length; i++) ...[
            Text(_jobs[i].job, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Wrap(
              spacing: Gap.xs,
              runSpacing: Gap.xs,
              children: [
                for (final s in _Size.values)
                  ChoiceChip(
                    key: ValueKey('size-job-$i-${s.name}'),
                    label: Text(_sizeLabels[s]!),
                    selected: _picks[i] == s,
                    selectedColor: (_jobs[i].ok.contains(s) ? c.lime : c.amber).withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _picks[i] = s),
                  ),
              ],
            ),
            if (_picks[i] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${_jobs[i].ok.contains(_picks[i]) ? 'Good pick. ' : 'Hmm: best is "${_sizeLabels[_jobs[i].ok.first]}". '}'
                  '${_jobs[i].why}',
                  key: ValueKey('size-why-$i'),
                  style: TextStyle(fontSize: 13, color: _jobs[i].ok.contains(_picks[i]) ? c.text : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          Text(
            _picks.length < _jobs.length
                ? '${_picks.length} of ${_jobs.length} jobs matched'
                : 'Sensible picks: $good of ${_jobs.length}. Rule of thumb: start small, and move up only when the answers fall short.',
            key: const ValueKey('size-score'),
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
