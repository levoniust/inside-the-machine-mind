import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 1 · "How much data lives here?": tokens → bytes → novels → years of reading.
/// Uses TR-TOKEN-WORDS (≈4 characters ≈ ¾ word per token) and TR-READING's reading pace; DC-CC, TR-FINEWEB.
/// A "novel" is assumed to be ~100,000 words (stated on screen).
class S1DataScaleScreen extends StatelessWidget {
  const S1DataScaleScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's1_data_scale',
        children: [_Scale()],
      );
}

double tokensToBytes(double tokens) => tokens * 4; // ~4 characters (bytes of plain English text) per token
double tokensToNovels(double tokens) => tokens * 0.75 / 100000;

class _Scale extends StatefulWidget {
  const _Scale();

  @override
  State<_Scale> createState() => _ScaleState();
}

class _ScaleState extends State<_Scale> {
  double _exp = 9; // log10(tokens)

  static const _marks = [
    ('A long novel', 1.33e5),
    ('A thousand novels', 1.33e8),
    ('One cleaned web snapshot', 15e12 / 96),
    ('FineWeb (15 trillion)', 15e12),
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tokens = math.pow(10, _exp).toDouble();
    final novels = tokensToNovels(tokens);
    final years = tokens * 0.75 / 250 / 60 / 8 / 365;
    final stack = (math.log(novels.clamp(1, 1e12)) / math.ln10 / 12).clamp(0.02, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Slide from a book to the whole web',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LabeledSlider(
                key: const ValueKey('scale-tokens'),
                label: 'Tokens',
                value: _exp,
                min: 5,
                max: 13.2,
                color: c.cyan,
                format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
                onChanged: (v) => setState(() => _exp = v),
              ),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (final (n, t) in _marks)
                    ActionChip(label: Text(n), onPressed: () => setState(() => _exp = math.log(t) / math.ln10)),
                ],
              ),
              const SizedBox(height: Gap.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 70,
                    height: 160,
                    child: Semantics(
                      label: 'Stack of books growing with the data size',
                      child: CustomPaint(painter: _StackPainter(stack, c)),
                    ),
                  ),
                  const SizedBox(width: Gap.m),
                  Expanded(
                    child: StatGrid(
                      columns: 1,
                      children: [
                        StatTile(label: 'As plain text', value: humanBytes(tokensToBytes(tokens)), color: c.cyan, icon: Icons.save_outlined),
                        StatTile(
                            key: const ValueKey('scale-novels'),
                            label: 'Novels (~100,000 words each)',
                            value: humanNumber(novels, digits: novels < 10 ? 1 : 0),
                            color: c.violet,
                            icon: Icons.menu_book_outlined),
                        StatTile(
                            label: 'Years for you to read it',
                            value: years < 1 ? '${(years * 365).toStringAsFixed(0)} days' : humanNumber(years, digits: 0),
                            color: c.amber,
                            icon: Icons.schedule),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Gap.s),
              TermText(
                'One [[token]] is about 4 letters, so text is surprisingly small on disk: all of FineWeb\'s 15 trillion tokens is '
                'roughly 60 TB as plain text, a few big hard drives. Reading it is another matter.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          children: [
            Expanded(child: FactCard(value: '398 TiB', label: 'one raw monthly web snapshot (2.3 billion pages, with all the code and markup)', factId: 'DC-CC')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '15T tokens', label: 'of cleaned text in FineWeb', factId: 'TR-FINEWEB')),
          ],
        ),
      ],
    );
  }
}

class _StackPainter extends CustomPainter {
  _StackPainter(this.fill, this.c);
  final double fill;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final books = (fill * 18).ceil();
    final colors = [c.violet, c.cyan, c.magenta, c.amber, c.lime];
    final bh = size.height / 18;
    for (var i = 0; i < books; i++) {
      final w = size.width * (0.75 + 0.2 * ((i * 37) % 10) / 10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH((size.width - w) / 2, size.height - (i + 1) * bh, w, bh - 1.5), const Radius.circular(2)),
        Paint()..color = colors[i % colors.length].withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(_StackPainter old) => old.fill != fill || old.c != c;
}
