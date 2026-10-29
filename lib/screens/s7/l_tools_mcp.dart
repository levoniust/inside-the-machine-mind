import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Tools and MCP under the hood: the real JSON of one tool round trip (the MCP spec's own weather example), MCP as one
/// plug shape for many tools, and "Write the call", where a wrong call shows the error the model would get back.
/// Facts MCP-*, TOOL-* (MCP spec, Anthropic docs, ReAct, Toolformer).
class LToolsMcpScreen extends StatelessWidget {
  const LToolsMcpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(7);
    return LessonScaffold(
      lessonId: 'l_tools_mcp',
      children: [
        const _RoundTrip(),
        const _Plug(),
        const _WriteTheCall(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: 'Toolformer',
                label: '2023: a model taught itself when to call a calculator, search, translator and calendar',
                factId: 'TOOL-TOOLFORMER',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'ReAct',
                label: '2022: think, act, read the result, think again, the loop every agent runs today',
                factId: 'TOOL-REACT',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Json extends StatelessWidget {
  const _Json(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Gap.s),
      decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(text, style: AppText.mono.copyWith(fontSize: 11.5, height: 1.35)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

const _trip = [
  (
    'The app shows the model a menu',
    'Before you even ask, the app lists each tool: a name, a plain-English description, and the shape of its arguments '
        '(a JSON Schema). This text goes into the model\'s [[context window]] like any other words.',
    '{\n'
        '  "name": "get_weather",\n'
        '  "description": "Get current weather information for a location",\n'
        '  "inputSchema": {\n'
        '    "type": "object",\n'
        '    "properties": {\n'
        '      "location": { "type": "string", "description": "City name or zip code" }\n'
        '    },\n'
        '    "required": ["location"]\n'
        '  }\n'
        '}',
  ),
  (
    'The model writes a call',
    'You ask "What\'s it like in New York?". The model doesn\'t fetch anything itself: it writes these [[tokens|token]] '
        'and stops, waiting for the result.',
    '{\n'
        '  "method": "tools/call",\n'
        '  "params": {\n'
        '    "name": "get_weather",\n'
        '    "arguments": { "location": "New York" }\n'
        '  }\n'
        '}',
  ),
  (
    'The app runs it and sends the result back',
    'Ordinary code runs the tool and pastes the answer into the conversation. To the model, it\'s just more text to read.',
    '{\n'
        '  "content": [{\n'
        '    "type": "text",\n'
        '    "text": "Current weather in New York:\\nTemperature: 72°F\\nConditions: Partly cloudy"\n'
        '  }],\n'
        '  "isError": false\n'
        '}',
  ),
  (
    'The model answers',
    'Now it writes for you, using the result: one round trip. An [[agent]] simply repeats this loop until the job is done.',
    '"It\'s 72°F and partly cloudy in New York right now."',
  ),
];

class _RoundTrip extends StatefulWidget {
  const _RoundTrip();

  @override
  State<_RoundTrip> createState() => _RoundTripState();
}

class _RoundTripState extends State<_RoundTrip> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final (title, body, json) = _trip[_i];
    return DemoCard(
      title: 'One tool call, in real JSON',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${_i + 1}. $title',
            key: ValueKey('mcp-trip-$_i'),
            style: TextStyle(color: accent, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Gap.xs),
          TermText(body),
          const SizedBox(height: Gap.s),
          _Json(json),
          const SizedBox(height: Gap.s),
          StepControls(step: _i, count: _trip.length, onStep: (i) => setState(() => _i = i)),
          const SizedBox(height: Gap.xs),
          Text(
            'The JSON is the MCP specification\'s own example. Claude\'s and OpenAI\'s APIs use the same idea with '
            'slightly different labels (Claude calls it a tool_use block and a tool_result).',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'tool_use → tool_result',
            label: 'the round trip in Claude\'s API',
            factId: 'TOOL-ROUNDTRIP',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Plug extends StatelessWidget {
  const _Plug();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    Widget box(String t, String sub, Color col) => Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 6),
      decoration: BoxDecoration(
        color: col.withValues(alpha: 0.14),
        border: Border.all(color: col),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          Text(sub, style: TextStyle(color: c.textDim, fontSize: 11)),
        ],
      ),
    );
    return DemoCard(
      title: 'MCP: one plug shape for every tool',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'Before [[MCP]], every app wired up every tool its own way. MCP is like USB for AI tools: write a tool '
            'server once, and any app that speaks MCP can plug it in.',
          ),
          const SizedBox(height: Gap.m),
          Center(child: box('Your AI app (the host)', 'one MCP client per server', accent)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Center(child: Icon(Icons.cable, color: c.textDim)),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              box('Files server', 'read, search', c.cyan),
              box('Calendar server', 'events', c.cyan),
              box('Database server', 'queries', c.cyan),
            ],
          ),
          const SizedBox(height: Gap.m),
          const TermText(
            'Each server can offer three things: **tools** (actions to run), **resources** (data such as file contents) '
            'and **prompts** (ready-made templates). Underneath, it\'s plain JSON messages: tools/list to read the menu, '
            'tools/call to run one.',
          ),
          const SizedBox(height: Gap.s),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: '1 per server', label: 'MCP clients inside the host app', factId: 'MCP-PARTS'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: '3', label: 'kinds of thing a server offers', factId: 'MCP-PRIMS'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// The game: five requests, four candidate calls each. Wrong calls return the error the model would actually see.

class _Cand {
  const _Cand(this.call, this.reply, {this.ok = false});
  final String call, reply;
  final bool ok;
}

class _Req {
  const _Req(this.ask, this.cands);
  final String ask;
  final List<_Cand> cands;
}

const _menu =
    'get_weather(location: string)\nset_timer(minutes: integer)\nsearch_notes(query: string)\n'
    'send_email(to, subject, body)';

const _reqs = [
  _Req('"Do I need a coat in Denver today?"', [
    _Cand('get_weather {"city": "Denver"}', 'Error -32602: invalid arguments: "location" is required.'),
    _Cand(
      'get_weather {"location": "Denver"}',
      'Result: 41°F, windy. The model can now say yes, bring a coat.',
      ok: true,
    ),
    _Cand('weather {"location": "Denver"}', 'Error -32602: Unknown tool: weather'),
    _Cand('(no tool, answer from memory)', 'It can\'t know today\'s weather; it would be guessing.'),
  ]),
  _Req('"Set a timer for 15 minutes."', [
    _Cand('set_timer {"minutes": "fifteen"}', 'Error: invalid arguments: "minutes" must be an integer.'),
    _Cand('set_timer {"seconds": 900}', 'Error -32602: invalid arguments: "minutes" is required.'),
    _Cand('set_timer {"minutes": 15}', 'Result: timer set for 15 minutes.', ok: true),
    _Cand('search_notes {"query": "timer"}', 'Result: 0 notes found. Wrong tool: nothing got set.'),
  ]),
  _Req('"What did I write about the antenna?"', [
    _Cand('search_notes {"query": "antenna"}', 'Result: 3 notes. The model reads them and summarizes.', ok: true),
    _Cand('search_notes {}', 'Error -32602: invalid arguments: "query" is required.'),
    _Cand('get_weather {"location": "antenna"}', 'Result (isError: true): no such place "antenna".'),
    _Cand('(no tool, answer from memory)', 'The model has never seen your notes; it would make something up.'),
  ]),
  _Req('"What is 12 × 12?"', [
    _Cand('search_notes {"query": "12 x 12"}', 'Works, but a search for simple math is wasted time.'),
    _Cand('(no tool, just answer)', '144. Not every question needs a tool.', ok: true),
    _Cand('set_timer {"minutes": 144}', 'Result: a 144-minute timer. Oops.'),
    _Cand('calculator {"expr": "12*12"}', 'Error -32602: Unknown tool: calculator (it isn\'t on the menu).'),
  ]),
  _Req('"Email my notes to Sam." (you never gave an address)', [
    _Cand('send_email {"to": "sam@example.com", ...}', 'Guessing an address could send your notes to a stranger.'),
    _Cand(
      '(ask: "What\'s Sam\'s address? I\'ll show you the email before sending.")',
      'Right: ask for what\'s missing, and let a person approve actions that can\'t be undone.',
      ok: true,
    ),
    _Cand('send_email {"to": "", "subject": "Notes"}', 'Result (isError: true): no recipient. Nothing sent.'),
    _Cand('search_notes {"query": "Sam email"}', 'Maybe useful later, but it still shouldn\'t send without asking.'),
  ]),
];

class _WriteTheCall extends StatefulWidget {
  const _WriteTheCall();

  @override
  State<_WriteTheCall> createState() => _WriteTheCallState();
}

class _WriteTheCallState extends State<_WriteTheCall> {
  int _r = 0;
  int? _pick;
  int _firstTry = 0;
  bool _tried = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(7);
    final r = _reqs[_r];
    final solved = _pick != null && r.cands[_pick!].ok;
    final last = _r == _reqs.length - 1;
    return DemoCard(
      title: 'Write the call (${_r + 1} of ${_reqs.length})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tools on the menu:', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          const _Json(_menu),
          const SizedBox(height: Gap.s),
          Text(
            r.ask,
            key: ValueKey('mcp-ask-$_r'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Gap.xs),
          for (var i = 0; i < r.cands.length; i++) ...[
            OutlinedButton(
              key: ValueKey('mcp-cand-$_r-$i'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(Gap.s),
                side: BorderSide(
                  color: _pick == i ? (r.cands[i].ok ? accent : c.amber) : c.line,
                  width: _pick == i ? 2 : 1,
                ),
              ),
              onPressed: solved
                  ? null
                  : () => setState(() {
                      if (!_tried && r.cands[i].ok) _firstTry++;
                      _tried = true;
                      _pick = i;
                    }),
              child: Text(r.cands[i].call, style: AppText.mono.copyWith(fontSize: 12, color: c.text)),
            ),
            const SizedBox(height: Gap.xs),
          ],
          if (_pick != null)
            Container(
              key: const ValueKey('mcp-reply'),
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                color: (solved ? accent : c.amber).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(r.cands[_pick!].reply, style: AppText.mono.copyWith(fontSize: 12, color: c.text)),
            ),
          if (solved && !last)
            Padding(
              padding: const EdgeInsets.only(top: Gap.s),
              child: FilledButton(
                key: const ValueKey('mcp-next'),
                style: FilledButton.styleFrom(backgroundColor: accent),
                onPressed: () => setState(() {
                  _r++;
                  _pick = null;
                  _tried = false;
                }),
                child: const Text('Next request'),
              ),
            ),
          if (solved && last)
            Padding(
              padding: const EdgeInsets.only(top: Gap.s),
              child: Text(
                'Right first time: $_firstTry of ${_reqs.length}. Errors aren\'t the end: the model reads them and '
                'tries again, which is why a clear description and schema matter so much.',
                key: const ValueKey('mcp-done'),
                style: TextStyle(color: accent, fontWeight: FontWeight.w700),
              ),
            ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'isError',
            label: 'unknown tools and bad arguments come back as errors the model can read',
            factId: 'MCP-ERRORS',
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'human in the loop',
            label: 'the MCP spec says a person should always be able to deny a tool call',
            factId: 'MCP-HUMAN',
          ),
        ],
      ),
    );
  }
}
