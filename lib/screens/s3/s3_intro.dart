import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 3 · "Ask the question": Bit types the question, you press send, and a packet flies into the
/// machine. When it lands, the chip writes a short reply one token at a time: for every token the stack of
/// layer bars lights floor by floor, then that token drops into the reply. The preview card walks through
/// the stops ahead in the same order.
class S3IntroScreen extends StatefulWidget {
  const S3IntroScreen({super.key});

  @override
  State<S3IntroScreen> createState() => _S3IntroScreenState();
}

class _S3IntroScreenState extends State<S3IntroScreen> {
  bool _arrived = false;

  void _packetArrived() {
    if (mounted) setState(() => _arrived = true);
  }

  @override
  Widget build(BuildContext context) => LessonScaffold(
        lessonId: 's3_intro',
        children: [
          _Send(onArrived: _packetArrived),
          _Preview(arrived: _arrived),
        ],
      );
}

class _Send extends StatefulWidget {
  const _Send({required this.onArrived});
  final VoidCallback onArrived;

  @override
  State<_Send> createState() => _SendState();
}

class _SendState extends State<_Send> with TickerProviderStateMixin {
  static const question = 'Why is the sky blue?';
  static const layerCount = 5;

  /// The short reply, split the way a tokenizer might (an illustration; real token splits vary).
  static const reply = ['Air', ' scat', 'ters', ' blue', ' light', ' the', ' most', '.'];
  static const msPerToken = 500;
  late final AnimationController _type = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
  late final AnimationController _wake =
      AnimationController(vsync: this, duration: Duration(milliseconds: msPerToken * reply.length));
  bool _sent = false;
  bool _awoke = false;

  @override
  void initState() {
    super.initState();
    _fly.addStatusListener((s) {
      if (s == AnimationStatus.completed) _wakeUp();
    });
  }

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
      _wakeUp(); // the status listener may already have run; _wakeUp fires at most once
    } else {
      _fly.forward(from: 0);
    }
  }

  /// The packet landed: generate the reply token by token and let the preview start its walk.
  /// Lighting layers and adding words is a colour/text reveal (no motion), so it also plays when animations are off.
  void _wakeUp() {
    if (_awoke || !mounted) return;
    _awoke = true;
    _wake.forward(from: 0);
    widget.onArrived();
  }

  /// Where the reply is: which token is going through the layers, how many floors are lit, how many tokens are out.
  _Gen get _gen {
    final x = _wake.value * reply.length;
    final k = x.floor().clamp(0, reply.length - 1);
    final frac = (x - k).clamp(0.0, 1.0);
    // The first 80% of each token's turn lights the floors; then the token drops out of the top.
    final lit = (frac / 0.8 * layerCount).floor().clamp(0, layerCount);
    final out = _wake.isCompleted ? reply.length : k + (frac >= 0.8 ? 1 : 0);
    return _Gen(k, lit, out, _wake.isCompleted);
  }

  @override
  void dispose() {
    _type.dispose();
    _fly.dispose();
    _wake.dispose();
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
              animation: Listenable.merge([_fly, _wake]),
              builder: (_, _) {
                final g = _gen;
                final String a11y;
                if (!_sent) {
                  a11y = 'A closed chip waits on the right for your question.';
                } else if (!_awoke) {
                  a11y = 'A packet flies into the chip.';
                } else if (!g.done) {
                  a11y = 'Making token ${g.token + 1} of ${reply.length}: ${g.lit} of $layerCount layers lit.';
                } else {
                  a11y = 'The reply is done: ${reply.length} tokens, each one through all $layerCount layers.';
                }
                return Semantics(
                  label: a11y,
                  child: CustomPaint(painter: _FlyPainter(_sent ? _fly.value : 0, g.done ? 1 : g.lit / layerCount, c)),
                );
              },
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
          if (_awoke) ...[
            const SizedBox(height: Gap.s),
            AnimatedBuilder(animation: _wake, builder: (_, _) => _Reply(gen: _gen)),
          ],
        ],
      ),
    );
  }
}

class _Gen {
  const _Gen(this.token, this.lit, this.out, this.done);
  final int token, lit, out;
  final bool done;
}

/// The reply bubble: tokens appear one by one, each in its own faint box so you can see where tokens split.
class _Reply extends StatelessWidget {
  const _Reply({required this.gen});
  final _Gen gen;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const reply = _SendState.reply;
    return Container(
      key: const ValueKey('intro-reply'),
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: c.surfaceHi,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.cyan.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            gen.done ? 'Reply: ${reply.length} tokens' : 'Token ${gen.token + 1} of ${reply.length}: going through the layers…',
            key: const ValueKey('intro-reply-status'),
            style: TextStyle(color: gen.done ? c.lime : c.cyan, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: Gap.xs),
          Wrap(
            runSpacing: 4,
            children: [
              for (var i = 0; i < gen.out; i++)
                Container(
                  margin: const EdgeInsets.only(right: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: (i.isEven ? c.cyan : c.magenta).withValues(alpha: i == gen.out - 1 && !gen.done ? 0.35 : 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(reply[i], style: const TextStyle(fontSize: 16)),
                ),
              if (!gen.done) Text(' ▍', style: TextStyle(color: c.cyan, fontSize: 16)),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            gen.done ? 'The whole trip again for every token. The next lessons follow one of them.' : '',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FlyPainter extends CustomPainter {
  _FlyPainter(this.t, this.wake, this.c);
  final double t;
  final double wake;
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
    // The chip's "floors": a small stack of layer bars that light up one after another after the packet lands.
    const bars = 5;
    const barH = 5.0, slot = 11.5;
    final barW = chip.width - 30;
    final bx = chip.center.dx - barW / 2;
    final by0 = chip.center.dy - (bars * slot - (slot - barH)) / 2;
    final litBars = (wake * bars).floor().clamp(0, bars);
    for (var i = 0; i < bars; i++) {
      final bar = Rect.fromLTWH(bx, by0 + i * slot, barW, barH);
      final isLit = i < litBars;
      final isCurrent = wake > 0 && wake < 1 && i == litBars;
      if (isCurrent) {
        canvas.drawRRect(RRect.fromRectAndRadius(bar.inflate(2), const Radius.circular(4)),
            Paint()..color = c.cyan.withValues(alpha: 0.55)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      }
      canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(2.5)),
          Paint()..color = isLit || isCurrent ? c.cyan : c.line.withValues(alpha: 0.5));
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
  bool shouldRepaint(_FlyPainter old) => old.t != t || old.wake != wake || old.c != c;
}

class _Preview extends StatefulWidget {
  const _Preview({required this.arrived});
  final bool arrived;

  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> with SingleTickerProviderStateMixin {
  static const stops = <(IconData, String, String)>[
    (Icons.content_cut, 'Chopped into tokens', 'word pieces with ID numbers'),
    (Icons.place_outlined, 'Turned into coordinates', 'each piece gets an address on a map of meaning'),
    (Icons.layers_outlined, 'Through the layers', 'attention and feed-forward, floor by floor'),
    (Icons.casino_outlined, 'A word is picked', 'from a list of possible next words'),
    (Icons.loop, 'Again and again', 'one word at a time until the answer is done'),
  ];

  /// One pass over the five stops after the packet arrives (~300 ms each). It is a colour-only
  /// highlight (no motion), so it also runs when animations are off.
  late final AnimationController _walk = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 300 * stops.length),
  );
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _maybeStart();
  }

  @override
  void didUpdateWidget(_Preview old) {
    super.didUpdateWidget(old);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.arrived && !_started) {
      _started = true;
      _walk.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _walk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: _walk,
      builder: (_, _) {
        final step = _walk.value * stops.length; // 0.0 … 5.0
        final passed = step.floor().clamp(0, stops.length); // stops the highlight has moved on from
        final active = _walk.isAnimating ? passed.clamp(0, stops.length - 1) : -1; // the stop lit right now (-1 when idle or done)
        return DemoCard(
          title: 'The stops ahead',
          child: Column(
            children: [
              for (var i = 0; i < stops.length; i++)
                AnimatedContainer(
                  key: ValueKey('preview-stop-$i'),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(vertical: Gap.xs),
                  padding: const EdgeInsets.symmetric(horizontal: Gap.m, vertical: Gap.s),
                  decoration: BoxDecoration(
                    color: i == active ? c.cyan.withValues(alpha: 0.10) : Colors.transparent,
                    border: Border.all(
                      color: i == active ? c.cyan : i < passed ? c.lime.withValues(alpha: 0.5) : c.line.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: (i == active ? c.cyan : c.magenta).withValues(alpha: 0.15),
                        child: Icon(stops[i].$1, color: i == active ? c.cyan : c.magenta),
                      ),
                      const SizedBox(width: Gap.m),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${i + 1}. ${stops[i].$2}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(stops[i].$3, style: TextStyle(color: c.textDim, fontSize: 13)),
                          ],
                        ),
                      ),
                      if (i < passed) ...[const SizedBox(width: Gap.s), Icon(Icons.check, color: c.lime)],
                    ],
                  ),
                ),
              if (widget.arrived) ...[
                const SizedBox(height: Gap.s),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        active >= 0 ? 'Following your question: ${stops[active].$2}…' : 'Five stops, one word at a time.',
                        key: const ValueKey('preview-step'),
                        style: TextStyle(color: active >= 0 ? c.cyan : c.textDim, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    TextButton.icon(
                      key: const ValueKey('preview-replay'),
                      onPressed: () => _walk.forward(from: 0),
                      icon: const Icon(Icons.replay, size: 18),
                      label: const Text('Walk again'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
