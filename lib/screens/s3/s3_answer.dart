import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../extras/finale_screen.dart';

/// Section 3 · "The answer arrives". The answer to "Why is the sky blue?" streams in token by token,
/// then a replay of the whole journey: hardware → training → inference.
class S3AnswerScreen extends StatelessWidget {
  const S3AnswerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LessonScaffold(
      lessonId: 's3_answer',
      children: [
        const _StreamingAnswer(),
        const _JourneyReplay(),
        FilledButton.icon(
          key: const ValueKey('to-finale'),
          style: FilledButton.styleFrom(backgroundColor: c.amber, foregroundColor: c.bg, minimumSize: const Size.fromHeight(52)),
          onPressed: () => openPage(context, const FinaleScreen(), '/finale'),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('One last thing…'),
        ),
      ],
    );
  }
}

const answerText = 'Sunlight looks white, but it is a mix of every color. When it hits the air, the tiny gas molecules '
    'scatter short blue waves of light much more strongly than long red ones. That scattered blue light reaches '
    'your eyes from every direction of the sky, so the whole sky glows blue. At sunset, light travels through '
    'much more air, the blue gets scattered away before it reaches you, and the reds and oranges are left.';

class _StreamingAnswer extends StatefulWidget {
  const _StreamingAnswer();

  @override
  State<_StreamingAnswer> createState() => _StreamingAnswerState();
}

class _StreamingAnswerState extends State<_StreamingAnswer> with SingleTickerProviderStateMixin {
  // Split into word-ish "tokens" so the answer streams like a real model's output.
  static final tokens = RegExp(r'\S+\s*').allMatches(answerText).map((m) => m.group(0)!).toList();
  late final AnimationController _t = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: tokens.length * 90),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _t.value = 1;
    } else if (_t.value == 0 && !_t.isAnimating) {
      _t.forward();
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
    return DemoCard(
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final n = (_t.value * tokens.length).ceil();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.person_outline, color: c.textDim, size: 18),
                  const SizedBox(width: Gap.s),
                  Flexible(
                    child: Text('Why is the sky blue?', style: TextStyle(color: c.textDim, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
              const SizedBox(height: Gap.m),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: tokens.take(n).join(), style: TextStyle(color: c.text, fontSize: 17, height: 1.5)),
                  if (n < tokens.length) TextSpan(text: ' ▍', style: TextStyle(color: c.magenta, fontSize: 17)),
                ]),
                key: const ValueKey('answer-text'),
              ),
              const SizedBox(height: Gap.m),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Gap.s,
                children: [
                  Text('$n / ${tokens.length} tokens', style: AppText.mono.copyWith(color: c.textDim, fontSize: 12)),
                  TextButton.icon(
                    key: const ValueKey('answer-replay'),
                    onPressed: () => _t.forward(from: 0),
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Stream again'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stage {
  const _Stage(this.section, this.icon, this.title, this.lines);
  final int section;
  final IconData icon;
  final String title;
  final List<String> lines;
}

const _stages = [
  _Stage(1, Icons.memory, 'Where the mind lives', [
    'Weights stored on SSDs, loaded into HBM next to the GPUs',
    'Thousands of GPUs linked by NVLink and InfiniBand',
    'A datacenter drawing megawatts, cooled by liquid',
  ]),
  _Stage(2, Icons.school_outlined, 'How the mind grew', [
    'Trillions of tokens of cleaned text',
    'Guess → loss → backpropagation → nudge, trillions of times',
    'Fine-tuning and feedback turned a parrot into a helper',
  ]),
  _Stage(3, Icons.chat_bubble_outline, 'How the mind answered', [
    'Your question chopped into tokens and embedded',
    'Attention and feed-forward layers, one floor after another',
    'One word at a time, picked from probabilities',
  ]),
];

class _JourneyReplay extends StatefulWidget {
  const _JourneyReplay();

  @override
  State<_JourneyReplay> createState() => _JourneyReplayState();
}

class _JourneyReplayState extends State<_JourneyReplay> with SingleTickerProviderStateMixin {
  late final AnimationController _t = AnimationController(vsync: this, duration: const Duration(seconds: 20));

  @override
  void initState() {
    super.initState();
    _t.value = 1; // show the full journey until replayed
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'The journey of your question',
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final total = _stages.length * 3;
          final shown = (_t.value * total).floor();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var s = 0; s < _stages.length; s++) ...[
                _stageTile(context, _stages[s], shown - s * 3, s == _stages.length - 1),
              ],
              const SizedBox(height: Gap.s),
              Center(
                child: OutlinedButton.icon(
                  key: const ValueKey('journey-replay'),
                  onPressed: () => _t.forward(from: 0),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Replay the whole journey (20 s)'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _stageTile(BuildContext context, _Stage st, int linesShown, bool last) {
    final c = AppColors.of(context);
    final accent = c.section(st.section);
    final active = linesShown > 0;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? accent : c.surface,
                  border: Border.all(color: accent, width: 2),
                  boxShadow: active ? [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 12)] : null,
                ),
                child: Icon(st.icon, size: 20, color: active ? c.bg : accent),
              ),
              if (!last) Expanded(child: Container(width: 2, color: active ? accent : c.line)),
            ],
          ),
          const SizedBox(width: Gap.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Gap.l, top: Gap.s),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(st.title, style: TextStyle(color: accent, fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: Gap.xs),
                  for (var i = 0; i < st.lines.length; i++)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: i < linesShown ? 1 : 0.15,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('• ${st.lines[i]}', style: TextStyle(color: c.text)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
