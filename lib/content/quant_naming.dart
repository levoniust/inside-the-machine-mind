/// Reference content for the "Decoding model filenames" lesson (v1.2).
/// Every claim here is backed by lib/content/facts.dart sources:
/// SRC-LLAMACPP, SRC-LLAMACPP-WIKI, SRC-UNSLOTH-DV2, SRC-UNSLOTH-DOCS,
/// SRC-GPTQ, SRC-AWQ, SRC-EXL2, SRC-QLORA. Prose only — numbers live in facts.
library;

/// One piece of a quantized model filename.
class NamePart {
  const NamePart(this.part, this.kind, this.what, {this.example});

  /// The literal token, e.g. `Q4_K_M`.
  final String part;

  /// Grouping used for coloring: model, quant, format, tag.
  final String kind;

  /// Plain-language explanation.
  final String what;

  /// Optional extra example line.
  final String? example;
}

/// Sample filenames the user can crack, split into tappable parts.
const sampleFilenames = <List<NamePart>>[
  [
    NamePart('Llama-3.1-70B-', 'model', 'Which model, and how big. "70B" = 70 billion numbers (parameters) making up its mind.'),
    NamePart('Q4', 'quant', 'Q = quantized (compressed numbers). 4 = each number is stored in about 4 bits instead of 16 — a quarter of the space.'),
    NamePart('_K', 'quant', 'The "k-quant" packing scheme: weights are stored in groups of 32 with smarter shared notes about their size, so the same 4 bits lose less of the model.'),
    NamePart('_M', 'quant', 'Medium care: the few layers the model leans on hardest keep a higher precision. (S = less care, L = more.) This is the popular everyday choice.'),
    NamePart('.gguf', 'format', 'GGUF — the shipping carton, not the packing style: the standard file format an app like llama.cpp or Ollama reads.'),
  ],
  [
    NamePart('Qwen3-8B-', 'model', 'A smaller mind: 8 billion numbers. Small enough for a phone or a laptop.'),
    NamePart('IQ4_XS', 'quant', 'An "i-quant": the newest packing generation. Instead of rounding each number to steps on a ruler, it picks each number from a tiny built-in dictionary of allowed values — and XS means this dictionary squeezes harder than the plain ones.'),
    NamePart('.gguf', 'format', 'Same standard carton.'),
  ],
  [
    NamePart('gemma-3-12B-', 'model', 'Google\'s Gemma family, 12 billion numbers.'),
    NamePart('UD-', 'tag', 'Unsloth Dynamic: not one ruler for the whole model, but a per-layer recipe — the important layers of this specific model get better treatment than the rest.'),
    NamePart('Q5_K_XL', 'quant', 'The base recipe: about 5 bits per weight with the k-quant packing; the XL (extra-large) dose of extra precision protects the most sensitive layers.'),
    NamePart('.gguf', 'format', 'Same carton again.'),
  ],
  [
    NamePart('Mistral-7B-', 'model', 'A 7-billion-number model from Mistral AI, the French lab famous for making small models punch above their size.'),
    NamePart('F16', 'quant', 'No compression at all: 16-bit floating-point numbers — the "half-precision" many models are trained and released in. F = float, 16 = bits.'),
    NamePart('.gguf', 'format', 'The carton.'),
  ],
];

/// What each kind means, for the legend chips.
const kindLabels = {'model': 'the model', 'quant': 'how numbers are stored', 'tag': 'special recipe', 'format': 'the file carton'};

/// A row of the "decoder ring" reference card.
class FormatRow {
  const FormatRow(this.name, this.line, {this.bpw});

  final String name;

  /// Nominal bits per weight, for the size calculator. Null = not in calculator.
  final double? bpw;

  /// One- or two-sentence explanation, verified against the sources.
  final String line;
}

/// The full decoder ring, in order: exact numbers first, then the packing families.
const formatRows = <FormatRow>[
  FormatRow('F32', 'Plain 32-bit numbers — the most detail any weight can get. Training math lives here; you almost never ship a model like this.', bpw: 32),
  FormatRow('F16 / FP16', '16-bit "half precision" — one of the two usual shapes a finished model is released in (the other is BF16). Two bytes per number.', bpw: 16),
  FormatRow('BF16', 'B = "brain float": a 16-bit number that keeps the huge range of 32-bit floats but less detail. The everyday training format of modern AI.', bpw: 16),
  FormatRow('FP8', '8-bit floats — used inside the fastest new datacenter chips for the math itself.', bpw: 8),
  FormatRow('NF4', 'A special 4-bit ruler whose 16 marks are spaced for bell-curve-shaped weights — which real model weights tend to be (the trick from the QLoRA work). Better placement beats evenly spaced marks.', bpw: 4),
  FormatRow('Q8_0', '8-bit quantization: half the size of F16 and, in practice, quality you can\'t tell apart. The "_0" means a simple symmetric block layout.', bpw: 8),
  FormatRow('Q5 / Q4 / Q3 / Q2', 'The number is simply the bits each weight gets. Plain (_0/_1) versions are the old, simple block layouts.', bpw: null),
  FormatRow('_0 vs _1', 'How much note-taking each 32-weight block does: _0 stores one shared scale; _1 also stores a shared starting point (the block\'s minimum), so it costs a few more bits and buys a little more accuracy.', bpw: null),
  FormatRow('Q4_K / Q5_K / Q6_K', 'k-quants: the smarter packing generation. Blocks of 32 are grouped into super-blocks with better shared notes, so a Q4_K file keeps far more of the model than the old Q4_0 at the same size. M/L variants spend a few extra bits on the most-important layers.', bpw: 4.5),
  FormatRow('_S / _M / _L', 'How much extra care the important layers get: S = small boost, M = medium (the default most people pick), L = large boost — a bit bigger, a bit better.', bpw: null),
  FormatRow('IQ1_S … IQ4_XS', 'i-quants: the newest generation. Every weight is picked from a tiny built-in dictionary of allowed values instead of a ruler — usually steered by an "importance matrix" (a test run that finds which weights matter most; required for the tiny IQ1/IQ2 sizes, optional above). Suffixes: XXS is the tightest squeeze for a bit count, then XS, S, M, L — and NL means non-linear: steps that are deliberately unevenly spaced.', bpw: null),
  FormatRow('UD-…_XL', 'Unsloth Dynamic: a per-model recipe that hands the most sensitive layers a higher precision while the rest take the hard squeeze. The "_XL" is the biggest dose of that protection.', bpw: null),
  FormatRow('GPTQ', 'A different quantizing recipe (outside GGUF): round the weights one by one, and each time, nudge the remaining weights to cancel the error just made.', bpw: null),
  FormatRow('AWQ', 'Another recipe: first find the few weights the model actually leans hardest on during real use, and shield those from aggressive rounding.', bpw: null),
  FormatRow('EXL2', 'Another carton (file format) for quantized weights, like GGUF — built for fast loading on GPUs by a different project.', bpw: null),
];

/// Size-calculator model sizes (parameters), reusing the same lineup as s3_at_home.
const calcModels = [
  (label: '8B', params: 8e9),
  (label: '70B', params: 70e9),
  (label: '405B', params: 405e9),
];
