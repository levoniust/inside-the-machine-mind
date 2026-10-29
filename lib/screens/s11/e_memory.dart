import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// How the app remembers you: the context window as a notepad that slides (a toy 5-message window), "What does it
/// still see?", then the memory feature as a sticky-note file that survives a new chat. Facts MEM-*.
class EMemoryScreen extends StatelessWidget {
  const EMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(11);
    return LessonScaffold(
      lessonId: 'e_memory',
      children: [
        const _Window(),
        const _NewChat(),
        const _Controls(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: 'Every 24 h',
                label: 'how often Claude\'s memory summary of your chats is refreshed',
                factId: 'MEM-CLAUDE',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: 'Name, interests, goals',
                label: 'what Microsoft Copilot says it remembers with personalization on',
                factId: 'MEM-COPILOT',
                color: accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _Msg {
  const _Msg(this.text, [this.fact]);
  final String text;

  /// The detail this message carries, if any (a guessable fact).
  final String? fact;
}

const _chat = [
  _Msg('Hi! I\'m Priya.', 'Your name'),
  _Msg('I\'m planning my sister\'s birthday for June 14.', 'The date'),
  _Msg('She\'s allergic to peanuts.', 'The allergy'),
  _Msg('My budget is about \$200.', 'The budget'),
  _Msg('Any theme ideas?'),
  _Msg('Let\'s go with a garden party.', 'Garden party'),
  _Msg('What food works outdoors?'),
  _Msg('Oh, it might rain that day.', 'Rain'),
  _Msg('Indoor backup ideas?'),
  _Msg('Now write the invitation.'),
];
const _window = 5;

class _Window extends StatefulWidget {
  const _Window();

  @override
  State<_Window> createState() => _WindowState();
}

class _WindowState extends State<_Window> {
  int _sent = 4;
  final _guess = <int>{};
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    final firstSeen = _sent > _window ? _sent - _window : 0;
    final facts = [
      for (var i = 0; i < _chat.length; i++)
        if (_chat[i].fact != null) i,
    ];
    final done = _sent == _chat.length;
    final right = [for (final i in facts) (i >= firstSeen) == _guess.contains(i)].where((x) => x).length;
    return DemoCard(
      title: 'The notepad it can see',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'A chatbot only "sees" what fits on its notepad: the [[context window]]. In this toy the notepad holds the '
            'last 5 messages. Real ones hold hundreds of pages, but a long enough chat still slides off the top.',
          ),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _sent; i++)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: i >= firstSeen ? 1 : 0.3,
              child: Container(
                key: ValueKey('mem-msg-$i'),
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: 6),
                decoration: BoxDecoration(
                  color: i >= firstSeen ? accent.withValues(alpha: 0.12) : null,
                  border: Border.all(color: i >= firstSeen ? accent : c.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(_chat[i].text)),
                    if (i < firstSeen) Text('off the notepad', style: TextStyle(color: c.textDim, fontSize: 11)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: Gap.xs),
          if (!done)
            FilledButton(
              key: const ValueKey('mem-send'),
              style: FilledButton.styleFrom(backgroundColor: accent),
              onPressed: () => setState(() => _sent++),
              child: Text('Send the next message (${_sent + 1} of ${_chat.length})'),
            )
          else ...[
            const Text(
              'It\'s writing the invitation now. Which details can it still see? Tap them.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Gap.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final i in facts)
                  FilterChip(
                    key: ValueKey('mem-fact-$i'),
                    label: Text(_chat[i].fact!),
                    selected: _guess.contains(i),
                    onSelected: _revealed ? null : (on) => setState(() => on ? _guess.add(i) : _guess.remove(i)),
                  ),
              ],
            ),
            const SizedBox(height: Gap.xs),
            if (!_revealed)
              OutlinedButton(
                key: const ValueKey('mem-reveal'),
                onPressed: () => setState(() => _revealed = true),
                child: const Text('Check'),
              )
            else
              Text(
                '$right of ${facts.length} right. Only the garden party and the rain are still on the notepad: the '
                'invitation could forget the date and the peanut allergy. In a long chat, repeat what matters, or '
                'start fresh with a short summary.',
                key: const ValueKey('mem-result'),
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

class _NewChat extends StatefulWidget {
  const _NewChat();

  @override
  State<_NewChat> createState() => _NewChatState();
}

class _NewChatState extends State<_NewChat> {
  bool _memory = true;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(11);
    const saved = ['Name: Priya', 'Has a sister (birthday June 14)', 'Sister is allergic to peanuts'];
    return DemoCard(
      title: 'A new chat, next week',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'A new chat starts with an empty notepad. The **memory** feature is different: a small file of notes the '
            'app keeps about you and quietly adds to the start of new chats.',
          ),
          const SizedBox(height: Gap.s),
          SwitchListTile(
            key: const ValueKey('mem-switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Memory'),
            value: _memory,
            activeThumbColor: accent,
            onChanged: (v) => setState(() => _memory = v),
          ),
          Text('You: "Any cake ideas?"', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Container(
            key: ValueKey('mem-new-$_memory'),
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_memory) ...[
                  Text('Notes it starts with:', style: TextStyle(color: c.textDim, fontSize: 12)),
                  for (final s in saved) Text('• $s'),
                  const SizedBox(height: Gap.xs),
                  const Text('"For your sister\'s party, how about a lemon cake? It\'s easy to make peanut-free."'),
                ] else
                  const Text(
                    '"Sure! Chocolate, lemon or carrot cake are all popular." (It knows nothing about the party.)',
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'An example. Helpful, but it also means the app keeps facts about you and the people you mention.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    Widget row(String app, String how) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(app, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(how),
        ],
      ),
    );
    return DemoCard(
      title: 'See it, edit it, switch it off',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Every big app lets you look at what it remembers:', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          row('ChatGPT', 'A temporary chat doesn\'t create or update memories and stays out of your history.'),
          row(
            'Claude',
            'One memory summary, refreshed daily; projects keep separate memories; incognito chats are left out; Reset memory wipes it.',
          ),
          row('Gemini', '"Memory summary" shows what it understands about you; add, fix or delete details.'),
          row('Copilot', 'Edit or delete what it remembers, or turn personalization off and it forgets.'),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FactCard(value: 'Temporary chat', label: 'ChatGPT, no new memories', factId: 'MEM-CHATGPT-TEMP'),
              ),
              SizedBox(width: Gap.s),
              Expanded(
                child: FactCard(value: 'Memory summary', label: 'Gemini, view and edit', factId: 'MEM-GEMINI'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
