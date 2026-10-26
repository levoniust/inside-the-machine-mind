import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machine_mind/content/fit_data.dart';
import 'package:machine_mind/screens/s6/l_will_it_fit.dart';

import '../helpers.dart';

FitResult _fit(String model, String quant, int ctx, String hw, {String kv = 'f16', double ram = 64, double ramBW = 89.6}) =>
    FitResult.compute(
      model: fitModels.firstWhere((m) => m.name.startsWith(model)),
      quant: fitQuants.firstWhere((q) => q.name == quant),
      context: ctx,
      kv: fitKvTypes.firstWhere((k) => k.name == kv),
      hw: fitHardware.firstWhere((h) => h.name.startsWith(hw)),
      ramGB: ram,
      ramBW: ramBW,
    );

void main() {
  test('Llama 3.1 8B Q4_K_M at 8k: 4.91 GB weights, exactly 1 GiB f16 KV cache, fits a 3090', () {
    final r = _fit('Llama 3.1 8B', 'Q4_K_M', 8192, 'RTX 3090');
    expect(r.weightsGB, closeTo(8.03 * 4.8944 / 8, 1e-9));
    expect(r.kvGB, closeTo(1073741824 / 1e9, 1e-9)); // 2 × 32 × 8 × 128 × 2 B × 8192
    expect(r.verdict, FitVerdict.fits);
    expect(r.tokPerSec, closeTo(936 / (r.weightsGB + r.kvGB), 1e-6));
  });

  test('q8_0 KV halves (roughly) the cache; sliding-window layers cap at the window', () {
    final f16 = _fit('Llama 3.1 8B', 'Q4_K_M', 32768, 'RTX 3090');
    final q8 = _fit('Llama 3.1 8B', 'Q4_K_M', 32768, 'RTX 3090', kv: 'q8_0');
    expect(q8.kvGB / f16.kvGB, closeTo(34 / 64, 1e-9));
    final oss = _fit('gpt-oss-120b', 'Q4_K_M', 131072, 'RTX 3090');
    // 18 full layers × 131072 + 18 sliding layers × 128 tokens, 2 × 8 × 64 numbers, 2 bytes each
    expect(oss.kvGB, closeTo((18 * 131072 + 18 * 128) * 1024 * 2 / 1e9, 1e-9));
  });

  test('70B at Q4_K_M needs offload on one 24 GB card, and does not fit with 16 GB RAM', () {
    expect(_fit('Llama 3.3 70B', 'Q4_K_M', 8192, 'RTX 3090').verdict, FitVerdict.offload);
    expect(_fit('Llama 3.3 70B', 'Q4_K_M', 8192, 'RTX 3090', ram: 16).verdict, FitVerdict.noFit);
    expect(_fit('Llama 3.1 8B', 'Q4_K_M', 8192, 'CPU only').verdict, FitVerdict.cpuOnly);
  });

  test('MoE speed uses active parameters only; DeepSeek MLA cache is 576 numbers per token per layer', () {
    final moe = _fit('Qwen3 30B-A3B', 'Q4_K_M', 4096, 'RTX 3090');
    final dense = _fit('Qwen3 32B', 'Q4_K_M', 4096, 'RTX 3090');
    expect(moe.tokPerSec! > 5 * dense.tokPerSec!, isTrue);
    expect(_fit('DeepSeek', 'Q4_K_M', 8192, 'Mac, M3 Ultra').kvGB, closeTo(61 * 576 * 2 * 8192 / 1e9, 1e-9));
  });

  testWidgets('picking a smaller card changes the verdict; the math opens', (tester) async {
    await pumpApp(tester, home: const LWillItFitScreen());
    await tester.scrollUntilVisible(find.byKey(const ValueKey('fit-verdict')), 300);
    expect(find.text('Fits on the GPU'), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('fit-model-2')), -300);
    await tester.tap(find.byKey(const ValueKey('fit-model-2'))); // Llama 3.3 70B
    await tester.pump();
    expect(find.text('Fits with offload to RAM (slower)'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('fit-math')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('fit-math')));
    await tester.pump();
    await tester.scrollUntilVisible(find.textContaining('weights = 70.6 B params'), 200);
    expect(find.textContaining('weights = 70.6 B params'), findsOneWidget);
    expectNoErrors(tester);
  });

  testWidgets('no overflow at large text in light mode', (tester) async {
    await pumpApp(tester, home: const LWillItFitScreen(), textScale: 1.3, brightness: Brightness.light);
    await pumpFrames(tester);
    expectNoErrors(tester);
  });
}
