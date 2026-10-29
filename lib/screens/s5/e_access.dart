import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// AI that helps people see, hear and speak: four real, public people in their own words (each with a source), then
/// "A day with the tools". Rule: only people who told their story publicly; quotes exactly as reported. Facts ACC-*.
class EAccessScreen extends StatelessWidget {
  const EAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LessonScaffold(lessonId: 'e_access', children: [_Stories(), _Day()]);
  }
}

class _Story {
  const _Story(this.icon, this.name, this.who, this.story, this.quote, this.factId);
  final IconData icon;
  final String name, who, story, factId;
  final String? quote;
}

const _stories = [
  _Story(
    Icons.visibility_outlined,
    'Lucy Edwards',
    'Blind content creator',
    'She lost her sight at 17. In 2023 she tested Be My Eyes\' GPT-4 "Virtual Volunteer", and now she asks AI to '
        'describe her own photos, outfits and makeup.',
    '"I haven\'t had an opinion about my face for 12 years. Suddenly I\'m taking a photo and I can ask AI."',
    'ACC-EDWARDS',
  ),
  _Story(
    Icons.hearing_outlined,
    'Dimitri Kanevsky',
    'Google research scientist, deaf since early childhood',
    'After 30 years of working on speech recognition, he helped build Live Transcribe: a free phone app that captions '
        'the people around you in over 70 languages, with a keyboard to type back.',
    null,
    'ACC-KANEVSKY',
  ),
  _Story(
    Icons.record_voice_over_outlined,
    'Jennifer Wexton',
    'US Representative (Virginia)',
    'A brain disease, progressive supranuclear palsy, took her clear speech. In July 2024 she spoke on the House floor in '
        'an AI copy of her own voice, made from recordings of her old speeches.',
    '"I cried happy tears when I first heard it."',
    'ACC-WEXTON',
  ),
  _Story(
    Icons.sports_football_outlined,
    'Tim Shaw',
    'Former NFL linebacker with ALS',
    'ALS took his voice. Google\'s Project Euphonia and DeepMind rebuilt it from the many interviews he had given as a '
        'player, because a good synthetic voice then needed 30-40 minutes of recordings.',
    null,
    'ACC-SHAW',
  ),
];

class _Stories extends StatefulWidget {
  const _Stories();

  @override
  State<_Stories> createState() => _StoriesState();
}

class _StoriesState extends State<_Stories> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final s = _stories[_i];
    return DemoCard(
      title: 'Four people, in their own words',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _stories.length; i++)
                ChoiceChip(
                  key: ValueKey('acc-person-$i'),
                  avatar: Icon(_stories[i].icon, size: 16),
                  label: Text(_stories[i].name),
                  selected: i == _i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _i = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text(
            s.name,
            key: ValueKey('acc-name-$_i'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: accent),
          ),
          Text(s.who, style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          Text(s.story),
          if (s.quote case final q?) ...[
            const SizedBox(height: Gap.s),
            Container(
              padding: const EdgeInsets.all(Gap.s),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: accent, width: 4)),
                color: accent.withValues(alpha: 0.08),
              ),
              child: Text(q, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15)),
            ),
          ],
          const SizedBox(height: Gap.s),
          FactCard(value: s.name, label: 'their story and its source', factId: s.factId, color: accent),
          const SizedBox(height: Gap.s),
          const TermText(
            'Not perfect: some "AI mirror" apps will, if asked, rate a person against narrow beauty standards. The same '
            '[[voice clone]] tech that gave Wexton her voice back is also used in scams.',
          ),
          const SizedBox(height: Gap.xs),
          const FactCard(value: 'Mirror, mirror', label: 'a caution from the BBC report', factId: 'ACC-MIRROR-RISK'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------

enum _Tool { describe, captions, voice, bank }

class _Moment {
  const _Moment(this.time, this.text, this.best, this.why);
  final String time, text, why;
  final _Tool best;
}

const _toolNames = {
  _Tool.describe: 'Describe what the camera sees',
  _Tool.captions: 'Live captions',
  _Tool.voice: 'Speak in my own rebuilt voice',
  _Tool.bank: 'Bank my voice now',
};

const _moments = [
  _Moment(
    '8:00',
    'A letter arrives. You\'re blind and want to know what it says.',
    _Tool.describe,
    'Point the phone, hear the letter read and described.',
  ),
  _Moment(
    '9:30',
    'You\'re deaf, and the barista is asking you something.',
    _Tool.captions,
    'Their words appear on your screen as they talk.',
  ),
  _Moment(
    '11:00',
    'You can no longer speak clearly, and it\'s your turn to present at work.',
    _Tool.voice,
    'You type; it speaks in a voice that sounds like you, like Wexton\'s did.',
  ),
  _Moment(
    '13:00',
    'You\'re blind and choosing an outfit for tonight.',
    _Tool.describe,
    'Ask how the colours go together, like Lucy Edwards does.',
  ),
  _Moment(
    '15:00',
    'Your doctor has just said "ALS". Your speech is still clear.',
    _Tool.bank,
    'Record your voice while you can. In 2019 a good synthetic voice needed 30-40 minutes of recordings.',
  ),
  _Moment(
    '17:30',
    'You\'re hard of hearing and on a video call with family.',
    _Tool.captions,
    'Captions keep you in the conversation, and you can type back.',
  ),
];

class _Day extends StatefulWidget {
  const _Day();

  @override
  State<_Day> createState() => _DayState();
}

class _DayState extends State<_Day> {
  final _pick = <int, _Tool>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(5);
    final right = _pick.entries.where((e) => _moments[e.key].best == e.value).length;
    return DemoCard(
      title: 'A day with the tools',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Different people, one day. Pick the tool that helps at each moment.'),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < _moments.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    _moments[i].time,
                    style: AppText.mono.copyWith(color: accent, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(_moments[i].text, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in _Tool.values)
                  ChoiceChip(
                    key: ValueKey('acc-$i-${t.name}'),
                    label: Text(_toolNames[t]!),
                    selected: _pick[i] == t,
                    selectedColor: (_moments[i].best == t ? accent : c.amber).withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _pick[i] = t),
                  ),
              ],
            ),
            if (_pick[i] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  p == _moments[i].best
                      ? 'Yes. ${_moments[i].why}'
                      : 'Try another. Best: "${_toolNames[_moments[i].best]}".',
                  key: ValueKey('acc-why-$i'),
                  style: TextStyle(color: p == _moments[i].best ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_pick.length == _moments.length)
            Text(
              'Right tool: $right of ${_moments.length}. The same kind of AI that chats with you can read, listen and '
              'speak for people who need it most.',
              key: const ValueKey('acc-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
