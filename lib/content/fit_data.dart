/// Data for the "Will it fit?" calculator (l_will_it_fit). Every number here is a fact in research/facts.md
/// (RUN-BPW-FILE, RUN-SHAPE-*, hardware HW-*/SOTA-HW-*); keep them in sync.
library;

/// A model preset: size and the shape numbers that decide the KV cache.
class FitModel {
  const FitModel(
    this.name,
    this.totalB,
    this.activeB,
    this.layers,
    this.kvHeads,
    this.headDim, {
    required this.maxContext,
    this.attnHeads = 0,
    this.scaledContext,
    this.slidingLayers = 0,
    this.window = 0,
    this.kvElemsOverride,
    this.factId,
  });
  final String name;

  /// Parameters in billions: all of them, and the ones used per token (same for dense models).
  final double totalB, activeB;
  final int layers, kvHeads, headDim;

  /// Query (attention) heads. More than [kvHeads] = grouped-query attention: several heads share one K/V pair.
  final int attnHeads;

  /// Context the model was trained for, and (if any) how far RoPE scaling such as YaRN officially stretches it.
  final int maxContext;
  final int? scaledContext;

  /// Layers that only remember the last [window] tokens (sliding-window attention).
  final int slidingLayers, window;

  /// K+V numbers stored per token per layer, when the model compresses its cache (DeepSeek MLA).
  final int? kvElemsOverride;
  final String? factId;

  bool get moe => activeB < totalB;
  int get kvElemsPerLayer => kvElemsOverride ?? 2 * kvHeads * headDim;
}

const fitModels = [
  FitModel('Llama 3.1 8B', 8.03, 8.03, 32, 8, 128, attnHeads: 32, maxContext: 131072, factId: 'RUN-SHAPE-L8B'),
  FitModel(
    'Qwen3 32B',
    32.8,
    32.8,
    64,
    8,
    128,
    attnHeads: 64,
    maxContext: 32768,
    scaledContext: 131072,
    factId: 'RUN-SHAPE-Q32B',
  ),
  FitModel('Llama 3.3 70B', 70.6, 70.6, 80, 8, 128, attnHeads: 64, maxContext: 131072, factId: 'RUN-SHAPE-L70B'),
  FitModel(
    'Qwen3 30B-A3B (MoE)',
    30.5,
    3.3,
    48,
    4,
    128,
    attnHeads: 32,
    maxContext: 32768,
    scaledContext: 131072,
    factId: 'RUN-SHAPE-Q30BA3B',
  ),
  FitModel(
    'gpt-oss-120b (MoE)',
    117,
    5.1,
    36,
    8,
    64,
    attnHeads: 64,
    maxContext: 131072,
    slidingLayers: 18,
    window: 128,
    factId: 'RUN-SHAPE-GPTOSS',
  ),
  FitModel(
    'Qwen3 235B-A22B (MoE)',
    235,
    22,
    94,
    4,
    128,
    attnHeads: 64,
    maxContext: 32768,
    scaledContext: 131072,
    factId: 'RUN-SHAPE-Q235B',
  ),
  FitModel(
    'DeepSeek V3 / R1 671B (MoE)',
    671,
    37,
    61,
    0,
    0,
    attnHeads: 128,
    maxContext: 131072,
    kvElemsOverride: 576,
    factId: 'RUN-SHAPE-DSV3',
  ),
];

/// Whole-file bits per weight measured on Llama 3.1 8B (llama.cpp quantize README); other models land close.
class FitQuant {
  const FitQuant(this.name, this.bpw);
  final String name;
  final double bpw;
}

const fitQuants = [
  FitQuant('IQ2_XXS', 2.3824),
  FitQuant('IQ3_XXS', 3.2548),
  FitQuant('IQ4_XS', 4.4597),
  FitQuant('Q4_K_M', 4.8944),
  FitQuant('Q5_K_M', 5.7036),
  FitQuant('Q6_K', 6.5633),
  FitQuant('Q8_0', 8.5008),
  FitQuant('F16', 16.0005),
];

/// KV cache element types (llama.cpp --cache-type-k/-v): bytes per number.
class FitKvType {
  const FitKvType(this.name, this.bytes);
  final String name;
  final double bytes;
}

const fitKvTypes = [FitKvType('f16', 2), FitKvType('q8_0', 34 / 32), FitKvType('q4_0', 18 / 32)];

/// A machine: fast memory (GPU VRAM or a unified pool) with its bandwidth, plus normal RAM for offloading.
class FitHardware {
  const FitHardware(this.name, this.fastGB, this.fastBW, {this.unified = false, this.factId});
  final String name;
  final double fastGB, fastBW;

  /// Unified memory (Macs, DGX Spark): one pool shared by the system and the model; no separate RAM to spill to.
  final bool unified;
  final String? factId;
}

const fitHardware = [
  FitHardware('CPU only', 0, 0),
  FitHardware('RTX 3060 12 GB', 12, 360, factId: 'RUN-HW-3060'),
  FitHardware('RTX 4060 Ti 16 GB', 16, 288, factId: 'RUN-HW-4060TI'),
  FitHardware('RTX 3090 24 GB', 24, 936, factId: 'HW-GDDR-3090'),
  FitHardware('RTX 4090 24 GB', 24, 1008, factId: 'HW-GDDR-4090'),
  FitHardware('RTX 5090 32 GB', 32, 1792, factId: 'HW-GDDR-5090'),
  FitHardware('2 × RTX 3090 (48 GB)', 48, 936, factId: 'HW-GDDR-3090'),
  FitHardware('Mac, M4 Max 128 GB', 128, 546, unified: true, factId: 'HW-LPDDR-M4MAX'),
  FitHardware('DGX Spark 128 GB', 128, 273, unified: true, factId: 'RUN-HW-SPARK'),
  FitHardware('Mac, M3 Ultra 512 GB', 512, 819, unified: true, factId: 'HW-LPDDR-M3ULTRA'),
];

/// System RAM choices for offloading: (label, GB/s). Dual-channel peak = MT/s × 8 bytes × 2.
const fitRamSpeeds = [
  ('DDR4-3200, 2 channels', 51.2),
  ('DDR5-5600, 2 channels', 89.6),
  ('DDR5-6400, 8 channels', 409.6),
];

/// Everything the calculator shows, from the user's choices.
class FitResult {
  FitResult._(
    this.weightsGB,
    this.kvGB,
    this.overheadGB,
    this.fastGB,
    this.ramGB,
    this.onFastGB,
    this.inRamGB,
    this.tokPerSec,
    this.verdict,
  );
  final double weightsGB, kvGB, overheadGB, fastGB, ramGB, onFastGB, inRamGB;

  /// Upper bound on generation speed (memory-bandwidth bound), null if it doesn't fit.
  final double? tokPerSec;
  final FitVerdict verdict;
  double get totalGB => weightsGB + kvGB + overheadGB;

  /// GB that a unified-memory machine keeps for the system (rough rule, shown as such).
  static const unifiedReserveGB = 8.0;

  static FitResult compute({
    required FitModel model,
    required FitQuant quant,
    required int context,
    required FitKvType kv,
    required FitHardware hw,
    required double ramGB,
    required double ramBW,
  }) {
    final weights = model.totalB * quant.bpw / 8; // GB, since B params × bytes
    final fullLayers = model.layers - model.slidingLayers;
    final cachedTokens = fullLayers * context + model.slidingLayers * (context < model.window ? context : model.window);
    final kvGB = cachedTokens * model.kvElemsPerLayer * kv.bytes / 1e9;
    final overhead = 0.5 + 0.02 * weights; // compute buffers etc.: a rough rule, labelled as such in the app
    final total = weights + kvGB + overhead;
    final fast = hw.unified ? (hw.fastGB - unifiedReserveGB).clamp(0, double.infinity).toDouble() : hw.fastGB;
    final ram = hw.unified ? 0.0 : ramGB * 0.9; // leave some RAM for the system
    final onFast = total < fast ? total : fast;
    final inRam = total - onFast;
    final verdict = inRam <= 0
        ? FitVerdict.fits
        : inRam <= ram
        ? (fast == 0 ? FitVerdict.cpuOnly : FitVerdict.offload)
        : FitVerdict.noFit;

    double? speed;
    if (verdict != FitVerdict.noFit) {
      // Each new token reads the active weights once plus the whole KV cache.
      final activeGB = model.activeB * quant.bpw / 8;
      final ramShare = weights == 0 ? 0.0 : (inRam / total).clamp(0.0, 1.0);
      final fromRam = (activeGB + kvGB) * ramShare;
      final fromFast = (activeGB + kvGB) - fromRam;
      final seconds = (fromFast > 0 ? fromFast / hw.fastBW : 0) + (fromRam > 0 ? fromRam / ramBW : 0);
      speed = seconds > 0 && seconds.isFinite ? 1 / seconds : null;
    }
    return FitResult._(weights, kvGB, overhead, fast, ram, onFast, inRam, speed, verdict);
  }
}

enum FitVerdict { fits, offload, cpuOnly, noFit }
