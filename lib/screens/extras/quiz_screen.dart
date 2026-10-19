import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/quizzes.dart';
import '../../core/progress.dart';
import '../../widgets/bit.dart';
import '../../widgets/term_text.dart';

/// A section quiz: one question at a time, instant feedback with an explanation, score at the end.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quizId});
  final String quizId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _q = 0;
  int? _picked;
  int _score = 0;
  bool _finished = false;

  void _pick(int i) {
    if (_picked != null) return;
    final qs = quizzes[widget.quizId]!;
    setState(() {
      _picked = i;
      if (i == qs[_q].answer) _score++;
    });
  }

  void _next() {
    final qs = quizzes[widget.quizId]!;
    if (_q + 1 < qs.length) {
      setState(() {
        _q++;
        _picked = null;
      });
    } else {
      AppScope.read(context).setQuizScore(widget.quizId, _score);
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final qs = quizzes[widget.quizId] ?? const [];
    final section = int.tryParse(widget.quizId.replaceAll(RegExp(r'\D'), '')) ?? 0;
    final accent = c.section(section);
    return Scaffold(
      appBar: AppBar(title: Text('Section $section quiz')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: qs.isEmpty
                ? const Center(child: Text('Quiz coming soon.'))
                : _finished
                    ? _result(context, qs.length, accent)
                    : _question(context, qs, accent),
          ),
        ),
      ),
    );
  }

  Widget _question(BuildContext context, List qs, Color accent) {
    final c = AppColors.of(context);
    final q = qs[_q];
    return ListView(
      padding: const EdgeInsets.all(Gap.l),
      children: [
        LinearProgressIndicator(value: (_q + 1) / qs.length, color: accent, backgroundColor: c.surfaceHi),
        const SizedBox(height: Gap.l),
        Text('Question ${_q + 1} of ${qs.length}', style: TextStyle(color: c.textDim)),
        const SizedBox(height: Gap.s),
        TermText(q.question, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Gap.l),
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.s),
            child: _Option(
              key: ValueKey('quiz-option-$i'),
              text: q.options[i],
              state: _picked == null
                  ? _OptState.idle
                  : i == q.answer
                      ? _OptState.right
                      : i == _picked
                          ? _OptState.wrong
                          : _OptState.dim,
              onTap: () => _pick(i),
            ),
          ),
        if (_picked != null) ...[
          const SizedBox(height: Gap.m),
          BitSays(
            key: ValueKey('explain-$_q'),
            lines: ['${_picked == q.answer ? 'Correct! ' : 'Not quite. '}${q.explain}'],
            mood: _picked == q.answer ? BitMood.happy : BitMood.think,
            size: 48,
          ),
          const SizedBox(height: Gap.l),
          FilledButton(
            key: const ValueKey('quiz-next'),
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
            onPressed: _next,
            child: Text(_q + 1 < qs.length ? 'Next question' : 'See my score'),
          ),
        ],
      ],
    );
  }

  Widget _result(BuildContext context, int total, Color accent) {
    final c = AppColors.of(context);
    final great = _score >= (total * 0.8).ceil();
    return Padding(
      padding: const EdgeInsets.all(Gap.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BitAvatar(size: 120, mood: great ? BitMood.happy : BitMood.wow),
          const SizedBox(height: Gap.l),
          Text('$_score / $total', style: AppText.mono.copyWith(fontSize: 48, fontWeight: FontWeight.w800, color: accent)),
          const SizedBox(height: Gap.s),
          Text(
            great ? 'Brilliant! Your circuits are glowing.' : 'Nice work! Every wrong answer is a gradient step.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Gap.xl),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Back to the journey'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _q = 0;
              _picked = null;
              _score = 0;
              _finished = false;
            }),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

enum _OptState { idle, right, wrong, dim }

class _Option extends StatelessWidget {
  const _Option({super.key, required this.text, required this.state, required this.onTap});
  final String text;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final (border, bg, icon) = switch (state) {
      _OptState.right => (c.lime, c.lime.withValues(alpha: 0.12), Icons.check_circle),
      _OptState.wrong => (c.red, c.red.withValues(alpha: 0.12), Icons.cancel),
      _OptState.dim => (c.line, c.surface, null),
      _OptState.idle => (c.line, c.surface, null),
    };
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border, width: 1.5)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gap.l, vertical: Gap.m + 2),
          child: Row(
            children: [
              Expanded(
                child: Text(text,
                    style: TextStyle(color: state == _OptState.dim ? c.textDim : c.text, fontSize: 16)),
              ),
              if (icon != null) Icon(icon, color: border),
            ],
          ),
        ),
      ),
    );
  }
}
