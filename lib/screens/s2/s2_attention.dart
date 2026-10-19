import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Who should I listen to?": attention lines from a chosen word to the earlier words it attends to.
/// Two example heads (grammar vs meaning). Weights are hand-set illustrations (labelled). Fact: TR-LLAMA3-ARCH (128 heads).
class S2AttentionScreen extends StatelessWidget {
  const S2AttentionScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_attention',
        children: [_Attention()],
      );
}

const attnWords = ['The', 'sky', 'is', 'blue', 'because', 'light', 'scatters'];

/// attention[head][word] = weights over words 0..word (rows sum to 1). Causal: only earlier words (and itself).
const attnWeights = <List<List<double>>>[
  // Head 0: "meaning" — content words look at related content words.
  [
    [1.0],
    [0.35, 0.65],
    [0.1, 0.6, 0.3],
    [0.05, 0.7, 0.1, 0.15],
    [0.05, 0.25, 0.1, 0.4, 0.2],
    [0.05, 0.3, 0.05, 0.3, 0.1, 0.2],
    [0.02, 0.15, 0.03, 0.15, 0.1, 0.5, 0.05],
  ],
  // Head 1: "grammar" — words look at their neighbours and the subject.
  [
    [1.0],
    [0.8, 0.2],
    [0.2, 0.7, 0.1],
    [0.1, 0.2, 0.6, 0.1],
    [0.05, 0.15, 0.2, 0.5, 0.1],
    [0.05, 0.05, 0.05, 0.15, 0.6, 0.1],
    [0.05, 0.05, 0.05, 0.05, 0.15, 0.6, 0.05],
  ],
];

class _Attention extends StatefulWidget {
  const _Attention();

  @override
  State<_Attention> createState() => _AttentionState();
}

class _AttentionState extends State<_Attention> {
  int _word = 6;
  int _head = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final w = attnWeights[_head][_word];
    var top = 0;
    for (var i = 0; i < w.length; i++) {
      if (i != _word && (top == _word || w[i] > w[top])) top = i;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Tap a word to see who it listens to',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<int>(
                key: const ValueKey('attn-head'),
                segments: const [
                  ButtonSegment(value: 0, label: Text('Meaning head')),
                  ButtonSegment(value: 1, label: Text('Grammar head')),
                ],
                selected: {_head},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _head = s.first),
              ),
              const SizedBox(height: Gap.m),
              LayoutBuilder(
                builder: (context, box) {
                  final slot = box.maxWidth / attnWords.length;
                  return SizedBox(
                    height: 170,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _ArcsPainter(_word, w, slot, c)),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            children: [
                              for (var i = 0; i < attnWords.length; i++)
                                SizedBox(
                                  width: slot,
                                  child: GestureDetector(
                                    key: ValueKey('attn-word-$i'),
                                    onTap: () => setState(() => _word = i),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: i == _word ? c.violet : c.surfaceHi,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FittedBox(
                                        child: Text(attnWords[i],
                                            style: TextStyle(
                                                color: i == _word ? Colors.white : c.text, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: Gap.m),
              Text(
                _word == 0
                    ? '"The" is the first word, so it can only look at itself.'
                    : '"${attnWords[_word]}" listens most to "${attnWords[top]}" (${(w[top] * 100).round()}%).',
                key: const ValueKey('attn-status'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Gap.xs),
              Text('Illustration: real attention weights are learned, not hand-written. Words can only look back, never ahead.',
                  style: TextStyle(color: c.textDim, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Many heads, many clues',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TermText(
                'Like turning your head in a noisy room toward the friend who just said your name, each [[attention]] head '
                'learns to look for a different kind of clue: who is doing what, which word an "it" refers to, what came '
                'just before. Big models run many heads side by side in every layer.',
              ),
              const SizedBox(height: Gap.m),
              const FactCard(value: '128 heads', label: 'per layer in Llama 3 405B, in each of its 126 layers', factId: 'TR-LLAMA3-ARCH'),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArcsPainter extends CustomPainter {
  _ArcsPainter(this.word, this.weights, this.slot, this.c);
  final int word;
  final List<double> weights;
  final double slot;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final base = size.height - 44;
    final from = Offset(slot * (word + 0.5), base);
    for (var i = 0; i < weights.length; i++) {
      if (i == word) continue;
      final to = Offset(slot * (i + 0.5), base);
      final hgt = math.min(base - 6, (from.dx - to.dx).abs() * 0.55 + 20);
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo((from.dx + to.dx) / 2, base - hgt * 1.6, to.dx, to.dy);
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 1 + weights[i] * 12
        ..color = c.violet.withValues(alpha: 0.25 + 0.75 * weights[i]));
    }
  }

  @override
  bool shouldRepaint(_ArcsPainter old) => old.word != word || old.weights != weights || old.c != c;
}
