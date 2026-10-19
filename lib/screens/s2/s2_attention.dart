import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Who should I listen to?": attention lines from a chosen word to the earlier words it attends to.
/// Three example heads (meaning, grammar and pronoun) over two demo sentences.
/// Weights are hand-set illustrations (labelled). Fact: TR-LLAMA3-ARCH (128 heads).
class S2AttentionScreen extends StatelessWidget {
  const S2AttentionScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_attention',
        children: [_Attention()],
      );
}

const attnWords = ['The', 'sky', 'is', 'blue', 'because', 'light', 'scatters'];

/// The pronoun head's sentence: "it" points back at "robot".
const attnPronounWords = ['The', 'robot', 'said', 'it', 'was', 'happy'];

/// The sentence each head shows; attnWeights[h] must have exactly attnSentences[h].length rows.
const attnSentences = [attnWords, attnWords, attnPronounWords];
const attnHeadNames = ['Meaning head', 'Grammar head', 'Pronoun head'];

/// Word each head opens on (the pronoun head opens on "it", so the pointer back to "robot" shows at once).
const attnDefaultWord = [6, 6, 3];

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
  // Head 2: "pronoun" — "it" looks back at the noun it stands for ("robot").
  [
    [1.0],
    [0.25, 0.75],
    [0.1, 0.15, 0.75],
    [0.05, 0.65, 0.1, 0.2],
    [0.05, 0.4, 0.1, 0.35, 0.1],
    [0.05, 0.15, 0.3, 0.2, 0.1, 0.2],
  ],
];

class _Attention extends StatefulWidget {
  const _Attention();

  @override
  State<_Attention> createState() => _AttentionState();
}

class _AttentionState extends State<_Attention> {
  int _word = attnDefaultWord[0];
  int _head = 0;

  void _selectHead(int h) => setState(() {
        _head = h;
        _word = attnDefaultWord[h];
      });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final words = attnSentences[_head];
    final word = _word < words.length ? _word : words.length - 1;
    final w = attnWeights[_head][word];
    var top = 0;
    for (var i = 0; i < w.length; i++) {
      if (i != word && (top == word || w[i] > w[top])) top = i;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Tap a word to see who it listens to',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var h = 0; h < attnHeadNames.length; h++)
                    ChoiceChip(
                      key: ValueKey('attn-head-$h'),
                      label: Text(attnHeadNames[h]),
                      selected: _head == h,
                      selectedColor: c.violet.withValues(alpha: 0.25),
                      onSelected: (_) => _selectHead(h),
                    ),
                ],
              ),
              const SizedBox(height: Gap.m),
              LayoutBuilder(
                builder: (context, box) {
                  final slot = box.maxWidth / words.length;
                  return SizedBox(
                    height: 170,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Semantics(
                            label: word == 0
                                ? '"${words[word]}" has no earlier words to look at'
                                : '"${words[word]}" is linked most strongly to "${words[top]}"',
                            child: CustomPaint(painter: _ArcsPainter(word, w, slot, c)),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            children: [
                              for (var i = 0; i < words.length; i++)
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
                                        color: i == word ? c.violet : c.surfaceHi,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: FittedBox(
                                        child: Text(words[i],
                                            style: TextStyle(
                                                color: i == word ? Colors.white : c.text, fontWeight: FontWeight.w700)),
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
                word == 0
                    ? '"${words[0]}" is the first word, so it can only look at itself.'
                    : '"${words[word]}" listens most to "${words[top]}" (${(w[top] * 100).round()}%).',
                key: const ValueKey('attn-status'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
              if (_head == 2) ...[
                const SizedBox(height: Gap.xs),
                Text(
                  'A pronoun like "it" has no meaning of its own — the thickest line shows this head pointing it back at '
                  '"robot", the noun it stands for.',
                  style: TextStyle(color: c.textDim, fontSize: 12),
                ),
              ],
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
                'just before. Big models run many heads side by side in every [[layer]] (one of the stacked sections the model is built from).',
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
