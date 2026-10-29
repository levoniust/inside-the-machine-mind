import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Speech at home: Whisper sizes (speech to text), the voices already in Windows plus Piper (text to speech), and
/// "Pick a voice setup" for four everyday needs. Facts SPCH-* (Whisper/faster-whisper READMEs, Microsoft, Piper).
class LSpeechHomeScreen extends StatelessWidget {
  const LSpeechHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.of(context).section(6);
    return LessonScaffold(
      lessonId: 'l_speech_home',
      children: [
        const _Ears(),
        const _Voices(),
        const _PickSetup(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: FactCard(
                value: '2m23s → 16 s',
                label: '13 minutes of audio on a gaming GPU: original Whisper vs batched 8-bit faster-whisper',
                factId: 'SPCH-FW-GPU',
                color: accent,
              ),
            ),
            const SizedBox(width: Gap.m),
            Expanded(
              child: FactCard(
                value: '6m58s → 51 s',
                label: 'the same audio on a desktop CPU, small model, no GPU at all',
                factId: 'SPCH-FW-CPU',
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
// Speech to text: pick a Whisper size.

class _Size {
  const _Size(this.name, this.params, this.vram, this.speed, this.note);
  final String name, params, note;
  final double vram, speed;
}

const _sizes = [
  _Size('tiny', '39M', 1, 10, 'The fastest and smallest; it makes the most mistakes.'),
  _Size('base', '74M', 1, 7, 'Still about 1 GB: fine for short voice commands.'),
  _Size('small', '244M', 2, 4, 'A middle ground: ~4× large\'s speed at a sixth of its size.'),
  _Size('medium', '769M', 5, 2, 'Closer to large\'s accuracy; best with a GPU.'),
  _Size('large', '1,550M', 10, 1, 'The most accurate, and the slowest.'),
  _Size('turbo', '809M', 6, 8, 'Nearly large\'s accuracy at ~8× its speed, but it can\'t translate.'),
];

class _Ears extends StatefulWidget {
  const _Ears();

  @override
  State<_Ears> createState() => _EarsState();
}

class _EarsState extends State<_Ears> {
  int _i = 2;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final s = _sizes[_i];
    return DemoCard(
      title: 'Ears: speech to text with Whisper',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TermText(
            'OpenAI\'s Whisper is free to download and runs offline. It comes in six sizes: more [[parameters|parameter]] '
            'hear better but need more [[VRAM]] and time.',
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _sizes.length; i++)
                ChoiceChip(
                  key: ValueKey('speech-size-${_sizes[i].name}'),
                  label: Text(_sizes[i].name),
                  selected: i == _i,
                  selectedColor: accent.withValues(alpha: 0.3),
                  onSelected: (_) => setState(() => _i = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          StatGrid(
            columns: 3,
            children: [
              StatTile(label: 'Parameters', value: s.params),
              StatTile(label: 'VRAM', value: '~${s.vram.round()} GB'),
              StatTile(
                key: const ValueKey('speech-speed'),
                label: 'Speed vs large',
                value: '~${s.speed.round()}×',
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Text(s.note, key: ValueKey('speech-note-${s.name}')),
          const SizedBox(height: Gap.s),
          CompareBars(
            color: accent,
            highlight: _i,
            items: [for (final z in _sizes) BarItem(z.name, z.speed, display: '~${z.speed.round()}×')],
          ),
          const SizedBox(height: Gap.xs),
          Text(
            'Speeds from the Whisper README, measured on a datacenter GPU; at home they\'re slower, but the order holds. '
            'faster-whisper runs the same models up to 4× faster.',
            style: TextStyle(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: '6 sizes',
            label: 'tiny (39M) to large (1,550M), plus turbo',
            factId: 'SPCH-WHISPER-SIZES',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// Text to speech: what Windows already has, and Piper.

class _Voices extends StatelessWidget {
  const _Voices();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    Widget row(IconData icon, String title, String body, String factId) => Padding(
      padding: const EdgeInsets.only(bottom: Gap.s),
      child: Container(
        padding: const EdgeInsets.all(Gap.s),
        decoration: BoxDecoration(
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent),
            const SizedBox(width: Gap.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  TermText(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return DemoCard(
      title: 'Mouth: text to speech',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            Icons.desktop_windows_outlined,
            'Windows classic voices (already installed)',
            'English (US) comes with David, Mark and Zira. Any program can use them through Windows\' speech API, '
                'so even a two-line PowerShell script can read text aloud.',
            'SPCH-WIN-CLASSIC',
          ),
          row(
            Icons.record_voice_over_outlined,
            'Windows natural voices (free download)',
            'Newer, smoother voices such as Guy, Jenny and Aria. Open Settings → Accessibility → Narrator, then '
                '**Add natural voices**, pick one and install; it takes a few minutes.',
            'SPCH-WIN-NATURAL',
          ),
          row(
            Icons.home_outlined,
            'Piper (open source, any computer)',
            'A fast neural voice engine that runs entirely on your own machine. Home Assistant uses it for its '
                'voice, and so does the NVDA screen reader.',
            'SPCH-PIPER',
          ),
          Text('Try it on Windows (PowerShell):', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Gap.s),
            decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(8)),
            child: SelectableText(
              'Add-Type -AssemblyName System.Speech\n'
              '(New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak("Hello from my PC")',
              style: AppText.mono.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(height: Gap.s),
          const FactCard(
            value: 'Guy · Jenny · Aria',
            label: 'natural Narrator voices for US English',
            factId: 'SPCH-WIN-NATURAL',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------------------------------------------
// The game: four needs, three setups each.

class _Choice {
  const _Choice(this.text, this.why, {this.best = false});
  final String text, why;
  final bool best;
}

class _Need {
  const _Need(this.need, this.choices);
  final String need;
  final List<_Choice> choices;
}

const _needs = [
  _Need('Read my notes aloud on a Windows laptop, without installing anything.', [
    _Choice('Whisper large', 'Whisper listens; it can\'t speak. And it\'s a big download.'),
    _Choice(
      'Windows\' own voices',
      'Right: David, Mark and Zira are already there, and natural voices are a free add-on.',
      best: true,
    ),
    _Choice('A cloud voice service', 'Works, but it sends your notes away and usually needs an account.'),
  ]),
  _Need('A voice for a home assistant that works when the internet is down.', [
    _Choice(
      'Whisper base + Piper, on the home server',
      'Right: both run offline, and Home Assistant uses Piper for exactly this.',
      best: true,
    ),
    _Choice('Whisper large on a Raspberry Pi', 'Large wants ~10 GB of VRAM; a Pi would take ages per command.'),
    _Choice('Windows Narrator', 'Narrator reads your screen; it isn\'t a voice for other devices.'),
  ]),
  _Need('Transcribe a one-hour meeting recording on a gaming PC.', [
    _Choice('Whisper tiny', 'Fast, but it makes the most mistakes; a meeting deserves better.'),
    _Choice('Piper', 'Piper speaks; it doesn\'t listen.'),
    _Choice(
      'faster-whisper with turbo or large on the GPU',
      'Right: 13 minutes took 16 s batched on a gaming GPU, so an hour is a few minutes.',
      best: true,
    ),
  ]),
  _Need('Transcribe on an old laptop with no graphics card.', [
    _Choice(
      'Small Whisper, 8-bit, on the CPU',
      'Right: with faster-whisper, 13 minutes took 51 s on a desktop CPU; an older laptop is slower but fine.',
      best: true,
    ),
    _Choice('Whisper large', 'Without a GPU, large is painfully slow.'),
    _Choice('Wait until you buy a GPU', 'No need: small models run fine on a CPU.'),
  ]),
];

class _PickSetup extends StatefulWidget {
  const _PickSetup();

  @override
  State<_PickSetup> createState() => _PickSetupState();
}

class _PickSetupState extends State<_PickSetup> {
  final _picked = <int, int>{};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final accent = c.section(6);
    final right = _picked.entries.where((e) => _needs[e.key].choices[e.value].best).length;
    return DemoCard(
      title: 'Pick a voice setup',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var n = 0; n < _needs.length; n++) ...[
            Text('${n + 1}. ${_needs[n].need}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: Gap.xs),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _needs[n].choices.length; i++)
                  ChoiceChip(
                    key: ValueKey('speech-need-$n-$i'),
                    label: Text(_needs[n].choices[i].text),
                    selected: _picked[n] == i,
                    selectedColor: (_needs[n].choices[i].best ? accent : c.amber).withValues(alpha: 0.3),
                    onSelected: (_) => setState(() => _picked[n] = i),
                  ),
              ],
            ),
            if (_picked[n] case final p?)
              Padding(
                padding: const EdgeInsets.only(top: Gap.xs),
                child: Text(
                  _needs[n].choices[p].why,
                  key: ValueKey('speech-why-$n'),
                  style: TextStyle(color: _needs[n].choices[p].best ? accent : c.amber),
                ),
              ),
            const SizedBox(height: Gap.m),
          ],
          if (_picked.length == _needs.length)
            Text(
              'Best setups: $right of ${_needs.length}.',
              key: const ValueKey('speech-score'),
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
        ],
      ),
    );
  }
}
