import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../content/quant_naming.dart';
import '../../widgets/components.dart';
import '../../widgets/lesson_scaffold.dart';
import '../../widgets/term_text.dart';

/// Section 3 · "Decoding model filenames": read Q4_K_M, IQ1_S, UD-Q5_K_XL and friends.
/// Tap-to-crack filename decoder + a bits-per-weight size calculator + a decoder-ring reference.
/// Facts: QN-BPW, QN-70B-MATH, QN-MIX, QN-4BIT-OK.
class S3QuantsScreen extends StatelessWidget {
  const S3QuantsScreen({super.key});

  @override
  Widget build(BuildContext context) => const LessonScaffold(
        lessonId: 's3_quants',
        children: [
          _CrackTheName(),
          SizedBox(height: Gap.l),
          _SizeCalculator(),
          SizedBox(height: Gap.l),
          FactCard(
            value: '15 → 4.6 GB',
            label: 'llama.cpp measured this on a real 8B model: a [[K-quant|Q4_K_M]] file is about a third the size of the original — and an [[importance matrix]] claws back even more of the quality',
            factId: 'QN-4BIT-OK',
          ),
          SizedBox(height: Gap.l),
          _DecoderRing(),
        ],
      );
}

Color _kindColor(BuildContext context, String kind) {
  final c = AppColors.of(context);
  return switch (kind) {
    'model' => c.cyan,
    'quant' => c.magenta,
    'tag' => c.amber,
    _ => c.violet,
  };
}

class _CrackTheName extends StatefulWidget {
  const _CrackTheName();

  @override
  State<_CrackTheName> createState() => _CrackTheNameState();
}

class _CrackTheNameState extends State<_CrackTheName> {
  int _file = 0;
  int? _part;

  void _pickFile(int i) => setState(() {
        _file = i;
        _part = null;
      });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final parts = sampleFilenames[_file];
    final name = parts.map((p) => p.part).join();
    return DemoCard(
      title: 'Crack the filename',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('1 · Pick a download', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < sampleFilenames.length; i++)
                ChoiceChip(
                  key: ValueKey('quant-file-$i'),
                  label: Text(sampleFilenames[i].map((p) => p.part).join()),
                  selected: _file == i,
                  selectedColor: c.magenta.withValues(alpha: 0.25),
                  onSelected: (_) => _pickFile(i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Text('2 · Tap each piece of the name', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Semantics(
            label: 'The filename $name, split into tappable pieces',
            child: Wrap(
              spacing: 0,
              runSpacing: Gap.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < parts.length; i++)
                  ActionChip(
                    key: ValueKey('quant-part-$i'),
                    avatar: Icon(Icons.touch_app_outlined, size: 15, color: _kindColor(context, parts[i].kind)),
                    label: Text(parts[i].part, style: AppText.mono.copyWith(fontSize: 13, color: c.text)),
                    backgroundColor: _part == i ? _kindColor(context, parts[i].kind).withValues(alpha: 0.28) : c.surfaceHi,
                    side: BorderSide(color: _part == i ? _kindColor(context, parts[i].kind) : c.line),
                    onPressed: () => setState(() => _part = i),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Gap.m),
          Container(
            key: const ValueKey('quant-explain'),
            padding: const EdgeInsets.all(Gap.m),
            decoration: BoxDecoration(
              color: c.surfaceHi,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _part == null ? c.line : _kindColor(context, parts[_part!].kind)),
            ),
            child: _part == null
                ? Text('Tap a piece above and I\'ll tell you what it means.', style: TextStyle(color: c.textDim))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parts[_part!].part, style: AppText.mono.copyWith(color: _kindColor(context, parts[_part!].kind), fontSize: 14)),
                      const SizedBox(height: Gap.xs),
                      Text(kindLabelFor(parts[_part!].kind), style: TextStyle(color: c.textDim, fontSize: 12, fontStyle: FontStyle.italic)),
                      const SizedBox(height: Gap.xs),
                      Text(parts[_part!].what, style: TextStyle(color: c.text, height: 1.4)),
                    ],
                  ),
          ),
          const SizedBox(height: Gap.m),
          TermText(
            'One secret before the decoder ring: a model\'s knowledge is smeared across billions of numbers, like a photo spread over millions of pixels. '
            'Blurring every number a little barely changes the picture — that\'s why a quarter of the memory can cost almost nothing in quality.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

String kindLabelFor(String kind) => kindLabels[kind] ?? kind;

class _SizeCalculator extends StatefulWidget {
  const _SizeCalculator();

  @override
  State<_SizeCalculator> createState() => _SizeCalculatorState();
}

class _SizeCalculatorState extends State<_SizeCalculator> {
  static const formats = [
    (label: 'F32', bpw: 32.0),
    (label: 'F16', bpw: 16.0),
    (label: 'Q8_0', bpw: 8.0),
    (label: 'Q4_K', bpw: 4.5),
    (label: 'IQ4_XS', bpw: 4.25),
    (label: 'IQ3_XXS', bpw: 3.06),
    (label: 'IQ1_S', bpw: 1.5),
  ];
  int _model = 1;
  int _format = 3;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final params = calcModels[_model].params;
    final bpw = formats[_format].bpw;
    final gb = params * bpw / 8 / 1e9;
    final frac = (bpw / 32).clamp(0.0, 1.0);
    return DemoCard(
      title: 'What does a number cost?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Pick a mind and a storage format', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.xs),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < calcModels.length; i++)
                ChoiceChip(
                  key: ValueKey('quant-calc-model-$i'),
                  label: Text(calcModels[i].label),
                  selected: _model == i,
                  selectedColor: c.cyan.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _model = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.s),
          Wrap(
            spacing: Gap.s,
            runSpacing: Gap.s,
            children: [
              for (var i = 0; i < formats.length; i++)
                ChoiceChip(
                  key: ValueKey('quant-calc-format-$i'),
                  label: Text(formats[i].label),
                  selected: _format == i,
                  selectedColor: c.magenta.withValues(alpha: 0.25),
                  onSelected: (_) => setState(() => _format = i),
                ),
            ],
          ),
          const SizedBox(height: Gap.m),
          Row(
            children: [
              Expanded(
                child: Text('Weights on disk', style: TextStyle(color: c.textDim)),
              ),
              Text(
                gb >= 10 ? '${gb.toStringAsFixed(0)} GB' : '${gb.toStringAsFixed(1)} GB',
                key: const ValueKey('quant-calc-size'),
                style: AppText.mono.copyWith(color: c.text, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
          Semantics(
            label: 'Bar showing ${(frac * 100).round()} percent of the widest format (32 bits per weight)',
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
                      child: Container(color: c.magenta),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: Gap.s),
          Text(
            '${_plain(params)} numbers × $bpw bits ÷ 8 = ${gb >= 10 ? gb.toStringAsFixed(0) : gb.toStringAsFixed(1)} GB',
            style: AppText.mono.copyWith(color: c.textDim, fontSize: 12),
          ),
          const SizedBox(height: Gap.s),
          TermText(
            'A real Q4_K_M file lands a little above the bare math: the handful of layers the model leans on hardest keep more bits. '
            'That mixing is what the S / M / L letters in a [[K-quant|k-quant]] name choose.',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _plain(double params) => switch (params) {
        8e9 => '8,000,000,000',
        70e9 => '70,000,000,000',
        _ => '405,000,000,000',
      };
}

class _DecoderRing extends StatefulWidget {
  const _DecoderRing();

  @override
  State<_DecoderRing> createState() => _DecoderRingState();
}

class _DecoderRingState extends State<_DecoderRing> {
  final Set<int> _open = {};

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return DemoCard(
      title: 'The decoder ring',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tap any name to open it', style: TextStyle(color: c.textDim)),
          const SizedBox(height: Gap.s),
          for (var i = 0; i < formatRows.length; i++)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  key: ValueKey('decoder-row-$i'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _open.contains(i) ? _open.remove(i) : _open.add(i)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Gap.s, horizontal: Gap.xs),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 118,
                          // Long names ("Q4_K / Q5_K / Q6_K") shrink instead of wrapping into 3 lines.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(formatRows[i].name, style: AppText.mono.copyWith(color: c.cyan, fontSize: 12.5)),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _open.contains(i)
                                ? formatRows[i].line
                                : formatRows[i].line.split(RegExp(r'(?<=\.) ')).first,
                            style: TextStyle(color: _open.contains(i) ? c.text : c.textDim, fontSize: 13, height: 1.35),
                          ),
                        ),
                        Icon(_open.contains(i) ? Icons.expand_less : Icons.expand_more, color: c.textDim, size: 18),
                      ],
                    ),
                  ),
                ),
                if (i != formatRows.length - 1) Divider(height: 1, thickness: 0.5, color: c.line),
              ],
            ),
          const SizedBox(height: Gap.m),
          TermText(
            'Formats with a GGUF tag, a k-quant or an [[I-quant|i-quant]] inside the name all come from the open-source llama.cpp project — the same engine many '
            'home tools use. GPTQ, AWQ and EXL2 are other projects\' recipes for the same trick: spend fewer bits per number, and spend them where they matter. '
            'The measuring stick for all of it is [[bits per weight]].',
            style: TextStyle(color: c.textDim, fontSize: 13),
          ),
          const SizedBox(height: Gap.l),
          const FactCard(
            value: '1.5–32 bits/weight',
            label: 'Every llama.cpp format, measured — from IQ1_S\'s drastic 1.5 bits to plain F32',
            factId: 'QN-BPW',
          ),
        ],
      ),
    );
  }
}
