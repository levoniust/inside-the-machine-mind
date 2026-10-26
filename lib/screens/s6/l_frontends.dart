import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Beyond the chat box: what sits on top of the engine (front-end, RAG, tools/MCP, agents), a working mini-RAG
/// (keyword overlap search over six chunks) and a step-by-step agent loop.
class LFrontendsScreen extends StatelessWidget {
  const LFrontendsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const LessonScaffold(lessonId: 'l_frontends', children: [_Boxes(), _Rag(), _Agent()]);
}

const _parts = [
  (
    'Front-end',
    Icons.chat_outlined,
    'The chat app you type into (Open WebUI, LM Studio\'s chat, many others). It keeps your conversations and sends them to the engine.',
  ),
  (
    'Engine + API',
    Icons.memory,
    'Runs the model and answers over an OpenAI-compatible API, so any front-end can talk to any engine.',
  ),
  (
    'RAG',
    Icons.search,
    'Before the model answers, find the most relevant passages in your documents and paste them into the prompt.',
  ),
  (
    'Tools / MCP',
    Icons.build_outlined,
    'Lets the model call things: web search, a calculator, your files. MCP is a common standard for plugging tools in.',
  ),
  (
    'Agent loop',
    Icons.loop,
    'The model plans, calls a tool, reads the result and decides what to do next, again and again until the job is done.',
  ),
];

class _Boxes extends StatefulWidget {
  const _Boxes();

  @override
  State<_Boxes> createState() => _BoxesState();
}

class _BoxesState extends State<_Boxes> {
  int _sel = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'What sits around the model',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < _parts.length; i++)
                ChoiceChip(
                  key: ValueKey('fe-$i'),
                  avatar: Icon(_parts[i].$2, size: 18),
                  label: Text(_parts[i].$1),
                  selected: _sel == i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _sel = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(_parts[_sel].$3, key: const ValueKey('fe-desc')),
        ],
      ),
    );
  }
}

const _chunks = [
  'To reset the router, hold the reset button on the back for 10 seconds until the lights blink.',
  'The office kitchen is cleaned every Friday afternoon.',
  'If the router lights stay red after a reset, call the internet provider.',
  'Holiday requests go to your team lead at least two weeks ahead.',
  'The printer on the second floor needs a new toner cartridge.',
  'Parking spaces 1 to 12 are reserved for visitors.',
];
const _question = 'How do I reset my router?';

class _Rag extends StatefulWidget {
  const _Rag();

  @override
  State<_Rag> createState() => _RagState();
}

class _RagState extends State<_Rag> {
  List<int>? _hits;

  static Set<String> _words(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), ' ').split(' ').where((w) => w.length > 3).toSet();

  void _search() {
    final q = _words(_question);
    final scores = [for (final c in _chunks) _words(c).intersection(q).length];
    final order = List.generate(_chunks.length, (i) => i)..sort((a, b) => scores[b].compareTo(scores[a]));
    setState(() => _hits = order.take(2).toList());
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final hits = _hits ?? const [];
    return DemoCard(
      title: 'Mini RAG: look it up, then answer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Question: "$_question"', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _chunks.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(Gap.xs),
              decoration: BoxDecoration(
                color: hits.contains(i) ? accent.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: hits.contains(i) ? accent : c.line),
              ),
              child: Text(_chunks[i], key: ValueKey('rag-chunk-$i'), style: const TextStyle(fontSize: 13)),
            ),
          const SizedBox(height: Gap.s),
          FilledButton.icon(
            key: const ValueKey('rag-search'),
            style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
            onPressed: _search,
            icon: const Icon(Icons.search),
            label: const Text('Search the documents'),
          ),
          if (hits.isNotEmpty) ...[
            const SizedBox(height: Gap.s),
            Container(
              key: const ValueKey('rag-prompt'),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Use these notes to answer:\n${hits.map((i) => '- ${_chunks[i]}').join('\n')}\n\nQuestion: $_question',
                style: AppText.mono.copyWith(fontSize: 11),
              ),
            ),
            const SizedBox(height: Gap.xs),
            Text(
              'This demo matches shared words. Real RAG uses an embedding model, so "fix my wifi box" would find the router notes too.',
              style: TextStyle(color: c.textDim, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _Agent extends StatefulWidget {
  const _Agent();

  @override
  State<_Agent> createState() => _AgentState();
}

class _AgentState extends State<_Agent> {
  static const _steps = [
    ('Plan', 'Task: "What\'s the weather in Dallas, in °C?" I need current data, so I\'ll use the weather tool.'),
    ('Call a tool', 'weather(city: "Dallas") →'),
    ('Read the result', '{"temp_f": 77, "sky": "clear"}  It\'s in °F; (77 − 32) × 5 ÷ 9 = 25.'),
    ('Answer', 'It\'s clear in Dallas and about 25 °C.'),
  ];
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    return DemoCard(
      title: 'An agent, one step at a time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i <= _i; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xs),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${i + 1}. ${_steps[i].$1}: ',
                      style: TextStyle(fontWeight: FontWeight.w800, color: accent),
                    ),
                    TextSpan(text: _steps[i].$2),
                  ],
                ),
              ),
            ),
          const SizedBox(height: Gap.s),
          Row(
            children: [
              FilledButton(
                key: const ValueKey('agent-step'),
                style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: c.bg),
                onPressed: _i < _steps.length - 1 ? () => setState(() => _i++) : null,
                child: const Text('Next step'),
              ),
              const SizedBox(width: Gap.s),
              TextButton(onPressed: () => setState(() => _i = 0), child: const Text('Restart')),
            ],
          ),
          Text(
            'Made-up weather numbers. Real agents loop like this through many tools, and the model decides each next step.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
