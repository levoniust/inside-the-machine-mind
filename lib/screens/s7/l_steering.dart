import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Steering a model (a factual explainer, no recipe): behaviours show up as directions in the model's activations;
/// a control vector pushes along one at run time, abliteration removes one from the weights for good.
class LSteeringScreen extends StatelessWidget {
  const LSteeringScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
    lessonId: 'l_steering',
    children: [
      _Direction(),
      _Knob(),
      _TwoWays(),
      _Costs(),
      FactCard(
        value: '1 direction',
        label: 'controls refusing in 13 open chat models up to 72B',
        factId: 'CU-REFUSAL-DIR',
      ),
      FactCard(
        value: '± a vector',
        label: 'steering: add or subtract an average activation difference at run time',
        factId: 'CU-CAA',
      ),
    ],
  );
}

/// Two clusters of activations (cheerful vs gloomy sentences); the arrow between their centres is the direction.
class _Direction extends StatefulWidget {
  const _Direction();

  @override
  State<_Direction> createState() => _DirectionState();
}

class _DirectionState extends State<_Direction> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    return DemoCard(
      title: 'Ideas are directions inside the model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 190,
            child: CustomPaint(
              key: const ValueKey('steer-plot'),
              painter: _ClusterPainter(shown: _shown, happy: c.amber, sad: c.violet, arrow: accent, text: c.textDim),
            ),
          ),
          const SizedBox(height: Gap.s),
          FilledButton.icon(
            key: const ValueKey('steer-find'),
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
            onPressed: () => setState(() => _shown = !_shown),
            icon: Icon(_shown ? Icons.visibility_off : Icons.arrow_right_alt),
            label: Text(_shown ? 'Hide the direction' : 'Find the direction'),
          ),
          const SizedBox(height: Gap.s),
          Text(
            'Feed the model many cheerful and many gloomy sentences and record its internal activations (drawn here in 2-D; '
            'real ones have thousands of dimensions). Average each group: the arrow from one centre to the other is the '
            '"cheerfulness" direction.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ClusterPainter extends CustomPainter {
  _ClusterPainter({
    required this.shown,
    required this.happy,
    required this.sad,
    required this.arrow,
    required this.text,
  });
  final bool shown;
  final Color happy, sad, arrow, text;

  static const _sadPts = [
    Offset(.18, .30),
    Offset(.25, .45),
    Offset(.12, .52),
    Offset(.30, .62),
    Offset(.22, .70),
    Offset(.35, .40),
    Offset(.17, .40),
  ];
  static const _happyPts = [
    Offset(.68, .25),
    Offset(.78, .35),
    Offset(.85, .22),
    Offset(.72, .48),
    Offset(.88, .42),
    Offset(.80, .55),
    Offset(.65, .38),
  ];

  Offset _mean(List<Offset> p) => p.reduce((a, b) => a + b) / p.length.toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    Offset s(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
    for (final p in _sadPts) {
      canvas.drawCircle(s(p), 6, Paint()..color = sad.withValues(alpha: 0.8));
    }
    for (final p in _happyPts) {
      canvas.drawCircle(s(p), 6, Paint()..color = happy.withValues(alpha: 0.8));
    }
    _label(canvas, 'gloomy sentences', s(const Offset(.08, .80)), sad);
    _label(canvas, 'cheerful sentences', s(const Offset(.62, .66)), happy);
    if (!shown) return;
    final a = s(_mean(_sadPts)), b = s(_mean(_happyPts));
    final paint = Paint()
      ..color = arrow
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(a, b, paint);
    final d = (b - a) / (b - a).distance;
    final n = Offset(-d.dy, d.dx);
    canvas.drawPath(
      Path()
        ..moveTo(b.dx, b.dy)
        ..lineTo((b - d * 14 + n * 7).dx, (b - d * 14 + n * 7).dy)
        ..lineTo((b - d * 14 - n * 7).dx, (b - d * 14 - n * 7).dy)
        ..close(),
      Paint()..color = arrow,
    );
    _label(canvas, 'the direction', (a + b) / 2 + const Offset(-30, -22), arrow);
  }

  void _label(Canvas canvas, String t, Offset at, Color color) {
    (TextPainter(
      text: TextSpan(
        text: t,
        style: TextStyle(fontSize: 11, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, at);
  }

  @override
  bool shouldRepaint(_ClusterPainter old) => old.shown != shown || old.arrow != arrow;
}

/// Pushing along the direction while the model writes (pre-written examples, as a demo).
class _Knob extends StatefulWidget {
  const _Knob();

  @override
  State<_Knob> createState() => _KnobState();
}

class _KnobState extends State<_Knob> {
  static const _lines = [
    'Grey again. The rain will probably last all week, like it always does.',
    'It\'s cloudy, and rain is likely later. Bring a coat.',
    'Cloudy with a chance of rain this afternoon. Temperatures around 14 °C.',
    'A few clouds, maybe some rain later, a fine day for a walk with an umbrella.',
    'What a lovely soft grey morning! A little rain will make everything sparkle.',
  ];
  double _k = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    return DemoCard(
      title: 'Turn the knob',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Prompt: "Describe today\'s weather."', style: AppText.mono.copyWith(fontSize: 12, color: c.textDim)),
          const SizedBox(height: Gap.s),
          Container(
            padding: const EdgeInsets.all(Gap.m),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(12)),
            child: Text(_lines[(_k + 2).round()], key: const ValueKey('steer-out')),
          ),
          LabeledSlider(
            key: const ValueKey('steer-k'),
            label: 'Push along "cheerfulness"',
            value: _k,
            min: -2,
            max: 2,
            divisions: 4,
            format: (v) => v > 0 ? '+${v.round()}' : '${v.round()}',
            color: accent,
            onChanged: (v) => setState(() => _k = v),
          ),
          Text(
            'Pre-written to show the idea. Push too hard and real models start writing nonsense: the strength needs care.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TwoWays extends StatelessWidget {
  const _TwoWays();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    Widget box(String title, String body, IconData icon) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(Gap.m),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent),
            const SizedBox(height: Gap.xs),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: Gap.xs),
            Text(body, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
    return DemoCard(
      title: 'Two ways to use a direction',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          box(
            'Control vector',
            'Added while the model runs, at a strength you choose, and removed by just not adding it. '
                'llama.cpp can load one with --control-vector.',
            Icons.tune,
          ),
          const SizedBox(width: Gap.s),
          box(
            'Abliteration',
            'The direction is removed from the weights themselves, permanently. Used on the "refusal" '
                'direction to make so-called uncensored models.',
            Icons.content_cut,
          ),
        ],
      ),
    );
  }
}

class _Costs extends StatelessWidget {
  const _Costs();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c.amber),
          const SizedBox(width: Gap.s),
          Expanded(child: Text(text)),
        ],
      ),
    );
    return DemoCard(
      title: 'What it costs',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Icons.trending_down,
            'Quality: a direction is rarely about only one thing, so pushing or cutting it can blunt other skills.',
          ),
          row(
            Icons.shield_outlined,
            'Safety: removing refusal removes a safety layer the makers trained in. The model will then help with harmful requests too.',
          ),
          row(
            Icons.gavel_outlined,
            'Responsibility: the licence and the law still apply. What the model says is now on the person running it.',
          ),
          row(
            Icons.science_outlined,
            'Why researchers care: it shows how thin today\'s safety training can be, and helps them understand and build sturdier models.',
          ),
        ],
      ),
    );
  }
}
