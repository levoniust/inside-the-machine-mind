import 'package:flutter/material.dart';

import '../../app/nav.dart';
import '../../app/theme.dart';
import '../../content/lessons.dart';
import '../../content/quizzes.dart';
import '../../core/models.dart';
import '../../core/progress.dart';
import '../../widgets/bit.dart';
import '../../widgets/components.dart';
import '../extras/finale_screen.dart';
import 'lab_home.dart';

/// Section landing page: lessons as nodes on a glowing circuit path, quiz at the end.
class SectionHub extends StatelessWidget {
  const SectionHub({super.key, required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final s = sections[number - 1];
    final p = AppScope.progress(context);
    final accent = c.section(number);
    final ids = s.lessons.map((l) => l.id);
    final nextUp = s.lessons.firstWhere((l) => !p.isDone(l.id), orElse: () => s.lessons.first);
    final quizScore = p.quizScore(s.quizId);
    final quizLen = quizzes[s.quizId]?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(s.label)),
      body: CircuitBackground(
        accent: accent,
        density: 0.6,
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Gap.l, Gap.s, Gap.l, Gap.xxl),
                children: [
                  SectionTag(number <= 3 ? s.tag : (s.area == Area.lab ? 'Enthusiast Lab' : 'Front door'), color: accent),
                  const SizedBox(height: Gap.m),
                  Text(s.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: Gap.xs),
                  Text(s.tagline, style: TextStyle(color: c.textDim, fontSize: 16)),
                  const SizedBox(height: Gap.l),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: p.fraction(ids),
                            minHeight: 8,
                            color: accent,
                            backgroundColor: c.surfaceHi,
                          ),
                        ),
                      ),
                      const SizedBox(width: Gap.m),
                      Text('${(p.fraction(ids) * 100).round()}%', style: AppText.mono.copyWith(color: accent)),
                    ],
                  ),
                  const SizedBox(height: Gap.l),
                  FilledButton.icon(
                    key: const ValueKey('hub-continue'),
                    style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
                    onPressed: () => openLesson(context, nextUp.id, track: number),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      p.fraction(ids) == 0 ? (number <= 4 ? 'Start the journey' : 'Start') : 'Continue: ${nextUp.title}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: Gap.xl),
                  for (var i = 0; i < s.lessons.length; i++)
                    _Node(
                      index: i + 1,
                      title: s.lessons[i].title,
                      subtitle: s.lessons[i].subtitle,
                      done: p.isDone(s.lessons[i].id),
                      current: s.lessons[i].id == nextUp.id,
                      accent: accent,
                      last: false,
                      onTap: () => openLesson(context, s.lessons[i].id, track: number),
                    ),
                  if (s.quizId.isNotEmpty)
                    _Node(
                      index: s.lessons.length + 1,
                      title: number <= 3 ? 'Section quiz' : 'Quiz',
                      subtitle: quizScore == null ? '$quizLen questions' : 'Best: $quizScore / $quizLen',
                      done: quizScore != null,
                      current: false,
                      accent: accent,
                      last: true,
                      icon: Icons.quiz_outlined,
                      onTap: () => openQuiz(context, s.quizId),
                    ),
                  const SizedBox(height: Gap.xl),
                  if (p.fraction(ids) == 1) ...[
                    BitSays(
                      lines: [
                        number == 5
                            ? 'You finished the front door! Curious how people run these models themselves? The Enthusiast Lab is open.'
                            : 'You finished this whole ${number <= 3 ? 'section' : 'track'}! On to the next part?',
                      ],
                      mood: BitMood.happy,
                    ),
                    const SizedBox(height: Gap.m),
                    if (nextTrack(number) case final next?)
                      FilledButton.icon(
                        key: const ValueKey('hub-next-section'),
                        style: FilledButton.styleFrom(backgroundColor: c.section(next.number), foregroundColor: c.bg),
                        onPressed: () => Navigator.of(context)
                            .pushReplacement(MaterialPageRoute<void>(builder: (_) => SectionHub(number: next.number))),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          '${next.label}${next.number <= 3 ? ': ${next.title}' : ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    else if (number == 3)
                      FilledButton.icon(
                        key: const ValueKey('hub-next-section'),
                        style: FilledButton.styleFrom(backgroundColor: c.section(0), foregroundColor: c.bg),
                        onPressed: () => openPage(context, const FinaleScreen(), '/finale'),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('See the finale'),
                      )
                    else if (number == 5)
                      FilledButton.icon(
                        key: const ValueKey('hub-next-section'),
                        style: FilledButton.styleFrom(backgroundColor: c.lime, foregroundColor: c.bg),
                        onPressed: () => openPage(context, const LabHome(), '/lab'),
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Open the Enthusiast Lab'),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.current,
    required this.accent,
    required this.last,
    required this.onTap,
    this.icon,
  });
  final int index;
  final String title, subtitle;
  final bool done, current, last;
  final Color accent;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? accent : c.surface,
                      border: Border.all(color: done || current ? accent : c.line, width: 2),
                      boxShadow: current ? [BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 14)] : null,
                    ),
                    child: icon != null
                        ? Icon(icon, size: 18, color: done ? c.bg : accent)
                        : done
                        ? Icon(Icons.check, size: 18, color: c.bg)
                        : Text(
                            '$index',
                            style: AppText.mono.copyWith(
                              fontWeight: FontWeight.w800,
                              color: current ? accent : c.textDim,
                            ),
                          ),
                  ),
                  if (!last) Expanded(child: Container(width: 2, color: done ? accent.withValues(alpha: 0.7) : c.line)),
                ],
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: Gap.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.text),
                    ),
                    if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: c.textDim)),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: c.textDim),
          ],
        ),
      ),
    );
  }
}
