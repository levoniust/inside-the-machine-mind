import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Beyond words": images and sound become tokens too (multimodal), and agents run a loop of
/// think → use a tool → look at the result. Facts: TL-CLAUDECODE, TL-OPUS55.
class S3BeyondTextScreen extends StatelessWidget {
  const S3BeyondTextScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_beyond_text',
        children: [_Senses(), _AgentLoop()],
      );
}

enum _Mode { image, sound }

class _Senses extends StatefulWidget {
  const _Senses();

  @override
  State<_Senses> createState() => _SensesState();
}

class _SensesState extends State<_Senses> {
  _Mode _mode = _Mode.image;
  bool _chopped = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Everything becomes tokens',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Mode>(
            key: const ValueKey('beyond-mode'),
            segments: const [
              ButtonSegment(value: _Mode.image, label: Text('A picture'), icon: Icon(Icons.image_outlined)),
              ButtonSegment(value: _Mode.sound, label: Text('A voice'), icon: Icon(Icons.graphic_eq)),
            ],
            selected: {_mode},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() {
              _mode = s.first;
              _chopped = false;
            }),
          ),
          const SizedBox(height: Gap.m),
          AspectRatio(
            aspectRatio: 1.8,
            child: Semantics(
              label: _mode == _Mode.image ? 'A picture split into patches' : 'A sound wave split into slices',
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: _chopped ? 1 : 0),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, _) => CustomPaint(painter: _SensePainter(_mode, v, c)),
              ),
            ),
          ),
          const SizedBox(height: Gap.m),
          Center(
            child: FilledButton.icon(
              key: const ValueKey('beyond-chop'),
              style: FilledButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
              onPressed: () => setState(() => _chopped = !_chopped),
              icon: Icon(_chopped ? Icons.undo : Icons.grid_view),
              label: Text(_chopped ? 'Put it back together' : 'Chop it into tokens'),
            ),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            _mode == _Mode.image
                ? 'A picture is cut into small squares (patches). Each patch becomes a list of numbers, just like a word token, '
                    'so the same model can "read" images. That\'s what [[multimodal]] means.'
                : 'Sound is cut into tiny slices of time. Each slice becomes a token, so a model can listen, and even answer '
                    'back by producing sound tokens.',
            key: ValueKey('beyond-caption-${_mode.name}'),
            style: TextStyle(color: c.text),
          ),
        ],
      ),
    );
  }
}

class _SensePainter extends CustomPainter {
  _SensePainter(this.mode, this.v, this.c);
  final _Mode mode;
  final double v;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    if (mode == _Mode.image) {
      // A tiny "sky" picture: gradient sky, sun, hill — split into 6×4 patches that drift apart.
      const cols = 6, rows = 4;
      final pw = size.width / cols, ph = size.height / rows;
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < cols; x++) {
          final gap = v * 6;
          final rect = Rect.fromLTWH(x * pw + gap * (x - 2.5) * 0.6, y * ph + gap * (y - 1.5) * 0.6, pw, ph).deflate(v * 2);
          canvas.save();
          canvas.clipRect(rect);
          canvas.translate(rect.left - x * pw, rect.top - y * ph);
          _picture(canvas, size);
          canvas.restore();
          if (v > 0.5) {
            canvas.drawRect(rect, Paint()
              ..style = PaintingStyle.stroke
              ..color = c.magenta.withValues(alpha: v));
          }
        }
      }
    } else {
      final mid = size.height / 2;
      final path = Path();
      for (var i = 0; i <= 240; i++) {
        final x = i / 240 * size.width;
        final env = math.sin(i / 240 * math.pi);
        final y = mid + math.sin(i * 0.35) * math.sin(i * 0.05) * size.height * 0.38 * env;
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      canvas.drawPath(path, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = c.cyan);
      if (v > 0) {
        for (var k = 1; k < 16; k++) {
          final x = k / 16 * size.width;
          canvas.drawLine(Offset(x, size.height * 0.08), Offset(x, size.height * 0.92),
              Paint()..color = c.magenta.withValues(alpha: 0.7 * v)..strokeWidth = 1.5);
        }
      }
    }
  }

  void _picture(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF1E6FD9), const Color(0xFF8CC8FF)]).createShader(r));
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.28), size.height * 0.14, Paint()..color = const Color(0xFFFFD34D));
    final hill = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.45, size.width, size.height * 0.85)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF2E9E55));
  }

  @override
  bool shouldRepaint(_SensePainter old) => old.v != v || old.mode != mode || old.c != c;
}

const _agentSteps = [
  ('Think', Icons.psychology_outlined, 'Goal: "The weather test is failing; fix it." First, I need to see the error.'),
  ('Use a tool', Icons.terminal, 'Runs the tests: 1 failing: expected 21 °C, got 69.8. Looks like a °F/°C mix-up.'),
  ('Look', Icons.visibility_outlined, 'Opens weather.py and finds the line that forgets to convert Fahrenheit to Celsius.'),
  ('Act', Icons.edit_outlined, 'Edits the line to convert properly.'),
  ('Check', Icons.check_circle_outline, 'Runs the tests again: all pass. Done, and it explains what it changed.'),
];

class _AgentLoop extends StatefulWidget {
  const _AgentLoop();

  @override
  State<_AgentLoop> createState() => _AgentLoopState();
}

class _AgentLoopState extends State<_AgentLoop> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Agents: thinking in a loop with tools',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TermText(
            'An [[agent]] is a model in a loop: it thinks, uses a tool (search, run code, open a file), looks at the result, '
            'and repeats until the job is done. Here is a coding agent fixing a bug (a made-up example):',
            style: TextStyle(color: c.textDim),
          ),
          const SizedBox(height: Gap.m),
          for (var i = 0; i < _agentSteps.length; i++)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: i <= _step ? 1 : 0.25,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: i == _step ? c.magenta : c.surfaceHi,
                  child: Icon(_agentSteps[i].$2, color: i == _step ? Colors.white : c.textDim, size: 20),
                ),
                title: Text(_agentSteps[i].$1, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(_agentSteps[i].$3),
              ),
            ),
          StepControls(step: _step, count: _agentSteps.length, onStep: (i) => setState(() => _step = i)),
          const SizedBox(height: Gap.m),
          const Row(
            children: [
              Expanded(child: FactCard(value: '2025', label: 'Claude Code brought coding agents to the terminal', factId: 'TL-CLAUDECODE')),
              SizedBox(width: Gap.m),
              Expanded(child: FactCard(value: '18+ hours', label: 'an unattended agent session reported with Opus 5.5', factId: 'TL-OPUS55')),
            ],
          ),
        ],
      ),
    );
  }
}
