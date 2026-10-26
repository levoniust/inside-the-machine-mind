import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Jobs around AI that are not research: pick where you come from, see the roles nearest to you and what to learn first.
class LJobsScreen extends StatelessWidget {
  const LJobsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 'l_jobs', children: [_Roles()]);
}

class _Role {
  const _Role(this.title, this.does, this.learn, this.from);
  final String title, does, learn;
  final Set<String> from;
}

const _roles = [
  _Role(
    'AI / ML engineer',
    'Builds products on top of models: prompts, RAG, fine-tunes, evaluation, shipping it.',
    'Python, an API or two, RAG, basic evaluation',
    {'software'},
  ),
  _Role(
    'MLOps / AI infrastructure',
    'Keeps models running: GPUs, serving engines, monitoring, costs.',
    'Linux, containers, vLLM or similar, GPU basics',
    {'it', 'software', 'hardware'},
  ),
  _Role(
    'Data engineer',
    'Collects, cleans and moves the data that training and RAG depend on.',
    'SQL, pipelines, data quality',
    {'software', 'it', 'science'},
  ),
  _Role(
    'Evaluation & red-teaming',
    'Designs tests, tries to break models, writes up what fails.',
    'Careful testing, writing, some scripting',
    {'writing', 'science', 'software'},
  ),
  _Role(
    'Datacenter & hardware ops',
    'Installs and runs the racks: power, cooling, networking, failing GPUs.',
    'Electrical/IT basics, networking, monitoring',
    {'hardware', 'it'},
  ),
  _Role(
    'Solutions / applied AI',
    'Helps a company or customer use AI for real work; part engineer, part translator.',
    'One domain well, plus prompting and RAG',
    {'it', 'writing', 'science'},
  ),
  _Role(
    'AI product manager',
    'Decides what an AI feature should do, for whom, and how to tell it works.',
    'User research, evaluation basics, clear writing',
    {'writing', 'software'},
  ),
  _Role(
    'Technical writing & education',
    'Explains AI tools to the people who use them (like this app does).',
    'Writing, one hands-on tool, honesty about limits',
    {'writing'},
  ),
  _Role(
    'Policy, safety & governance',
    'Rules, risk and responsible use inside companies and governments.',
    'Law or policy background plus how models fail',
    {'writing', 'science'},
  ),
];

const _origins = [
  ('it', 'IT'),
  ('software', 'Software'),
  ('hardware', 'Hardware'),
  ('writing', 'Writing'),
  ('science', 'Science'),
];

class _Roles extends StatefulWidget {
  const _Roles();

  @override
  State<_Roles> createState() => _RolesState();
}

class _RolesState extends State<_Roles> {
  String? _from;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(10);
    final shown = [
      for (final r in _roles)
        if (_from == null || r.from.contains(_from)) r,
    ];
    return DemoCard(
      title: 'I come from…',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (final (id, label) in _origins)
                ChoiceChip(
                  key: ValueKey('jobs-$id'),
                  label: Text(label),
                  selected: _from == id,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (on) => setState(() => _from = on ? id : null),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(
            '${shown.length} roles',
            key: const ValueKey('jobs-count'),
            style: AppText.mono.copyWith(color: accent),
          ),
          const SizedBox(height: Gap.xs),
          for (final r in shown)
            Container(
              margin: const EdgeInsets.only(bottom: Gap.s),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text(r.does, style: const TextStyle(fontSize: 13)),
                  Text('Learn first: ${r.learn}', style: TextStyle(fontSize: 13, color: c.textDim)),
                ],
              ),
            ),
          Text(
            'None of these needs a PhD. Most need one solid skill you already have, plus hands-on time with the tools in this Lab.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
