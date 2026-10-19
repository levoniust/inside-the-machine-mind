import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/glossary.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · "The word decoder": 16 flip cards, engineering term on the front, everyday word and
/// meaning on the back (from the glossary).
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

class _Deck extends StatefulWidget {
  const _Deck();

  @override
  State<_Deck> createState() => _DeckState();
}

class _DeckState extends State<_Deck> {
  final Set<int> _flipped = {};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final cols = MediaQuery.sizeOf(context).width >= 600 ? 4 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
