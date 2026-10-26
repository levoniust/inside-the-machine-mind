import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/progress.dart';
import '../../core/speech.dart';
import '../../widgets/library_card.dart';

/// Start screen, theme, motion, Bit's voice, and resetting progress.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final p = AppScope.progress(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(Gap.l),
            children: [
              Text(
                'Open the app at',
                style: TextStyle(color: c.textDim, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Gap.s),
              SegmentedButton<int>(
                key: const ValueKey('settings-audience'),
                segments: const [
                  ButtonSegment(value: 1, label: Text('Front door'), icon: Icon(Icons.door_front_door_outlined)),
                  ButtonSegment(value: 2, label: Text('Enthusiast Lab'), icon: Icon(Icons.science_outlined)),
                ],
                selected: {p.audience == 2 ? 2 : 1},
                showSelectedIcon: false,
                onSelectionChanged: (s) => AppScope.read(context).setAudience(s.first),
              ),
              const SizedBox(height: Gap.l),
              Text(
                'Look',
                style: TextStyle(color: c.textDim, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Gap.s),
              SegmentedButton<int>(
                key: const ValueKey('settings-theme'),
                segments: const [
                  ButtonSegment(value: 0, label: Text('System'), icon: Icon(Icons.brightness_auto)),
                  ButtonSegment(value: 1, label: Text('Dark'), icon: Icon(Icons.dark_mode_outlined)),
                  ButtonSegment(value: 2, label: Text('Light'), icon: Icon(Icons.light_mode_outlined)),
                ],
                selected: {p.theme},
                showSelectedIcon: false,
                onSelectionChanged: (s) => AppScope.read(context).setTheme(s.first),
              ),
              const SizedBox(height: Gap.l),
              SwitchListTile(
                key: const ValueKey('settings-motion'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Reduce motion'),
                subtitle: const Text('Stops looping background and demo animations'),
                value: p.reduceMotion,
                onChanged: (v) => AppScope.read(context).setReduceMotion(v),
              ),
              SwitchListTile(
                key: const ValueKey('settings-speak'),
                contentPadding: EdgeInsets.zero,
                title: const Text('Bit reads its lines aloud'),
                subtitle: const Text('Uses your phone\'s built-in voice. You can also tap the speaker in any bubble.'),
                value: p.autoSpeak,
                onChanged: (v) {
                  AppScope.read(context).setAutoSpeak(v);
                  if (v) BitVoice.instance.say('Hi! I\'m Bit. I\'ll read along with you.');
                },
              ),
              const SizedBox(height: Gap.s),
              Text(
                'Text size follows your phone\'s font-size setting.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
              const SizedBox(height: Gap.xl),
              const LibraryCard(),
              const SizedBox(height: Gap.xl),
              Text(
                'Progress',
                style: TextStyle(color: c.textDim, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: Gap.s),
              Text('${p.doneCount} lessons explored', style: TextStyle(color: c.text)),
              Text(
                'Easter eggs found: ${eggIds.where(p.foundEgg).length} of ${eggIds.length}',
                key: const ValueKey('settings-eggs'),
                style: TextStyle(color: c.text),
              ),
              const SizedBox(height: Gap.s),
              OutlinedButton.icon(
                key: const ValueKey('settings-reset'),
                icon: Icon(Icons.restart_alt, color: c.red),
                label: const Text('Start the journey over'),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Start over?'),
                      content: const Text(
                        'This forgets which lessons you finished, your quiz scores and the secrets you found.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Start over')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) AppScope.read(context).reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
