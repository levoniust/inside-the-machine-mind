import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';

/// Where your words go: a message's path from your phone through the company's servers, with the gates that depend
/// on each app's settings (facts PRIV-*, from each company's help pages, as of Oct 2026).
class EPrivacyScreen extends StatelessWidget {
  const EPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 'e_privacy', children: [_Path(), _NeverPaste()]);
}

class _App {
  const _App(
    this.name,
    this.training,
    this.setting,
    this.temp,
    this.kept,
    this.humans,
    this.factId, {
    required this.trainsByDefault,
  });
  final String name, training, setting, temp, kept, humans, factId;
  final bool trainsByDefault;
}

const _apps = [
  _App(
    'ChatGPT',
    'Used to improve the models unless you switch it off.',
    'Settings > Data controls > "Improve the model for everyone"',
    'Temporary Chat: not used for training, kept for up to 30 days for safety.',
    'Deleted chats are permanently deleted within 30 days.',
    '',
    'PRIV-CHATGPT',
    trainsByDefault: true,
  ),
  _App(
    'Gemini',
    'With "Keep Activity" on, used to improve Google\'s services, including training its AI models.',
    'Turn off "Keep Activity" (Gemini Apps Activity)',
    'Temporary chats are kept for 72 hours.',
    'Activity is auto-deleted after 18 months by default (you can pick 3 or 36).',
    'Some chats are read by human reviewers, separated from your account, and kept for up to 3 years.',
    'PRIV-GEMINI',
    trainsByDefault: true,
  ),
  _App(
    'Copilot',
    'Used for AI training unless you opt out (some groups of users are excluded).',
    'Opt out in Copilot\'s privacy settings',
    '',
    'Conversation activity is kept for 18 months by default.',
    'Some conversations get automated and human review.',
    'PRIV-COPILOT',
    trainsByDefault: true,
  ),
  _App(
    'Claude',
    'Used to improve Claude only if you allow it.',
    'Privacy Settings > "Model Improvement" (off unless you turn it on)',
    'Incognito chats are never used for training.',
    'If you allow training, data can be kept for up to five years; deleted chats leave storage within 30 days.',
    '',
    'PRIV-CLAUDE',
    trainsByDefault: false,
  ),
  _App(
    'Meta AI',
    'Not confirmed for this version of the app.',
    'See Meta\'s Privacy Center, "Privacy and generative AI"',
    '',
    '',
    '',
    '',
    trainsByDefault: true,
  ),
];

class _Path extends StatefulWidget {
  const _Path();

  @override
  State<_Path> createState() => _PathState();
}

class _PathState extends State<_Path> {
  int _app = 0;
  bool _trainingOff = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final a = _apps[_app];
    final known = a.factId.isNotEmpty;
    final trains = known && (a.trainsByDefault ? !_trainingOff : _trainingOff);
    Widget gate(String label, IconData icon, bool on, String detail, {Key? key}) => Opacity(
      key: key,
      opacity: on ? 1 : 0.35,
      child: Container(
        margin: const EdgeInsets.only(bottom: Gap.xs),
        padding: const EdgeInsets.all(Gap.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? accent : c.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: on ? accent : c.textDim, size: 20),
            const SizedBox(width: Gap.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  if (detail.isNotEmpty) Text(detail, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return DemoCard(
      title: 'Follow your message',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(alignment: Alignment.centerLeft, child: AsOfChip('Oct 2026')),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (var i = 0; i < _apps.length; i++)
                ChoiceChip(
                  key: ValueKey('priv-app-$i'),
                  label: Text(_apps[i].name),
                  selected: _app == i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() {
                    _app = i;
                    _trainingOff = false;
                  }),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          gate('1. Your phone or computer', Icons.smartphone, true, 'You type and press send.'),
          gate(
            '2. The company\'s servers',
            Icons.cloud_outlined,
            true,
            known ? a.kept : 'Your chat is processed and stored there.',
          ),
          gate(
            '3. Training future models',
            Icons.model_training,
            trains,
            known ? a.training : a.training,
            key: const ValueKey('priv-gate-train'),
          ),
          if (a.humans.isNotEmpty) gate('4. Human reviewers', Icons.person_search_outlined, true, a.humans),
          const SizedBox(height: Gap.s),
          Text('Where the switch is: ${a.setting}', style: const TextStyle(fontWeight: FontWeight.w600)),
          if (known)
            SwitchListTile(
              key: const ValueKey('priv-switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(a.trainsByDefault ? 'Turn training off' : 'Allow training (it starts off)'),
              value: _trainingOff,
              onChanged: (v) => setState(() => _trainingOff = v),
            ),
          if (a.temp.isNotEmpty) Text(a.temp, style: TextStyle(color: c.textDim, fontSize: 13)),
          const SizedBox(height: Gap.xs),
          Text(
            'From each company\'s own help pages. Settings move around, so check the app itself.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _NeverPaste extends StatelessWidget {
  const _NeverPaste();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const items = [
      'Passwords and PIN codes',
      'ID, passport or bank numbers',
      'Other people\'s private details',
      'Your employer\'s secrets',
    ];
    return DemoCard(
      title: 'Never paste these into any chat',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.xs),
              child: Row(
                children: [
                  Icon(Icons.block, color: c.red, size: 18),
                  const SizedBox(width: Gap.s),
                  Expanded(child: Text(i)),
                ],
              ),
            ),
          const SizedBox(height: Gap.xs),
          Text(
            'Even with training switched off, what you send is stored on someone else\'s computer for a while.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
