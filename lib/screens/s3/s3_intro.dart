import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 3 · "Ask the question": Bit types the question, you press send, and a packet flies into the
/// machine; then a preview of the stops ahead in this section.
class S3IntroScreen extends StatelessWidget {
  const S3IntroScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_intro',
        children: [_Send(), _Preview()],
      );
}

class _Send extends StatefulWidget {
  const _Send();

  @override
  State<_Send> createState() => _SendState();
}

class _SendState extends State<_Send> with TickerProviderStateMixin {
  static const question = 'Why is the sky blue?';
  late final AnimationController _type = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  bool _sent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _type.value = 1;
    } else if (_type.value == 0) {
      _type.forward();
    }
  }

  void _sendIt() {
    setState(() => _sent = true);
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _fly.value = 1;
    } else {
      _fly.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _type.dispose();
    _fly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: AnimatedBuilder(
              animation: _fly,
              builder: (_, _) => CustomPaint(painter: _FlyPainter(_sent ? _fly.value : 0, c)),
            ),
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.m),
                  decoration: BoxDecoration(
                    color: c.surfaceHi,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: c.magenta.withValues(alpha: 0.5)),
                  ),
                  child: AnimatedBuilder(
                    animation: _type,
                    builder: (_, _) => Text(
                      _sent ? 'Message sent…' : question.substring(0, (question.length * _type.value).round()),
                      key: const ValueKey('intro-box'),
                      style: TextStyle(color: _sent ? c.textDim : c.text, fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Gap.s),
              IconButton.filled(
                key: const ValueKey('intro-send'),
                tooltip: 'Send',
                style: IconButton.styleFrom(backgroundColor: c.magenta, foregroundColor: Colors.white),
                onPressed: _sent ? null : _sendIt,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: _sent ? 1 : 0,
            child: Text('Your question is inside. Let\'s follow it, step by step.',
                key: const ValueKey('intro-sent'), style: TextStyle(color: c.lime, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _FlyPainter extends CustomPainter {
  _FlyPainter(this.t, this.c);
  final double t;
  final AppColors c;

  @override
  void paint(Canvas canvas, Size size) {
    // The "mind": a glowing chip on the right.
    final chip = Rect.fromCenter(center: Offset(size.width * 0.82, size.height * 0.45), width: 74, height: 74);
    final glow = 0.3 + 0.5 * t;
    canvas.drawRRect(RRect.fromRectAndRadius(chip.inflate(10), const Radius.circular(18)),
        Paint()..color = c.magenta.withValues(alpha: 0.15 * glow)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
    canvas.drawRRect(RRect.fromRectAndRadius(chip, const Radius.circular(12)), Paint()..color = c.surfaceHi);
    canvas.drawRRect(RRect.fromRectAndRadius(chip, const Radius.circular(12)), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = c.magenta.withValues(alpha: 0.5 + 0.5 * t));
    for (var i = 0; i < 5; i++) {
      final y = chip.top + 12 + i * 12.5;
      canvas.drawLine(Offset(chip.left - 10, y), Offset(chip.left, y), Paint()..color = c.line..strokeWidth = 2);
      canvas.drawLine(Offset(chip.right, y), Offset(chip.right + 10, y), Paint()..color = c.line..strokeWidth = 2);
    }
    // The packet flying along a curve from the bottom-left into the chip.
    if (t > 0 && t < 1) {
      final start = Offset(size.width * 0.12, size.height * 0.95);
      final ctrl = Offset(size.width * 0.4, -size.height * 0.2);
      final end = chip.center;
      final u = Curves.easeInOut.transform(t);
      final p = Offset(
        (1 - u) * (1 - u) * start.dx + 2 * (1 - u) * u * ctrl.dx + u * u * end.dx,
        (1 - u) * (1 - u) * start.dy + 2 * (1 - u) * u * ctrl.dy + u * u * end.dy,
      );
      canvas.drawCircle(p, 16, Paint()..color = c.cyan.withValues(alpha: 0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      canvas.drawCircle(p, 8, Paint()..color = c.cyan);
    }
  }

  @override
  bool shouldRepaint(_FlyPainter old) => old.t != t || old.c != c;
}

class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const stops = [
      (Icons.content_cut, 'Chopped into tokens', 'word pieces with ID numbers'),
      (Icons.place_outlined, 'Turned into coordinates', 'each piece gets an address on a map of meaning'),
      (Icons.layers_outlined, 'Through the layers', 'attention and feed-forward, floor by floor'),
      (Icons.casino_outlined, 'A word is picked', 'from a list of chances'),
      (Icons.loop, 'Again and again', 'one word at a time until the answer is done'),
    ];
    return DemoCard(
      title: 'The stops ahead',
      child: Column(
        children: [
          for (var i = 0; i < stops.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: c.magenta.withValues(alpha: 0.15), child: Icon(stops[i].$1, color: c.magenta)),
              title: Text('${i + 1}. ${stops[i].$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(stops[i].$3),
            ),
        ],
      ),
    );
  }
}
