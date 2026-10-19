import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 2 · "Gathering the library": where training text comes from (sources pour into a funnel), and a
/// reading-time calculator (TR-READING: 0.75 words/token, 250 words/min, 8 h/day). Facts: DC-CC, TR-FINEWEB.
class S2LibraryScreen extends StatelessWidget {
  const S2LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's2_library',
        children: [_Funnel(), _ReadingTime()],
      );
}

class _Source {
  const _Source(this.name, this.icon, this.text, this.colorOf);
  final String name, text;
  final IconData icon;
  final Color Function(AppColors) colorOf;
}

final _sources = [
  _Source('The web', Icons.public,
      'Crawlers visit billions of public web pages. One monthly snapshot from the nonprofit Common Crawl holds about 2.3 billion '
          'pages (398 TiB). This is by far the biggest ingredient.',
      (c) => c.cyan),
  _Source('Books', Icons.menu_book_outlined, 'Long, carefully written text teaches the model to follow ideas across many pages.',
      (c) => c.violet),
  _Source('Code', Icons.code, 'Public code from open-source projects teaches the model how programs are written.', (c) => c.lime),
  _Source('Encyclopedias', Icons.auto_stories_outlined, 'Wikipedia-style articles: dense, fact-rich and well organised.',
      (c) => c.amber),
  _Source('Science', Icons.science_outlined, 'Research papers bring maths, technical vocabulary and careful arguments.',
      (c) => c.magenta),
];

class _Funnel extends StatefulWidget {
  const _Funnel();

  @override
  State<_Funnel> createState() => _FunnelState();
}

class _FunnelState extends State<_Funnel> with SingleTickerProviderStateMixin {
  int _sel = 0;
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 0.5;
      _t.stop();
    } else if (!_t.isAnimating) {
      _t.repeat();
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
    final s = _sources[_sel];
    return DemoCard(
      title: 'Everything pours into one funnel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < _sources.length; i++)
                ChoiceChip(
                  key: ValueKey('library-$i'),
                  avatar: Icon(_sources[i].icon, size: 18, color: _sources[i].colorOf(c)),
                  label: Text(_sources[i].name),
                  selected: _sel == i,
                  selectedColor: _sources[i].colorOf(c).withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _sel = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.5,
            child: Semantics(
              label: 'Text from many sources pouring into a funnel and coming out as training data',
              child: AnimatedBuilder(
                animation: _t,
                builder: (_, _) => CustomPaint(painter: _FunnelPainter(_t.value, _sel, c)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Text(s.name, style: TextStyle(color: s.colorOf(c), fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: Gap.xs),
          Text(s.text, key: ValueKey('library-text-$_sel'), style: TextStyle(color: c.text)),
          const SizedBox(height: Gap.m),
          const Row(
            children: [
              Expanded(child: FactCard(value: '2.3 billion', label: 'web pages in one monthly Common Crawl snapshot', factId: 'DC-CC')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '15 trillion', label: '[[tokens|token]] in FineWeb, cleaned from 96 snapshots', factId: 'TR-FINEWEB')),
            ],
          ),
        ],
      ),
    );
  }
}

class _FunnelPainter extends CustomPainter {
  _FunnelPainter(this.t, this.sel, this.c);
  final double t;
  final int sel;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final funnel = Path()
      ..moveTo(w * 0.2, h * 0.35)
      ..lineTo(w * 0.8, h * 0.35)
      ..lineTo(w * 0.56, h * 0.72)
      ..lineTo(w * 0.56, h * 0.88)
      ..lineTo(w * 0.44, h * 0.88)
      ..lineTo(w * 0.44, h * 0.72)
      ..close();
    canvas.drawPath(funnel, Paint()..color = c.surfaceHi);
    canvas.drawPath(funnel, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = c.line);
    final rnd = math.Random(4);
    for (var i = 0; i < 26; i++) {
      final src = i % _sources.length;
      final col = _sources[src].colorOf(c);
      final p = (t + rnd.nextDouble()) % 1.0;
      final startX = w * (0.08 + 0.84 * src / (_sources.length - 1));
      final start = Offset(startX, 0);
      final mouth = Offset(w * 0.5 + (startX - w * 0.5) * 0.4, h * 0.36);
      final out = Offset(w * 0.5, h * 0.92);
      final pos = p < 0.6 ? Offset.lerp(start, mouth, p / 0.6)! : Offset.lerp(mouth, out, (p - 0.6) / 0.4)!;
      final big = src == sel;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: pos, width: big ? 16 : 11, height: big ? 11 : 8), const Radius.circular(2)),
        Paint()..color = col.withValues(alpha: big ? 1 : 0.55),
      );
    }
    final tp = TextPainter(
      text: TextSpan(text: 'training text', style: TextStyle(fontFamily: 'Roboto', fontSize: 11, color: c.textDim)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.6, h * 0.86));
  }

  @override
  bool shouldRepaint(_FunnelPainter old) => old.t != t || old.sel != sel || old.c != c;
}

/// Years for one person to read [tokens] tokens at 250 words/min, 8 hours a day.
double yearsToRead(double tokens) => tokens * 0.75 / 250 / 60 / 8 / 365;

class _ReadingTime extends StatefulWidget {
  const _ReadingTime();

  @override
  State<_ReadingTime> createState() => _ReadingTimeState();
}

class _ReadingTimeState extends State<_ReadingTime> {
  double _exp = math.log(15e12) / math.ln10;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tokens = math.pow(10, _exp).toDouble();
    final years = yearsToRead(tokens);
    return DemoCard(
      title: 'How long would YOU need to read it?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledSlider(
            key: const ValueKey('library-tokens'),
            label: 'Size of the library (tokens)',
            value: _exp,
            min: 6,
            max: 13.3,
            color: c.violet,
            format: (v) => humanNumber(math.pow(10, v).toDouble(), digits: 0),
            onChanged: (v) => setState(() => _exp = v),
          ),
          const SizedBox(height: Gap.s),
          Center(
            child: Text(
              years < 1 ? '${(years * 365).toStringAsFixed(years * 365 < 10 ? 1 : 0)} days' : '${humanNumber(years, digits: 0)} years',
              key: const ValueKey('library-years'),
              style: AppText.mono.copyWith(fontSize: 34, fontWeight: FontWeight.w800, color: c.violet),
            ),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            'Reading 8 hours a day at 250 words a minute (about ¾ of a word per [[token]]). A long novel is roughly 100,000 to '
            '200,000 tokens; today\'s big models read more than ten trillion.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
