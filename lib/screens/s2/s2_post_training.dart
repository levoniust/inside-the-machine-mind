import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Section 2 · Lesson 17: From parrot to assistant.
/// A model that finishes any sentence (parrot) vs one that answers helpfully (assistant),
/// then the user plays the rater: pick the better of two answers and watch the "helpfulness"
/// meter climb as it goes SFT → RLHF → Constitutional AI → reasoning RL.
class S2PostTrainingScreen extends StatelessWidget {
  const S2PostTrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return LessonScaffold(
      lessonId: 's2_post_training',
      children: [
        _ParrotVsAssistant(accent: c.section(2)),
        const _RaterDemo(),
        StatGrid(
          columns: 2,
          children: [
            StatTile(
              value: '>100×',
              label: 'InstructGPT (1.3B) beat GPT-3 (175B)',
              color: c.violet,
              icon: Icons.thumb_up,
            ),
            StatTile(
              value: '128K',
              label: 'Llama 3 405B context window',
              color: c.cyan,
              icon: Icons.chat_bubble,
            ),
          ],
        ),
      ],
    );
  }
}

enum _Stage { sft, rlhf, cai, reasoning }

extension on _Stage {
  String get name => switch (this) {
    _Stage.sft => 'SFT (examples)',
    _Stage.rlhf => 'RLHF (thumbs up/down)',
    _Stage.cai => 'Constitutional AI',
    _Stage.reasoning => 'Reasoning RL',
  };
  double get helpfulness => switch (this) {
    _Stage.sft => 0.35,
    _Stage.rlhf => 0.65,
    _Stage.cai => 0.85,
    _Stage.reasoning => 0.98,
  };
  Color colorOf(AppColors c) => switch (this) {
    _Stage.sft => c.violet,
    _Stage.rlhf => c.lime,
    _Stage.cai => c.cyan,
    _Stage.reasoning => c.magenta,
  };
}

/// Static side-by-side: a "parrot" that just finishes sentences vs an "assistant" that helps.
class _ParrotVsAssistant extends StatelessWidget {
  const _ParrotVsAssistant({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'Parrot vs assistant',
      child: Row(
        children: [
          Expanded(child: _ModelBubble(kind: _BubbleKind.parrot, accent: c.amber)),
          const SizedBox(width: Gap.l),
          Expanded(child: _ModelBubble(kind: _BubbleKind.assistant, accent: accent)),
        ],
      ),
    );
  }
}

enum _BubbleKind { parrot, assistant }

class _ModelBubble extends StatelessWidget {
  const _ModelBubble({required this.kind, required this.accent});
  final _BubbleKind kind;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final isParrot = kind == _BubbleKind.parrot;
    return Column(
      children: [
        Semantics(
          label: isParrot
              ? 'A parrot model that just finishes any sentence'
              : 'An assistant model that answers helpfully',
          child: Container(
            padding: const EdgeInsets.all(Gap.m),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isParrot ? '🦜 Parrot model' : '🤖 Assistant model',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: Gap.xs),
                Text('You: "What is a good lunch?"',
                    style: TextStyle(color: c.textDim, fontSize: 13)),
                const SizedBox(height: Gap.xs),
                Text(
                    isParrot
                        ? '…a sandwich. A sandwich is a food. A food is eaten by people. People eat food every day. Food is—'
                        : 'A sandwich! I can suggest a turkey wrap, or a tomato soup if you prefer something warm.',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gap.s),
        Text(isParrot ? 'finishes the sentence' : 'answers the question',
            textAlign: TextAlign.center, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// The interactive part: user plays the rater. Pick the better of two answers; the meter
/// climbs as the stage advances from SFT → RLHF → Constitutional AI → reasoning RL.
class _RaterDemo extends StatefulWidget {
  const _RaterDemo();

  @override
  State<_RaterDemo> createState() => _RaterDemoState();
}

class _RaterDemoState extends State<_RaterDemo> {
  int _stage = 0;
  int _round = 0;
  int _correct = 0;
  bool _showFeedback = false;
  bool _lastWasCorrect = false;

  static const _questions = [
    'Which city is closer to London: Manchester or Edinburgh?',
    'Is a whale a fish?',
    'How many hours are in a week?',
  ];
  static const _bad = [
    'Manchester is in Scotland, so it is closer.',
    'Yes, a whale is a fish because it lives in the sea.',
    'There are 24 hours in a week.',
  ];
  static const _good = [
    'Manchester is in England, so it is closer to London than Edinburgh.',
    'No, a whale is a mammal — it breathes air and nurses its young.',
    'There are 24 × 7 = 168 hours in a week.',
  ];

  _Stage get _currentStage => _Stage.values[_stage];
  double get _helpfulness => _currentStage.helpfulness;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(2);
    final q = _questions[_round % _questions.length];
    return DemoCard(
      title: 'Play the rater: pick the better answer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Stage: ${_currentStage.name}',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.m),
          Text(q, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.m),
          _answerButton(c, _bad[_round % _bad.length], isGood: false),
          const SizedBox(height: Gap.s),
          _answerButton(c, _good[_round % _good.length], isGood: true),
          const SizedBox(height: Gap.m),
          if (_showFeedback) ...[
            _FeedbackBar(c, correct: _lastWasCorrect, stage: _currentStage),
            const SizedBox(height: Gap.m),
          ],
          Row(
            children: [
              Expanded(
                child: Text('Helpfulness (illustration): ${(_helpfulness * 100).round()}%',
                    style: AppText.mono.copyWith(color: accent, fontSize: 14)),
              ),
              FilledButton(
                key: const ValueKey('stage-next'),
                onPressed: _stage < _Stage.values.length - 1 ? () => setState(() => _stage++) : null,
                child: Text(_stage < _Stage.values.length - 1 ? 'Next stage' : 'Final stage'),
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text('You rated $_correct answer(s) correctly.', style: TextStyle(color: c.textDim, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _answerButton(AppColors c, String text, {required bool isGood}) {
    final accent = c.section(2);
    final picked = _showFeedback && isGood == _lastWasCorrect;
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: picked ? accent.withValues(alpha: 0.12) : c.surfaceHi,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: picked ? accent : c.line),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          IconButton(
            key: ValueKey('rate-$text'),
            icon: Icon(isGood ? Icons.thumb_up : Icons.thumb_down,
                color: picked ? accent : c.textDim),
            tooltip: isGood ? 'This is the better answer' : 'This is the worse answer',
            onPressed: () {
              setState(() {
                _lastWasCorrect = isGood;
                _showFeedback = true;
                if (isGood) _correct++;
                _round++;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _FeedbackBar extends StatelessWidget {
  const _FeedbackBar(this.c, {required this.correct, required this.stage});
  final AppColors c;
  final bool correct;
  final _Stage stage;

  @override
  Widget build(BuildContext context) {
    final accent = stage.colorOf(c);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(correct ? Icons.thumb_up_alt : Icons.thumb_down_alt, color: accent, size: 20),
          const SizedBox(width: Gap.s),
          Expanded(
            child: Text(
                correct
                    ? 'Good pick! This is how [[RLHF]] teaches a model: humans reward the better answer. ([[Constitutional AI]] uses the same idea, with an AI judging by written principles.)'
                    : 'Not quite — the other answer was more helpful. That feedback is what trains the model.',
                style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
