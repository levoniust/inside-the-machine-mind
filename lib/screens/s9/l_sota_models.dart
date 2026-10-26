import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/facts.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// The models right now (as of Oct 2026): two shelves, closed frontier and open weights, each card from the maker's
/// own announcement or model card (facts SOTA-*). Filter open/closed and "runs at home".
class LSotaModelsScreen extends StatelessWidget {
  const LSotaModelsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 'l_sota_models', children: [_Shelves()]);
}

class _M {
  const _M(
    this.name,
    this.maker,
    this.when,
    this.size,
    this.note,
    this.factId, {
    required this.open,
    this.home = false,
  });
  final String name, maker, when, size, note, factId;
  final bool open, home;
}

const _models = [
  _M(
    'GPT-6 (Astra, Sol, Luna)',
    'OpenAI',
    'Sep 2026',
    'size not published',
    'Flagship family in ChatGPT and the API',
    'SOTA-GPT6',
    open: false,
  ),
  _M(
    'Claude Opus 5.5',
    'Anthropic',
    'Sep 22, 2026',
    'size not published',
    'Built for long-running agentic coding and knowledge work',
    'SOTA-OPUS55',
    open: false,
  ),
  _M(
    'Gemini 4 Argon',
    'Google',
    'Sep 30, 2026 (all users Oct 13)',
    'size not published',
    '1 million token context',
    'SOTA-GEMINI4',
    open: false,
  ),
  _M(
    'Muse Wonder',
    'Meta',
    'Oct 12, 2026',
    'size not published',
    '"Frontier models for agents", via the Meta Model API',
    'SOTA-MUSE',
    open: false,
  ),
  _M(
    'DeepSeek-V4.1-Flash',
    'DeepSeek',
    'Sep 2026 (update Oct 17)',
    '552B backbone, 8-16B active',
    'MIT licence, up to 1M tokens, reads images',
    'SOTA-DSV41',
    open: true,
  ),
  _M(
    'Qwen3.8 family',
    'Alibaba Qwen',
    'Aug 2026',
    '2.4T-A95B · 125B-A6B · 27B',
    'The 27B is Apache 2.0; 262K context, up to 1M',
    'SOTA-QWEN38',
    open: true,
    home: true,
  ),
  _M(
    'Kimi K3',
    'Moonshot AI',
    'Jun 2026',
    '2.8T total, 104B active',
    '1,048,576-token context',
    'SOTA-KIMIK3',
    open: true,
  ),
  _M('GLM-5.3', 'Zhipu (Z.ai)', 'Aug 2026', '~753B (mixture of experts)', 'Open weights', 'SOTA-GLM53', open: true),
  _M(
    'Gemma 4',
    'Google',
    'Jun 2026',
    '5B to 31B',
    'Apache 2.0, up to 256K context',
    'SOTA-GEMMA4',
    open: true,
    home: true,
  ),
];

class _Shelves extends StatefulWidget {
  const _Shelves();

  @override
  State<_Shelves> createState() => _ShelvesState();
}

class _ShelvesState extends State<_Shelves> {
  String _f = 'all';
  int? _open;

  bool _show(_M m) => switch (_f) {
    'open' => m.open,
    'closed' => !m.open,
    'home' => m.home,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(9);
    Widget shelf(String title, bool open) {
      final items = [
        for (var i = 0; i < _models.length; i++)
          if (_models[i].open == open && _show(_models[i])) i,
      ];
      if (items.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppText.mono.copyWith(fontWeight: FontWeight.w800, color: accent, letterSpacing: 1.2),
          ),
          const SizedBox(height: Gap.xs),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.s),
              child: InkWell(
                key: ValueKey('sota-$i'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _open = _open == i ? null : i),
                child: Container(
                  padding: const EdgeInsets.all(Gap.s),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_models[i].name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: Gap.s),
                          Flexible(
                            child: Text(
                              _models[i].when,
                              textAlign: TextAlign.right,
                              style: AppText.mono.copyWith(fontSize: 11, color: c.textDim),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_models[i].maker} · ${_models[i].size}',
                        style: TextStyle(fontSize: 13, color: c.textDim),
                      ),
                      if (_open == i) ...[
                        const SizedBox(height: Gap.xs),
                        Text(_models[i].note),
                        const SizedBox(height: 4),
                        Text(facts[_models[i].factId]?.text ?? '', style: TextStyle(fontSize: 12, color: c.textDim)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: Gap.s),
        ],
      );
    }

    return DemoCard(
      title: 'Two shelves',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.xs,
            children: [
              for (final (id, label) in [
                ('all', 'All'),
                ('closed', 'Closed'),
                ('open', 'Open weights'),
                ('home', 'Runs at home'),
              ])
                ChoiceChip(
                  key: ValueKey('sota-filter-$id'),
                  label: Text(label),
                  selected: _f == id,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _f = id),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          shelf('CLOSED FRONTIER', false),
          shelf('OPEN WEIGHTS', true),
          Text(
            'Each card comes from the maker\'s own announcement or model card. "Runs at home" = small enough for a single '
            'good GPU or a big Mac. Tap a card for the details and its source.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
