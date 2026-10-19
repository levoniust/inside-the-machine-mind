import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Tokens become coordinates": a hand-drawn 2-D "map of meaning" (illustration; real
/// embeddings have thousands of numbers). Tap a word to see its nearest neighbours; try king − man + woman
/// or Paris − France + Italy.
class S3EmbeddingsScreen extends StatelessWidget {
  const S3EmbeddingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_embeddings',
        children: [_WordMap()],
      );
}

/// Word → position on a 0..1 square. Clusters: royalty/people, animals, colours, sky & weather, tech, places.
/// Places form a parallelogram: country → capital is the same step for France → Paris and Italy → Rome.
const wordMap = <String, Offset>{
  'king': Offset(0.16, 0.18), 'queen': Offset(0.30, 0.13), 'prince': Offset(0.13, 0.30), 'princess': Offset(0.27, 0.26),
  'man': Offset(0.12, 0.44), 'woman': Offset(0.26, 0.39), 'boy': Offset(0.09, 0.55), 'girl': Offset(0.23, 0.50),
  'cat': Offset(0.70, 0.12), 'dog': Offset(0.80, 0.18), 'kitten': Offset(0.64, 0.22), 'puppy': Offset(0.76, 0.29),
  'blue': Offset(0.58, 0.58), 'red': Offset(0.70, 0.66), 'green': Offset(0.62, 0.72), 'orange': Offset(0.78, 0.56),
  'sky': Offset(0.45, 0.68), 'cloud': Offset(0.38, 0.78), 'sun': Offset(0.50, 0.84), 'rain': Offset(0.33, 0.88),
  'computer': Offset(0.86, 0.84), 'chip': Offset(0.92, 0.74), 'GPU': Offset(0.94, 0.90), 'memory': Offset(0.82, 0.94),
  'France': Offset(0.08, 0.68), 'Paris': Offset(0.11, 0.83), 'Italy': Offset(0.20, 0.70), 'Rome': Offset(0.23, 0.85),
};

/// "[a] − [minus] + [plus]": walk from [a] along the direction that leads from [minus] to [plus].
class Analogy {
  const Analogy(this.a, this.minus, this.plus);
  final String a, minus, plus;
  String get label => '$a − $minus + $plus';
  Offset get result => wordMap[a]! - wordMap[minus]! + wordMap[plus]!;
}

const analogies = [Analogy('king', 'man', 'woman'), Analogy('Paris', 'France', 'Italy')];

List<MapEntry<String, double>> nearest(Offset p, {String? exclude, int n = 3}) {
  final list = [
    for (final e in wordMap.entries)
      if (e.key != exclude) MapEntry(e.key, (e.value - p).distance),
  ]..sort((a, b) => a.value.compareTo(b.value));
  return list.take(n).toList();
}

class _WordMap extends StatefulWidget {
  const _WordMap();

  @override
  State<_WordMap> createState() => _WordMapState();
}

class _WordMapState extends State<_WordMap> with SingleTickerProviderStateMixin {
  String _picked = 'sky';
  int? _analogy; // index into [analogies] while the arithmetic is shown
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  void _startMath(int i) {
    setState(() => _analogy = i);
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 1;
    } else {
      _t.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final near = nearest(wordMap[_picked]!, exclude: _picked);
    final an = _analogy == null ? null : analogies[_analogy!];
    final landed = an == null ? null : nearest(an.result).first.key;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'A map of meaning',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tap a word. Words used in similar ways end up close together.', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              AspectRatio(
                aspectRatio: 1,
                child: LayoutBuilder(
                  builder: (context, box) => GestureDetector(
                    key: const ValueKey('emb-map'),
                    onTapDown: (d) {
                      final p = Offset(d.localPosition.dx / box.maxWidth, d.localPosition.dy / box.maxHeight);
                      setState(() {
                        _picked = nearest(p).first.key;
                        _analogy = null;
                      });
                    },
                    child: Semantics(
                      label: 'Word map. Selected $_picked; nearest: ${near.map((e) => e.key).join(', ')}',
                      child: AnimatedBuilder(
                        animation: _t,
                        builder: (_, _) => CustomPaint(
                          painter: _MapPainter(_picked, near.map((e) => e.key).toList(), an, _t.value, c),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Gap.xs),
              Text('Illustration: a hand-drawn 2-D map. Real embeddings use thousands of numbers per token.',
                  style: TextStyle(color: c.textDim, fontSize: 11)),
              const SizedBox(height: Gap.m),
              Text(
                an != null
                    ? '${an.label} lands right next to "$landed".'
                    : '"$_picked" is closest to: ${near.map((e) => e.key).join(', ')}.',
                key: const ValueKey('emb-status'),
                style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: Gap.m),
              for (var i = 0; i < analogies.length; i++) ...[
                if (i > 0) const SizedBox(height: Gap.s),
                FilledButton.icon(
                  key: ValueKey(i == 0 ? 'emb-math' : 'emb-math${i + 1}'),
                  style: FilledButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
                  onPressed: () => _startMath(i),
                  icon: const Icon(Icons.calculate_outlined),
                  label: Text('Try: ${analogies[i].label}'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        DemoCard(
          title: 'Why coordinates?',
          child: TermText(
            'Once words are [[embeddings|embedding]] (lists of numbers), the model can do math with meaning: directions '
            'on the map capture ideas like "royal", "female" or "capital city of". In Llama 3 405B each token becomes a list of 16,384 '
            'numbers, a point in a space with 16,384 directions instead of the 2 on our map.',
            style: TextStyle(color: c.text),
          ),
        ),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  _MapPainter(this.picked, this.near, this.analogy, this.t, this.c);
  final String picked;
  final List<String> near;
  final Analogy? analogy; // null: show the picked word's neighbours
  final double t;
  final AppColors c;

  bool get showMath => analogy != null;

  @override
  void paint(Canvas canvas, Size size) {
    Offset px(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
    canvas.drawRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), Paint()..color = c.surfaceHi);
    final grid = Paint()
      ..color = c.line.withValues(alpha: 0.5)
      ..strokeWidth = 0.6;
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(size.width * i / 6, 0), Offset(size.width * i / 6, size.height), grid);
      canvas.drawLine(Offset(0, size.height * i / 6), Offset(size.width, size.height * i / 6), grid);
    }
    if (!showMath) {
      for (final n in near) {
        canvas.drawLine(px(wordMap[picked]!), px(wordMap[n]!), Paint()
          ..color = c.magenta.withValues(alpha: 0.7)
          ..strokeWidth = 2);
      }
    } else {
      // a → (− minus) → (+ plus), drawn step by step.
      final k = wordMap[analogy!.a]!, m = wordMap[analogy!.minus]!, w = wordMap[analogy!.plus]!;
      final mid = k + (w - m) * (t.clamp(0.0, 1.0));
      final arrow = Paint()
        ..color = c.lime
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(px(m), px(w), Paint()
        ..color = c.lime.withValues(alpha: 0.35)
        ..strokeWidth = 2);
      canvas.drawLine(px(k), px(mid), arrow);
      canvas.drawCircle(px(mid), 7, Paint()..color = c.lime);
      if (t >= 1) canvas.drawCircle(px(analogy!.result), 16, Paint()..color = c.lime.withValues(alpha: 0.25));
    }
    for (final e in wordMap.entries) {
      final isPicked = e.key == picked && !showMath;
      final isNear = near.contains(e.key) && !showMath;
      final p = px(e.value);
      canvas.drawCircle(p, isPicked ? 6 : 4, Paint()..color = isPicked ? c.magenta : (isNear ? c.cyan : c.textDim));
      final tp = TextPainter(
        text: TextSpan(
          text: e.key,
          style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: isPicked ? 13 : 11,
              fontWeight: isPicked || isNear ? FontWeight.w800 : FontWeight.w500,
              color: isPicked ? c.magenta : (isNear ? c.text : c.textDim)),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, p + Offset(-tp.width / 2, 6));
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => true;
}
