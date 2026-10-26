import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// What changed this year: a dated timeline, every item backed by a fact with its source.
class LThisYearScreen extends StatelessWidget {
  const LThisYearScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 'l_this_year', children: [_Timeline()]);
}

const _events = [
  ('Jun 2026', 'Google releases Gemma 4 (open, Apache 2.0, up to 31B)', 'SOTA-GEMMA4'),
  ('Jun 2026', 'Moonshot releases Kimi K3: 2.8T parameters, open weights', 'SOTA-KIMIK3'),
  ('Jul 30, 2026', 'Gemini Robotics 2 brings whole-body control to humanoid robots', 'RB-GEMINI'),
  ('Aug 2026', 'Qwen3.8 arrives, with open weights up to 2.4T parameters', 'SOTA-QWEN38'),
  ('Aug 2026', 'Zhipu releases GLM-5.3 (open weights, ~753B)', 'SOTA-GLM53'),
  ('Sep 2026', 'OpenAI launches GPT-6 Astra; Sol and Luna follow on Sep 22', 'SOTA-GPT6'),
  ('Sep 2026', 'DeepSeek-V4.1-Flash: open, MIT, 1M-token context', 'SOTA-DSV41'),
  ('Sep 22, 2026', 'Anthropic releases Claude Opus 5.5', 'SOTA-OPUS55'),
  ('Sep 2026', 'ChatGPT reports more than 1 billion weekly users', 'IN-USERS'),
  ('Sep 30, 2026', 'Google announces Gemini 4 Argon (1M tokens), open to all on Oct 13', 'SOTA-GEMINI4'),
  ('Oct 12, 2026', 'Meta launches Muse Wonder, its "frontier models for agents"', 'SOTA-MUSE'),
];

class _Timeline extends StatefulWidget {
  const _Timeline();

  @override
  State<_Timeline> createState() => _TimelineState();
}

class _TimelineState extends State<_Timeline> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(9);
    return DemoCard(
      title: 'June to October 2026',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _events.length; i++)
            InkWell(
              key: ValueKey('year-$i'),
              onTap: () => setState(() => _open = _open == i ? null : i),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Column(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                          ),
                          if (i < _events.length - 1)
                            Expanded(child: Container(width: 2, color: accent.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    const SizedBox(width: Gap.s),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: Gap.m),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _events[i].$1,
                              style: AppText.mono.copyWith(fontSize: 12, color: accent, fontWeight: FontWeight.w700),
                            ),
                            Text(_events[i].$2),
                            if (_open == i)
                              Text(
                                'Source: ${sources[facts[_events[i].$3]?.sources.first]?.title ?? ''}',
                                style: TextStyle(fontSize: 12, color: c.textDim),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            'Tap an event for its source. Next version of the app, this list grows.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
