import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Running AI at home": pick a machine, a model size and a precision; see whether the
/// model fits in memory and roughly how fast it can talk (speed ≈ memory bandwidth ÷ model size).
/// Facts: HW-GDDR-3090/4090/5090, HW-LPDDR-M4MAX, IN-SPARK, IN-BANDWIDTH-BOUND, TR-PHI3.
class S3AtHomeScreen extends StatelessWidget {
  const S3AtHomeScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(lessonId: 's3_at_home', children: [_Picker()]);
}

class Device {
  const Device(this.name, this.kind, this.memGb, this.bandwidthGbs, this.icon);
  final String name, kind;
  final double memGb, bandwidthGbs;
  final IconData icon;
}

const devices = [
  Device('RTX 3090', 'gaming graphics card', 24, 936, Icons.videogame_asset_outlined),
  Device('RTX 4090', 'gaming graphics card', 24, 1008, Icons.videogame_asset_outlined),
  Device('RTX 5090', 'gaming graphics card', 32, 1792, Icons.videogame_asset_outlined),
  Device('Mac (M4 Max)', 'laptop, unified memory', 128, 546, Icons.laptop_mac),
  Device('DGX Spark', 'AI mini-computer, unified memory', 128, 273, Icons.developer_board),
];

const modelSizes = [3.8e9, 8e9, 70e9, 405e9];
const modelNames = ['3.8B (phone-sized)', '8B', '70B', '405B (giant)'];
const bitOptions = [16, 8, 4];

/// Memory a model needs (weights only, plus ~10% working space) and the bandwidth-bound speed estimate.
class HomeRun {
  const HomeRun(this.device, this.params, this.bits);
  final Device device;
  final double params;
  final int bits;

  double get weightsGb => params * bits / 8 / 1e9;
  double get neededGb => weightsGb * 1.1;
  bool get fits => neededGb <= device.memGb;
  double get tokensPerSecond => device.bandwidthGbs / weightsGb;
}

class _Picker extends StatefulWidget {
  const _Picker();

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  int _device = 4;
  int _model = 2;
  int _bits = 1;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final run = HomeRun(devices[_device], modelSizes[_model], bitOptions[_bits]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DemoCard(
          title: 'Can my machine run it?',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('1 · Pick a machine', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.xs),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var i = 0; i < devices.length; i++)
                    ChoiceChip(
                      key: ValueKey('home-device-$i'),
                      avatar: Icon(devices[i].icon, size: 18),
                      label: Text(devices[i].name),
                      selected: _device == i,
                      selectedColor: c.magenta.withValues(alpha: 0.25),
                      onSelected: (_) => setState(() => _device = i),
                    ),
                ],
              ),
              const SizedBox(height: Gap.s),
              Text(
                '${run.device.kind}: ${run.device.memGb.round()} GB memory, ${run.device.bandwidthGbs.round()} GB/s',
                style: AppText.mono.copyWith(color: c.text, fontSize: 13),
              ),
              const SizedBox(height: Gap.l),
              Text('2 · Pick a model size', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.xs),
              Wrap(
                spacing: Gap.s,
                runSpacing: Gap.s,
                children: [
                  for (var i = 0; i < modelSizes.length; i++)
                    ChoiceChip(
                      key: ValueKey('home-model-$i'),
                      label: Text(modelNames[i]),
                      selected: _model == i,
                      selectedColor: c.magenta.withValues(alpha: 0.25),
                      onSelected: (_) => setState(() => _model = i),
                    ),
                ],
              ),
              const SizedBox(height: Gap.l),
              Text('3 · Squeeze it (precision)', style: TextStyle(color: c.textDim)),
              const SizedBox(height: Gap.xs),
              SegmentedButton<int>(
                key: const ValueKey('home-bits'),
                segments: [
                  for (var i = 0; i < bitOptions.length; i++)
                    ButtonSegment(value: i, label: Text('${bitOptions[i]}-bit')),
                ],
                selected: {_bits},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _bits = s.first),
              ),
              const SizedBox(height: Gap.l),
              _MemoryBar(run: run),
              const SizedBox(height: Gap.m),
              Container(
                key: const ValueKey('home-verdict'),
                padding: const EdgeInsets.all(Gap.m),
                decoration: BoxDecoration(
                  color: (run.fits ? c.lime : c.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (run.fits ? c.lime : c.red).withValues(alpha: 0.6)),
                ),
                child: Text(
                  run.fits
                      ? 'It fits! Expect up to roughly ${run.tokensPerSecond.toStringAsFixed(run.tokensPerSecond < 10 ? 1 : 0)} tokens per second.'
                      : 'Doesn\'t fit: it needs ~${run.neededGb.toStringAsFixed(0)} GB but this machine has ${run.device.memGb.round()} GB. '
                            'Try fewer bits or a smaller model.',
                  style: TextStyle(color: c.text, fontWeight: FontWeight.w600),
                ),
              ),
              if (run.fits) ...[const SizedBox(height: Gap.m), _TalkingSpeed(tokensPerSecond: run.tokensPerSecond)],
              const SizedBox(height: Gap.m),
              TermText(
                'Why this math works: to write each new word the chip must read (almost) every weight from memory once. '
                'Reading takes model size ÷ [[bandwidth]] seconds, so words per second ≈ [[bandwidth]] ÷ model size. Real speeds are a bit lower; this is the ceiling.',
                style: TextStyle(color: c.textDim, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.l),
        const FactCard(
          value: '128 GB · 1.2 kg',
          label: 'DGX Spark: a desktop box with [[unified memory]] that runs models up to ~200B knobs',
          factId: 'IN-SPARK',
        ),
      ],
    );
  }
}

class _MemoryBar extends StatelessWidget {
  const _MemoryBar({required this.run});
  final HomeRun run;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final frac = (run.neededGb / run.device.memGb).clamp(0.0, 1.0);
    final over = run.neededGb > run.device.memGb;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Memory needed', style: TextStyle(color: c.textDim)),
            ),
            Text(
              '${run.neededGb.toStringAsFixed(run.neededGb < 10 ? 1 : 0)} / ${run.device.memGb.round()} GB',
              style: AppText.mono.copyWith(color: over ? c.red : c.text),
            ),
          ],
        ),
        const SizedBox(height: Gap.xs),
        Semantics(
          label: 'Memory bar: ${(frac * 100).round()} percent full${over ? ', overflowing' : ''}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 22,
              child: Stack(
                children: [
                  Container(color: c.surfaceHi),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    widthFactor: frac,
                    child: Container(color: over ? c.red : c.magenta),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Types a sample sentence at the estimated speed (≈ 0.75 words per token).
class _TalkingSpeed extends StatefulWidget {
  const _TalkingSpeed({required this.tokensPerSecond});
  final double tokensPerSecond;

  @override
  State<_TalkingSpeed> createState() => _TalkingSpeedState();
}

class _TalkingSpeedState extends State<_TalkingSpeed> with SingleTickerProviderStateMixin {
  static const words = [
    'Sunlight',
    'is',
    'a',
    'mix',
    'of',
    'colors,',
    'and',
    'the',
    'air',
    'scatters',
    'blue',
    'light',
    'the',
    'most,',
    'so',
    'the',
    'sky',
    'looks',
    'blue.',
  ];
  late final Ticker _ticker = createTicker(_onTick);
  int _shown = 0;

  void _onTick(Duration elapsed) {
    final wordsPerSecond = (widget.tokensPerSecond * 0.75).clamp(0.5, 60.0);
    final n = (elapsed.inMilliseconds / 1000 * wordsPerSecond).floor() % (words.length + 6);
    if (n != _shown) setState(() => _shown = n);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _ticker.stop();
      _shown = words.length;
    } else if (!_ticker.isActive) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(_TalkingSpeed old) {
    super.didUpdateWidget(old);
    if (old.tokensPerSecond != widget.tokensPerSecond && _ticker.isActive) {
      _ticker
        ..stop()
        ..start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(Gap.m),
      decoration: BoxDecoration(color: c.surfaceHi, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Talking speed preview', style: TextStyle(color: c.textDim, fontSize: 12)),
          const SizedBox(height: Gap.xs),
          SizedBox(
            height: 48,
            child: Text(words.take(_shown.clamp(0, words.length)).join(' '), style: TextStyle(color: c.text)),
          ),
        ],
      ),
    );
  }
}
