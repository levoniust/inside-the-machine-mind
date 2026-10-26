import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Which assistant for what?: a wheel of everyday tasks. Tap one and the wheel shows the kind of tool that
/// fits, which big apps offer it, and what to watch out for. Deliberately no ranking (real app names, as of
/// Oct 2026; the privacy facts behind it are PRIV-* / FAKE-*).
class EWhichScreen extends StatelessWidget {
  const EWhichScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 'e_which',
        children: [_TaskWheel(), _WatchOuts()],
      );
}

enum _ToolKind { chat, image, voice, code, search }

class _Task {
  const _Task(this.label, this.icon, this.kind, this.tool, this.apps, this.watch);
  final String label;
  final IconData icon;
  final _ToolKind kind;
  final String tool;
  final String apps;
  final String watch;
}

const _tasks = [
  _Task('Write', Icons.edit_outlined, _ToolKind.chat, 'Chat assistant', 'ChatGPT · Gemini · Copilot · Claude',
      'It can be confidently wrong about facts — check anything that matters.'),
  _Task('Summarise', Icons.description_outlined, _ToolKind.chat, 'Chat assistant (paste or upload the text)',
      'ChatGPT · Gemini · Claude · Copilot', 'A summary can quietly drop a number or a caveat — skim the original too.'),
  _Task('Picture', Icons.image_outlined, _ToolKind.image, 'Image generator', 'ChatGPT · Gemini · Copilot · Meta AI',
      'An image generator will not answer your questions — and it still fumbles hands and spelling.'),
  _Task('Talk', Icons.record_voice_over_outlined, _ToolKind.voice, 'Voice mode', 'ChatGPT · Gemini · Copilot',
      'Hands-free and good in a car — but never watch a screen while driving.'),
  _Task('Code', Icons.code_outlined, _ToolKind.code, 'Coding assistant', 'GitHub Copilot · Claude Code · ChatGPT',
      'It writes confident bugs. Read the code and run it before trusting it.'),
  _Task('News', Icons.search_outlined, _ToolKind.search, 'AI search (a model that reads the web)',
      'Perplexity · Copilot · Gemini · ChatGPT',
      'A chat assistant without web search does not know today\'s news — follow its links.'),
  _Task('Photo', Icons.photo_camera_outlined, _ToolKind.chat, 'Chat assistant that can see images',
      'ChatGPT · Gemini · Claude · Copilot', 'Small text and fine detail get misread — crop close to the problem.'),
];

Color _toolColor(AppColors c, _ToolKind k) => switch (k) {
      _ToolKind.chat => c.cyan,
      _ToolKind.image => c.magenta,
      _ToolKind.voice => c.violet,
      _ToolKind.code => c.lime,
      _ToolKind.search => c.amber,
    };

class _TaskWheel extends StatefulWidget {
  const _TaskWheel();

  @override
  State<_TaskWheel> createState() => _TaskWheelState();
}

class _TaskWheelState extends State<_TaskWheel> {
  int _task = 0;
  final GlobalKey _wheelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final t = _tasks[_task];
    final color = _toolColor(c, t.kind);
    return DemoCard(
      title: 'What are you trying to do?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Semantics(
                label: 'Wheel of ${_tasks.length} everyday tasks; the selected one is ${t.label}, which fits a $toolLower.',
                child: GestureDetector(
                  key: const ValueKey('which-wheel'),
                  onTapUp: (d) => _spinTo(d.localPosition),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(key: _wheelKey, painter: _WheelPainter(_task, c)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < _tasks.length; i++)
                ChoiceChip(
                  key: ValueKey('which-task-$i'),
                  label: Text(_tasks[i].label),
                  selected: _task == i,
                  selectedColor: _toolColor(c, _tasks[i].kind).withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _task = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Container(
            key: ValueKey('which-detail-$_task'),
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(t.icon, color: color, size: 20),
                    const SizedBox(width: Gap.s),
                    Expanded(
                      child: Text('The tool that fits: $toolLower',
                          style: TextStyle(color: color, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.xs),
                Text('Big apps with it: ${t.apps}', style: const TextStyle(fontSize: 13.5)),
                const SizedBox(height: Gap.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.remove_red_eye_outlined, color: c.amber, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Watch out: ${t.watch}',
                          style: TextStyle(color: c.textDim, fontSize: 12.5, fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get toolLower => _tasks[_task].tool.toLowerCase();

  /// Pick the wedge under the tap (outside the hub circle). [p] is local to the wheel box.
  void _spinTo(Offset p) {
    final n = _tasks.length;
    final box = _wheelKey.currentContext?.size;
    if (box == null) return;
    final center = Offset(box.width / 2, box.height / 2);
    final d = p - center;
    final r = math.min(box.width, box.height) * 0.46;
    if (d.distance < r * 0.4 || d.distance > r * 1.15) return;
    final rel = (math.atan2(d.dy, d.dx) + math.pi / 2) % (math.pi * 2);
    setState(() => _task = (rel / (math.pi * 2 / n)).floor() % n);
  }
}

/// Seven wedges; the selected one is filled in its tool colour, with its icon in the hub.
class _WheelPainter extends CustomPainter {
  _WheelPainter(this.selected, this.c);
  final int selected;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    final n = _tasks.length;
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.46;
    final wedge = math.pi * 2 / n;
    for (var i = 0; i < n; i++) {
      final start = -math.pi / 2 + i * wedge;
      final color = _toolColor(c, _tasks[i].kind);
      final on = i == selected;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: r), start, wedge, false)
        ..close();
      canvas.drawPath(path, Paint()..color = on ? color.withValues(alpha: 0.3) : c.surfaceHi);
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = on ? 2 : 1
            ..color = on ? color : c.line);
      // Label near the rim, upright.
      final mid = start + wedge / 2;
      final labelPos = center + Offset(math.cos(mid), math.sin(mid)) * r * 0.72;
      _text(canvas, _tasks[i].label, labelPos,
          fontSize: 11.5, color: on ? c.text : c.textDim, weight: on ? FontWeight.w800 : FontWeight.w500);
    }
    // Hub with the selected task's icon.
    canvas.drawCircle(center, r * 0.34, Paint()..color = c.surface);
    canvas.drawCircle(center, r * 0.34,
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = _toolColor(c, _tasks[selected].kind));
    final t = _tasks[selected];
    final glyph = TextPainter(
      text: TextSpan(
          text: String.fromCharCode(t.icon.codePoint),
          style: TextStyle(
              fontSize: r * 0.3,
              fontFamily: t.icon.fontFamily,
              package: t.icon.fontPackage,
              color: _toolColor(c, t.kind))),
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(canvas, center - Offset(glyph.width / 2, glyph.height / 2));
  }

  void _text(Canvas canvas, String s, Offset center,
      {required double fontSize, required Color color, FontWeight weight = FontWeight.w400}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: fontSize, color: color, fontWeight: weight)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.selected != selected || old.c != c;
}

class _WatchOuts extends StatelessWidget {
  const _WatchOuts();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const items = [
      (Icons.category_outlined, 'The task picks the tool',
          'Match the shape of the job — words, a picture, your voice, code, today\'s news — not the logo.'),
      (Icons.swap_horiz, 'There is no ranking here on purpose',
          'The apps trade places every few months. What stays true is which kind of tool does which job.'),
      (Icons.groups_outlined, 'You do not have to choose a team',
          'Most of the big assistants overlap on everyday jobs; people keep more than one open.'),
      (Icons.privacy_tip_outlined, 'Whatever you pick, mind the settings',
          'The training and history switches are different in every app — "Where your words go" shows the paths.'),
    ];
    return DemoCard(
      title: 'Rules of thumb',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (icon, title, detail) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: c.section(5), size: 20),
                  const SizedBox(width: Gap.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(detail, style: TextStyle(color: c.textDim, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
