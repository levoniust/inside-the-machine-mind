import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/glossary.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · "The word decoder": 16 flip cards, engineering term on the front, everyday word and
/// meaning on the back (from the glossary). A "Test yourself" mode quizzes the same 16 terms:
/// 8 random rounds, each showing one everyday phrase with three terms to choose from.
class S2DecoderScreen extends StatelessWidget {
  const S2DecoderScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_decoder',
        children: [_Deck()],
      );
}

const decoderTerms = [
  'Training', 'Inference', 'Parameter', 'Model', 'Dataset', 'Token', 'Embedding', 'Loss',
  'Gradient', 'Backpropagation', 'Learning rate', 'Batch', 'Epoch', 'Checkpoint', 'Fine-tuning', 'Hallucination',
];

enum _Mode { browse, quiz }

class _Deck extends StatefulWidget {
  const _Deck();

  @override
  State<_Deck> createState() => _DeckState();
}

class _DeckState extends State<_Deck> {
  final Set<int> _flipped = {};
  _Mode _mode = _Mode.browse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<_Mode>(
          key: const ValueKey('decoder-mode'),
          segments: const [
            ButtonSegment(value: _Mode.browse, label: Text('Decode cards')),
            ButtonSegment(value: _Mode.quiz, label: Text('Test yourself')),
          ],
          selected: {_mode},
          showSelectedIcon: false,
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: Gap.m),
        if (_mode == _Mode.browse) ..._browse(context) else const _Quiz(),
      ],
    );
  }

  /// The flip-card deck: counter row, the 16 cards, and the "all decoded" line.
  List<Widget> _browse(BuildContext context) {
    final c = AppColors.of(context);
    final cols = MediaQuery.sizeOf(context).width >= 600 ? 4 : 2;
    return [
      Row(
        children: [
          Expanded(
            child: Text('${_flipped.length} / ${decoderTerms.length} decoded',
                key: const ValueKey('decoder-count'),
                style: TextStyle(color: c.violet, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          TextButton(
            key: const ValueKey('decoder-all'),
            onPressed: () => setState(() => _flipped.length == decoderTerms.length
                ? _flipped.clear()
                : _flipped.addAll(List.generate(decoderTerms.length, (i) => i))),
            child: Text(_flipped.length == decoderTerms.length ? 'Hide all' : 'Flip all'),
          ),
        ],
      ),
      const SizedBox(height: Gap.s),
      LayoutBuilder(
        builder: (context, box) {
          final w = (box.maxWidth - Gap.s * (cols - 1)) / cols;
          final h = MediaQuery.textScalerOf(context).scale(150);
          return Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < decoderTerms.length; i++)
                SizedBox(
                  width: w,
                  height: h,
                  child: _FlipCard(
                    key: ValueKey('decoder-$i'),
                    term: decoderTerms[i],
                    flipped: _flipped.contains(i),
                    onTap: () => setState(() => _flipped.contains(i) ? _flipped.remove(i) : _flipped.add(i)),
                  ),
                ),
            ],
          );
        },
      ),
      if (_flipped.length == decoderTerms.length) ...[
        const SizedBox(height: Gap.m),
        Text('All decoded! Every big AI word is a small idea in a costume.',
            style: TextStyle(color: c.lime, fontWeight: FontWeight.w700)),
      ],
    ];
  }
}

/// "Test yourself": 8 random rounds drawn from the same 16 terms. Each round shows one glossary
/// everyday phrase and three engineering terms; tap the match and the score ticks up.
class _Quiz extends StatefulWidget {
  const _Quiz();

  @override
  State<_Quiz> createState() => _QuizState();
}

class _QuizState extends State<_Quiz> {
  static const rounds = 8;
  final math.Random _rnd = math.Random();
  late List<int> _order; // term indices for this game's rounds, no repeats
  final List<int> _options = []; // the three choice term indices of the current round
  final List<bool> _results = []; // one entry per answered round
  int _round = 0; // 0-based index of the current round
  int? _picked; // index into [_options] once answered
  bool _finished = false;

  int get _score => _results.where((r) => r).length;
  bool get _answered => _picked != null;

  @override
  void initState() {
    super.initState();
    _order = _newOrder();
    _startRound();
  }

  List<int> _newOrder() {
    final all = List.generate(decoderTerms.length, (i) => i)..shuffle(_rnd);
    return all.take(rounds).toList();
  }

  void _startRound() {
    final answer = _order[_round];
    final wrong = [for (var i = 0; i < decoderTerms.length; i++) if (i != answer) i]..shuffle(_rnd);
    _options
      ..clear()
      ..addAll([answer, wrong[0], wrong[1]])
      ..shuffle(_rnd);
    _picked = null;
  }

  void _pick(int choice) {
    if (_answered) return;
    setState(() {
      _picked = choice;
      _results.add(_options[choice] == _order[_round]);
    });
  }

  void _next() {
    setState(() {
      if (_round + 1 >= rounds) {
        _finished = true;
      } else {
        _round++;
        _startRound();
      }
    });
  }

  void _replay() {
    setState(() {
      _order = _newOrder();
      _round = 0;
      _results.clear();
      _finished = false;
      _startRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(title: 'Test yourself', child: _finished ? _final(c) : _roundView(context));
  }

  Widget _roundView(BuildContext context) {
    final c = AppColors.of(context);
    final answer = decoderTerms[_order[_round]];
    final everyday = findTerm(answer)?.everyday ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Round ${_round + 1} / $rounds',
                  key: ValueKey('decoder-round-$_round'),
                  style: TextStyle(color: c.violet, fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            Text('Score: $_score', key: const ValueKey('decoder-score'), style: AppText.mono.copyWith(color: c.textDim, fontSize: 14)),
          ],
        ),
        const SizedBox(height: Gap.s),
        Semantics(
          label: 'Round ${_round + 1} of $rounds, $_score correct so far',
          child: Wrap(
            spacing: Gap.s,
            children: [
              for (var i = 0; i < rounds; i++)
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _results.length ? (_results[i] ? c.lime : c.red) : c.surfaceHi,
                    border: Border.all(color: i == _round && !_answered ? c.violet : c.line),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Gap.m),
        Container(
          padding: const EdgeInsets.all(Gap.l),
          decoration: BoxDecoration(
            color: c.violet.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.violet.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('“$everyday”',
                  key: const ValueKey('decoder-prompt'),
                  style: TextStyle(color: c.lime, fontWeight: FontWeight.w800, fontSize: 20)),
              const SizedBox(height: Gap.xs),
              Text('Which engineering word is this?', style: TextStyle(color: c.textDim, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: Gap.m),
        for (var i = 0; i < _options.length; i++) ...[
          _choice(i),
          const SizedBox(height: Gap.s),
        ],
        if (_answered) ...[
          Text(_results.last ? 'Correct!' : 'Not quite',
              key: const ValueKey('decoder-feedback'),
              style: TextStyle(color: _results.last ? c.lime : c.red, fontWeight: FontWeight.w800)),
          const SizedBox(height: Gap.xs),
          Text('“$answer” = $everyday', style: TextStyle(color: c.textDim, fontSize: 12)),
          const SizedBox(height: Gap.s),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const ValueKey('decoder-next'),
              style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: c.bg),
              onPressed: _next,
              icon: const Icon(Icons.arrow_forward),
              label: Text(_round + 1 >= rounds ? 'See my score' : 'Next word'),
            ),
          ),
        ],
      ],
    );
  }

  /// One choice button: plain while waiting, then the right answer turns lime and a wrong pick red.
  Widget _choice(int i) {
    final c = AppColors.of(context);
    final isAnswer = _options[i] == _order[_round];
    Color border = c.line, fg = c.text;
    Color? bg;
    var width = 1.0;
    if (_answered) {
      if (isAnswer) {
        border = c.lime;
        bg = c.lime.withValues(alpha: 0.14);
        width = 2;
      } else if (_picked == i) {
        border = c.red;
        bg = c.red.withValues(alpha: 0.12);
      } else {
        fg = c.textDim;
      }
    }
    return OutlinedButton(
      key: ValueKey('decoder-choice-$i'),
      onPressed: _answered ? null : () => _pick(i),
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        side: BorderSide(color: border, width: width),
        padding: const EdgeInsets.symmetric(vertical: Gap.m),
      ),
      child: Text(decoderTerms[_options[i]], style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
    );
  }

  Widget _final(AppColors c) {
    final msg = _score >= rounds - 1
        ? 'Expert decoder — those words are in plain clothes now.'
        : _score >= rounds ~/ 2
            ? 'Solid. Flip the cards you missed, then run it again.'
            : 'Back to the cards — every miss is one more costume you have seen through.';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: 'Game over: $_score correct out of $rounds',
          child: Text('Score: $_score / $rounds',
              key: const ValueKey('decoder-final-score'),
              textAlign: TextAlign.center,
              style: TextStyle(color: _score >= rounds ~/ 2 ? c.lime : c.amber, fontWeight: FontWeight.w800, fontSize: 26)),
        ),
        const SizedBox(height: Gap.s),
        Text(msg, textAlign: TextAlign.center, style: TextStyle(color: c.textDim)),
        const SizedBox(height: Gap.m),
        Center(
          child: FilledButton.icon(
            key: const ValueKey('decoder-replay'),
            style: FilledButton.styleFrom(backgroundColor: c.violet, foregroundColor: c.bg),
            onPressed: _replay,
            icon: const Icon(Icons.replay),
            label: const Text('Play again'),
          ),
        ),
      ],
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({super.key, required this.term, required this.flipped, required this.onTap});
  final String term;
  final bool flipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final g = findTerm(term);
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: flipped ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        builder: (context, v, _) {
          final showBack = v > 0.5;
          final angle = v * math.pi;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(showBack ? math.pi : 0),
              child: Container(
                padding: const EdgeInsets.all(Gap.m),
                decoration: BoxDecoration(
                  color: showBack ? c.violet.withValues(alpha: 0.16) : c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: showBack ? c.violet : c.line, width: showBack ? 2 : 1),
                ),
                child: showBack
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g?.everyday ?? '', style: TextStyle(color: c.lime, fontWeight: FontWeight.w800)),
                          const SizedBox(height: Gap.xs),
                          Expanded(
                            child: Text(g?.definition ?? '',
                                overflow: TextOverflow.fade, style: TextStyle(color: c.text, fontSize: 12, height: 1.3)),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.help_outline, color: c.violet.withValues(alpha: 0.7)),
                          const SizedBox(height: Gap.s),
                          Text(term,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: c.text, fontWeight: FontWeight.w800, fontSize: 16)),
                          Text('tap to decode', style: TextStyle(color: c.textDim, fontSize: 11)),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
