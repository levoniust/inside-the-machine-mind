import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "What people do with it": a tappable timeline of milestones, from Deep Blue to Opus 5.5.
/// Facts: TL-DEEPBLUE, TL-ALEXNET, TL-ALPHAGO, TL-TRANSFORMER, TL-GPT3, TL-ALPHAFOLD, TL-CHATGPT,
/// TL-CLAUDECODE, IN-USERS, TL-OPUS55.
class S3TimelineScreen extends StatelessWidget {
  const S3TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_timeline',
        children: [_Timeline()],
      );
}

class Milestone {
  const Milestone(this.year, this.title, this.icon, this.story, this.factId, this.big);
  final String year, title, story, factId, big;
  final IconData icon;
}

const milestones = [
  Milestone('1997', 'Deep Blue beats Kasparov', Icons.extension_outlined,
      'IBM\'s chess computer beat the world champion. It wasn\'t a learning machine: it searched millions of moves with rules '
          'written by people. Impressive, but it couldn\'t do anything except chess.',
      'TL-DEEPBLUE', 'Chess'),
  Milestone('2012', 'AlexNet sees', Icons.visibility_outlined,
      'A [[neural network]] trained on just two gaming [[GPUs|GPU]] crushed an image-recognition contest. Learning from data, '
          'on graphics chips, suddenly beat hand-written rules. The deep-learning boom began.',
      'TL-ALEXNET', '2 GPUs'),
  Milestone('2016', 'AlphaGo\'s Move 37', Icons.grid_on,
      'AlphaGo beat Go legend Lee Sedol 4–1. In game 2 it played a move experts thought was a mistake: a human would play it '
          'about 1 time in 10,000. It turned out to be brilliant.',
      'TL-ALPHAGO', '1 in 10,000'),
  Milestone('2017', 'The Transformer', Icons.account_tree_outlined,
      'Eight Google researchers published "Attention Is All You Need". Its [[attention]] design is the blueprint inside almost '
          'every modern language model, including the ones in this app.',
      'TL-TRANSFORMER', 'Attention'),
  Milestone('2020', 'GPT-3 writes', Icons.edit_note,
      'With 175 billion knobs, GPT-3 could write essays and code from just a few examples, without being trained for each task. '
          'Scale itself seemed to unlock new skills.',
      'TL-GPT3', '175B knobs'),
  Milestone('2020', 'AlphaFold folds proteins', Icons.biotech_outlined,
      'AlphaFold 2 predicted the 3-D shapes of proteins, a 50-year-old puzzle in biology. Over 200 million structures were '
          'later shared free with scientists, and its creators won the 2024 Nobel Prize in Chemistry.',
      'TL-ALPHAFOLD', 'Nobel 2024'),
  Milestone('2022', 'ChatGPT talks to everyone', Icons.chat_bubble_outline,
      'ChatGPT (built on GPT-3.5) launched on 30 November 2022 and reached a million users in five days. By 2026 more than a '
          'billion people use it every week.',
      'TL-CHATGPT', '1M in 5 days'),
  Milestone('2025', 'AI agents write software', Icons.terminal,
      'Claude Code put an AI [[agent]] in programmers\' terminals: it reads code, runs commands, writes changes and checks its '
          'work in a loop, like a teammate.',
      'TL-CLAUDECODE', 'Agents'),
  Milestone('2026', 'Claude Opus 5.5', Icons.rocket_launch_outlined,
      'Testers reported Claude Opus 5.5 migrating 680,000 lines of code in under a day and staying on an unattended '
          'engineering task for 18 hours. (It\'s also the model that orchestrated the building of this app!)',
      'TL-OPUS55', '18 hours'),
];

class _Timeline extends StatefulWidget {
  const _Timeline();

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  int _sel = 2;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final m = milestones[_sel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'From chess to coworkers',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Tap a milestone. Scroll sideways for more.', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.m),
              SizedBox(
                // Room for the node (44) plus three lines of text that grow with the user's font size.
                height: 58 + MediaQuery.textScalerOf(context).scale(64),
                child: ListView.builder(
                  key: const ValueKey('timeline-strip'),
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  itemCount: milestones.length,
                  itemBuilder: (context, i) => _Node(
                    key: ValueKey('timeline-$i'),
                    m: milestones[i],
                    selected: i == _sel,
                    first: i == 0,
                    last: i == milestones.length - 1,
                    onTap: () => setState(() => _sel = i),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: DemoCard(
            key: ValueKey('timeline-card-$_sel'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: c.magenta.withValues(alpha: 0.18),
                      child: Icon(m.icon, color: c.magenta),
                    ),
                    const SizedBox(width: Gap.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.year, style: AppText.mono.copyWith(color: c.magenta, fontWeight: FontWeight.w800)),
                          Text(m.title, key: const ValueKey('timeline-title'), style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Gap.m),
                TermText(m.story),
                const SizedBox(height: Gap.m),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => showFactSource(context, m.factId),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Source'),
                  ),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _sel > 0 ? () => setState(() => _sel--) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Earlier'),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      key: const ValueKey('timeline-later'),
                      onPressed: _sel < milestones.length - 1 ? () => setState(() => _sel++) : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Later'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gap.l),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: FactCard(value: '1 billion+', label: 'weekly ChatGPT users (2026)', factId: 'IN-USERS')),
            SizedBox(width: Gap.m),
            Expanded(child: FactCard(value: '29 years', label: 'from Deep Blue\'s chess win to AI coworkers', factId: 'TL-DEEPBLUE')),
          ],
        ),
      ],
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({super.key, required this.m, required this.selected, required this.first, required this.last, required this.onTap});
  final Milestone m;
  final bool selected, first, last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        child: Column(
          children: [
            Text(m.year, style: AppText.mono.copyWith(color: selected ? c.magenta : c.textDim, fontWeight: FontWeight.w700)),
            const SizedBox(height: Gap.xs),
            SizedBox(
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container(height: 2, color: first ? Colors.transparent : c.line)),
                      Expanded(child: Container(height: 2, color: last ? Colors.transparent : c.line)),
                    ],
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: selected ? 44 : 34,
                    height: selected ? 44 : 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? c.magenta : c.surface,
                      border: Border.all(color: c.magenta.withValues(alpha: selected ? 1 : 0.5), width: 2),
                      boxShadow: selected ? [BoxShadow(color: c.magenta.withValues(alpha: 0.5), blurRadius: 14)] : null,
                    ),
                    child: Icon(m.icon, size: selected ? 22 : 18, color: selected ? Colors.white : c.magenta),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Gap.xs),
            Text(m.big,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: selected ? c.text : c.textDim, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
