import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// How a picture appears from noise: five panels (photo → static, undo one step, words steer, Denoise it with steps
/// and seeds, labels and watermarks). Pictures are drawn shapes plus a seeded noise layer, so it all works offline;
/// big shapes clear before details, as the DDPM paper observed. Facts PIC-*.
class EPicturesScreen extends StatelessWidget {
  const EPicturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LessonScaffold(
      lessonId: 'e_pictures',
      children: [_ToStatic(), _UndoOneStep(), _WordsSteer(), _DenoiseIt(), _Labels()],
    );
  }
}

enum _Subject { lighthouse, cat }

/// Draws [subject] at [clarity] (0 = pure static, 1 = clear). Big shapes fade in first, details last; a noise layer
/// seeded by [seed] covers the rest. [seed] also picks small variations (fur or stripe colour).
class _PicPainter extends CustomPainter {
  _PicPainter({required this.subject, required this.clarity, required this.seed});
  final _Subject subject;
  final double clarity;
  final int seed;

  static const _furs = [Color(0xFFE08A3C), Color(0xFF7D7F86), Color(0xFF2E2E33)];
  static const _stripes = [Color(0xFFD23B3B), Color(0xFF2F6FD6), Color(0xFF2E9A55)];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final coarse = (clarity * 1.6).clamp(0.0, 1.0);
    final fine = ((clarity - 0.5) * 2).clamp(0.0, 1.0);
    final p = Paint();
    canvas.drawRect(Offset.zero & size, p..color = const Color(0xFF888888));
    Color a(Color col, double alpha) => col.withValues(alpha: alpha);

    if (subject == _Subject.lighthouse) {
      canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.7), p..color = a(const Color(0xFF8EC5F0), coarse));
      canvas.drawRect(Rect.fromLTWH(0, h * 0.7, w, h * 0.3), p..color = a(const Color(0xFF1F5E8C), coarse));
      final tower = Path()
        ..moveTo(w * 0.42, h * 0.78)
        ..lineTo(w * 0.47, h * 0.25)
        ..lineTo(w * 0.53, h * 0.25)
        ..lineTo(w * 0.58, h * 0.78)
        ..close();
      canvas.drawPath(tower, p..color = a(Colors.white, coarse));
      final stripe = _stripes[seed % _stripes.length];
      for (final y in [0.35, 0.52, 0.68]) {
        final t = (y - 0.25) / 0.53;
        final half = 0.03 + 0.05 * t;
        canvas.drawRect(
          Rect.fromLTRB(w * (0.5 - half), h * y, w * (0.5 + half), h * (y + 0.06)),
          p..color = a(stripe, fine),
        );
      }
      canvas.drawRect(
        Rect.fromLTWH(w * 0.46, h * 0.18, w * 0.08, h * 0.07),
        p..color = a(const Color(0xFFFFE066), fine),
      );
      final beam = Path()
        ..moveTo(w * 0.54, h * 0.2)
        ..lineTo(w * 0.98, h * 0.08)
        ..lineTo(w * 0.98, h * 0.3)
        ..close();
      canvas.drawPath(beam, p..color = a(const Color(0xFFFFE066), fine * 0.45));
    } else {
      canvas.drawRect(Offset.zero & size, p..color = a(const Color(0xFFF3E3C7), coarse));
      final fur = _furs[seed % _furs.length];
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.82), width: w * 0.55, height: h * 0.4),
        p..color = a(fur, coarse),
      );
      canvas.drawCircle(Offset(w * 0.5, h * 0.45), h * 0.24, p..color = a(fur, coarse));
      for (final s in [-1.0, 1.0]) {
        final ear = Path()
          ..moveTo(w * 0.5 + s * h * 0.2, h * 0.32)
          ..lineTo(w * 0.5 + s * h * 0.22, h * 0.1)
          ..lineTo(w * 0.5 + s * h * 0.06, h * 0.24)
          ..close();
        canvas.drawPath(ear, p..color = a(fur, coarse));
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.5 + s * h * 0.09, h * 0.42), width: h * 0.08, height: h * 0.1),
          p..color = a(const Color(0xFF9BD35A), fine),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(w * 0.5 + s * h * 0.09, h * 0.42), width: h * 0.025, height: h * 0.08),
          p..color = a(Colors.black, fine),
        );
        final whisker = Paint()
          ..color = a(Colors.white, fine)
          ..strokeWidth = 1.5;
        for (final dy in [-0.02, 0.02]) {
          canvas.drawLine(
            Offset(w * 0.5 + s * h * 0.08, h * (0.53 + dy)),
            Offset(w * 0.5 + s * h * 0.3, h * (0.51 + dy * 2)),
            whisker,
          );
        }
      }
      final nose = Path()
        ..moveTo(w * 0.5 - h * 0.03, h * 0.5)
        ..lineTo(w * 0.5 + h * 0.03, h * 0.5)
        ..lineTo(w * 0.5, h * 0.54)
        ..close();
      canvas.drawPath(nose, p..color = a(const Color(0xFFE88A9A), fine));
    }

    // The noise layer: the same random speckles for the same seed.
    final noise = 1 - clarity;
    if (noise > 0) {
      final r = math.Random(seed * 7919 + 1);
      final cell = math.max(4.0, w / 60);
      for (var y = 0.0; y < h; y += cell) {
        for (var x = 0.0; x < w; x += cell) {
          final v = r.nextInt(256);
          p.color = Color.fromARGB((noise * 255).round(), v, (v + r.nextInt(60)) % 256, (v + r.nextInt(90)) % 256);
          canvas.drawRect(Rect.fromLTWH(x, y, cell, cell), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PicPainter old) => old.clarity != clarity || old.subject != subject || old.seed != seed;
}

Widget _pic(_Subject s, double clarity, int seed, {Key? key, double height = 180}) => ClipRRect(
  key: key,
  borderRadius: BorderRadius.circular(10),
  child: SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: _PicPainter(subject: s, clarity: clarity, seed: seed),
    ),
  ),
);

// ---------------------------------------------------------------------------------------------------------------
// Panel 1.

class _ToStatic extends StatefulWidget {
  const _ToStatic();

  @override
  State<_ToStatic> createState() => _ToStaticState();
}

class _ToStaticState extends State<_ToStatic> {
  double _noise = 0;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(11);
    return DemoCard(
      title: '1. Turn a picture into static',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Training starts the easy way round. Take a real picture and add a little random noise. Then a little more. '
            'Keep going until it\'s pure TV static.',
          ),
          const SizedBox(height: Gap.s),
          _pic(_Subject.lighthouse, 1 - _noise, 3, key: const ValueKey('pic-static')),
          LabeledSlider(
            key: const ValueKey('pic-noise'),
            label: 'Noise added',
            value: _noise,
            min: 0,
            max: 1,
            divisions: 20,
            format: (v) => '${(v * 100).round()}%',
            color: accent,
            onChanged: (v) => setState(() => _noise = v),
          ),
          const FactCard(
            value: '1,000 steps',
            label: 'from picture to static, in the 2020 paper that started it',
            factId: 'PIC-NOISE',
          ),
        ],
      ),
    );
  }
}

// Panel 2.

class _UndoOneStep extends StatefulWidget {
  const _UndoOneStep();

  @override
  State<_UndoOneStep> createState() => _UndoOneStepState();
}

class _UndoOneStepState extends State<_UndoOneStep> {
  int _i = 0;
  static const _text = [
    'The model is shown a noisy picture and asked one small question: "which part of this is the noise?"',
    'It guesses. Its guess is compared with the noise that was really added, and it\'s nudged to guess better next time.',
    'Lots of pictures, every amount of noise, over and over. Now it can take any slightly noisy picture and make it a '
        'little cleaner.',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final clarity = [0.45, 0.45, 0.55][_i];
    return DemoCard(
      title: '2. Learn to undo one small step',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _pic(_Subject.lighthouse, clarity, 5, height: 110)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.arrow_forward, color: c.textDim),
              ),
              Expanded(child: _pic(_Subject.lighthouse, clarity + 0.12, 5, height: 110)),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(_text[_i], key: ValueKey('pic-undo-$_i')),
          const SizedBox(height: Gap.s),
          StepControls(step: _i, count: _text.length, onStep: (i) => setState(() => _i = i)),
        ],
      ),
    );
  }
}

// Panel 3.

class _WordsSteer extends StatelessWidget {
  const _WordsSteer();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: '3. Your words steer every step',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'Think of a sculptor told "a cat" and handed a rough block. Each chip of the chisel is guided by those words. '
            'In an image model, your [[prompt]] is turned into numbers, and at every step the model uses them (through '
            '[[attention]]) to decide which noise to remove.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'To save work, modern models clean up a small compressed version of the picture instead of every pixel, then '
            'blow it up at the end. That idea (latent diffusion) cut the computing cost a lot.',
          ),
          SizedBox(height: Gap.s),
          FactCard(
            value: 'Latent diffusion',
            label: 'denoise a compressed picture, steered by text',
            factId: 'PIC-LATENT',
          ),
        ],
      ),
    );
  }
}

// Panel 4: the game.

class _DenoiseIt extends StatefulWidget {
  const _DenoiseIt();

  @override
  State<_DenoiseIt> createState() => _DenoiseItState();
}

class _DenoiseItState extends State<_DenoiseIt> {
  static const _total = 30;
  int _step = 0;
  _Subject _subject = _Subject.cat;
  int _seed = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final clarity = _step / _total;
    final stage = _step == 0
        ? 'Pure static. Every picture starts here.'
        : _step < 12
        ? 'Big shapes first: you can tell roughly where things are.'
        : _step < _total
        ? 'Now the details: edges, colours, small features.'
        : 'Done: a ${_subject == _Subject.cat ? 'cat' : 'lighthouse'}, from the same static.';
    return DemoCard(
      title: '4. Denoise it',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Subject>(
            segments: const [
              ButtonSegment(value: _Subject.cat, label: Text('"a cat"')),
              ButtonSegment(value: _Subject.lighthouse, label: Text('"a lighthouse"')),
            ],
            selected: {_subject},
            onSelectionChanged: (s) => setState(() => _subject = s.first),
          ),
          const SizedBox(height: Gap.s),
          _pic(_subject, clarity, _seed, key: ValueKey('pic-game-${_subject.name}-$_seed-$_step'), height: 220),
          LabeledSlider(
            key: const ValueKey('pic-steps'),
            label: 'Steps done',
            value: _step.toDouble(),
            min: 0,
            max: _total.toDouble(),
            divisions: _total,
            format: (v) => '${v.round()} / $_total',
            color: accent,
            onChanged: (v) => setState(() => _step = v.round()),
          ),
          Text(
            stage,
            key: const ValueKey('pic-stage'),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: Gap.s),
          OutlinedButton.icon(
            key: const ValueKey('pic-seed'),
            onPressed: () => setState(() => _seed++),
            icon: const Icon(Icons.casino_outlined),
            label: Text('New seed (now ${_seed + 1})'),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'The seed picks the starting static. Same words + new seed = a different picture (here, a different fur or '
            'stripe colour). Same words + same seed = the same picture again. This toy uses $_total steps; the original '
            'method used 1,000.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'Big shapes first',
            label: 'then details, as researchers saw in their models',
            factId: 'PIC-START',
          ),
        ],
      ),
    );
  }
}

// Panel 5.

class _Labels extends StatelessWidget {
  const _Labels();

  @override
  Widget build(BuildContext context) {
    return const DemoCard(
      title: '5. Labels and invisible watermarks',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'AI pictures can look real, so makers add two kinds of tags. A **watermark** hides a pattern in the pixels '
            'themselves; a **content credential** is a signed record attached to the file saying where it came from and '
            'whether AI was used.',
          ),
          SizedBox(height: Gap.s),
          TermText(
            'Neither is a lie detector: a credential shows its record is intact and signed, not that the picture is '
            'true, and a missing tag doesn\'t prove a photo is real. Check the source too.',
          ),
          SizedBox(height: Gap.s),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(
                  value: 'SynthID',
                  label: 'invisible watermark that survives filters and JPEG',
                  factId: 'PIC-SYNTHID',
                ),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: 'C2PA', label: 'signed record of origin, edits and AI use', factId: 'PIC-C2PA'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
