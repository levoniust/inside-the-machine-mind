import 'package:flutter/widgets.dart';

import '../core/models.dart';
import '../screens/screen_registry.dart';
import '../widgets/lesson_scaffold.dart';

// Each lesson's screen lives in lib/screens/s<N>/<id>.dart and is registered in
// lib/screens/screen_registry.dart. Lessons without a screen yet show a placeholder.

WidgetBuilder _todo(String id) => screenBuilders[id] ?? (_) => PlaceholderLesson(lessonId: id);

LessonInfo _l(String id, int section, String title, [String subtitle = '', WidgetBuilder? builder]) =>
    LessonInfo(id: id, section: section, title: title, subtitle: subtitle, builder: builder ?? _todo(id));

final _hardware = SectionInfo(
  number: 1,
  tag: 'Hardware',
  title: 'Where the Mind Lives',
  tagline: 'The hardware: from a hard drive to a 100,000-GPU datacenter',
  quizId: 'quiz_s1',
  lessons: [
    _l('s1_intro', 1, 'Where does a thought live?'),
    _l('s1_storage', 1, 'The warehouse and the shelf', 'HDD vs SSD'),
    _l('s1_ram', 1, 'Your desk', 'System RAM'),
    _l('s1_memory_types', 1, 'The memory family', 'Cache, DDR, GDDR, HBM'),
    _l('s1_cpu_gpu', 1, 'Master chefs vs an army of cooks', 'CPU vs GPU'),
    _l('s1_matmul', 1, 'The one math trick behind AI', 'Matrix multiplication'),
    _l('s1_precision', 1, 'How precise is a number?', 'FP32 to FP4'),
    _l('s1_links', 1, 'Highways between the parts', 'PCIe, NVLink, InfiniBand'),
    _l('s1_too_big', 1, 'Why one chip isn\'t enough'),
    _l('s1_server', 1, 'Eight GPUs in a box', 'The AI server'),
    _l('s1_rack', 1, 'A rack that thinks as one', 'NVL72'),
    _l('s1_datacenter', 1, 'Into the datacenter', 'Build your own'),
    _l('s1_power_cooling', 1, 'Feeding and cooling the beast', 'Power & heat'),
    _l('s1_real_sites', 1, 'Real giants', 'Colossus, Stargate & more'),
    _l('s1_data_scale', 1, 'How much data lives here?'),
  ],
);

final _training = SectionInfo(
  number: 2,
  tag: 'Training',
  title: 'How the Mind Grew',
  tagline: 'Training: how billions of knobs get tuned, step by step',
  quizId: 'quiz_s2',
  lessons: [
    _l('s2_intro', 2, 'School vs the job', 'Training vs inference'),
    _l('s2_decoder', 2, 'The word decoder', 'Engineer-speak → plain English'),
    _l('s2_library', 2, 'Gathering the library', 'Where the data comes from'),
    _l('s2_cleaning', 2, 'Cleaning the library', 'Filtering & de-duplication'),
    _l('s2_tokens', 2, 'Chopping text into tokens', 'The tokenizer'),
    _l('s2_empty_brain', 2, 'Building an empty brain', 'The transformer'),
    _l('s2_attention', 2, 'Who should I listen to?', 'Attention'),
    _l('s2_guess', 2, 'Step 1: guess the next word'),
    _l('s2_loss', 2, 'Step 2: how wrong was it?', 'Loss'),
    _l('s2_backprop', 2, 'Step 3: passing the blame backward', 'Backpropagation'),
    _l('s2_descent', 2, 'Step 4: rolling downhill', 'Gradient descent'),
    _l('s2_train_it', 2, 'Train a tiny brain yourself'),
    _l('s2_scale_up', 2, 'Now do it trillions of times', 'Compute'),
    _l('s2_memory_budget', 2, 'What fills the GPU during training', 'Memory budget'),
    _l('s2_step_hardware', 2, 'One step, inside the hardware', 'Where the math happens'),
    _l('s2_parallel', 2, 'Splitting the work', 'Parallelism'),
    _l('s2_things_break', 2, 'When things break', 'Failures & checkpoints'),
    _l('s2_testing', 2, 'Exams along the way', 'Benchmarks'),
    _l('s2_post_training', 2, 'From parrot to assistant', 'Fine-tuning & RLHF'),
    _l('s2_safety', 2, 'Testing for safety', 'Red-teaming'),
    _l('s2_scaling_laws', 2, 'Bigger = smarter?', 'Scaling laws'),
    _l('s2_big_small', 2, 'Big models and small models'),
    _l('s2_making_small', 2, 'How small models are made', 'Distillation, quantization, MoE'),
  ],
);

final _inference = SectionInfo(
  number: 3,
  tag: 'Inference',
  title: 'The Mind Answers',
  tagline: 'Inference: how a question becomes an answer, and what we do with it',
  quizId: 'quiz_s3',
  lessons: [
    _l('s3_intro', 3, 'Ask the question'),
    _l('s3_tokenize', 3, 'Your words become tokens'),
    _l('s3_embeddings', 3, 'Tokens become coordinates', 'Embeddings'),
    _l('s3_tiny_model', 3, 'A tiny model, step by step'),
    _l('s3_sampling', 3, 'Picking the next word', 'Temperature & top-p'),
    _l('s3_loop', 3, 'One word at a time', 'The generation loop'),
    _l('s3_at_home', 3, 'Running AI at home', 'PCs, Macs & DGX Spark'),
    _l('s3_quants', 3, 'Decoding model filenames', 'Reading Q4_K_M & friends'),
    _l('s3_frontier', 3, 'A frontier model in the datacenter'),
    _l('s3_serving', 3, 'Serving a billion people'),
    _l('s3_beyond_text', 3, 'Beyond words', 'Images, voice & agents'),
    _l('s3_timeline', 3, 'What people do with it', 'From AlphaGo to Opus 5.5'),
    _l('s3_robots', 3, 'Minds with bodies', 'Robots'),
    _l('s3_science', 3, 'Minds for science and the world'),
    _l('s3_answer', 3, 'The answer arrives'),
  ],
);

final _foundations = [_hardware, _training, _inference];

/// A lesson from the original three sections, reused in another track.
LessonInfo _reuse(String id) => _foundations.expand((s) => s.lessons).firstWhere((l) => l.id == id);

// ---------- Everyday (the front door) ----------

final _journey = SectionInfo(
  number: 4,
  area: Area.everyday,
  tag: 'The short journey',
  title: 'Why is the sky blue?',
  tagline: 'Follow one question through the machine, the short way',
  quizId: 'quiz_s4',
  lessons: [
    for (final id in [
      's1_intro',
      's1_cpu_gpu',
      's1_datacenter',
      's2_intro',
      's2_library',
      's2_tokens',
      's2_guess',
      's2_train_it',
      's2_post_training',
      's2_safety',
      's3_intro',
      's3_tokenize',
      's3_sampling',
      's3_loop',
      's3_beyond_text',
      's3_timeline',
      's3_answer',
    ])
      _reuse(id),
  ],
);

final _newAi = SectionInfo(
  number: 11,
  area: Area.everyday,
  tag: 'How the new AI works',
  title: 'How the new AI works',
  tagline: 'Agents, thinking, memory, pictures, voice and the energy behind it',
  quizId: '',
  lessons: [
    _l('e_agents', 11, 'When the assistant does things', 'Agents and permissions'),
    _l('e_thinking', 11, 'Thinking before answering', 'Reasoning models'),
    _l('e_energy', 11, 'How much energy is one question?', 'From one prompt to the whole USA'),
    _l('e_memory', 11, 'How the app remembers you', 'Context window and memory'),
    _l('e_pictures', 11, 'How a picture appears from noise', 'Image generators'),
    _l('e_voice', 11, 'Talking to AI', 'Speech in, speech out'),
  ],
);

final _life = SectionInfo(
  number: 5,
  area: Area.everyday,
  tag: 'AI in your life',
  title: 'AI in your life',
  tagline: 'Using chatbots well, safely and honestly',
  quizId: 'quiz_s5',
  lessons: [
    _l('e_good_bad', 5, 'Confident guesses', 'What chatbots are good and bad at'),
    _l('e_asking', 5, 'Asking well', 'Getting better answers'),
    _l('e_privacy', 5, 'Where your words go', 'Privacy in the big apps'),
    _l('e_fakes', 5, 'Fakes and scams', 'Voice clones, deepfakes, AI phishing'),
    _l('e_school_work', 5, 'AI at school and work', 'Honest use'),
    _l('e_which', 5, 'Which assistant for what?', 'Chat, images, voice, code'),
    _l('e_model_size', 5, 'Big or small model?', 'Pick the right size for the job'),
    _l('e_bias', 5, 'Why answers can lean one way', 'Bias'),
    _l('e_advice', 5, 'Health, money and legal questions', 'Ask it or ask a person?'),
    _l('e_ai_text', 5, 'Was this written by AI?', 'Why detectors fail'),
    _l('e_access', 5, 'AI that helps people see, hear and speak', 'Real stories'),
    _l('e_at_home', 5, 'Can I run one at home?', 'A peek into the Lab'),
  ],
);

// ---------- Enthusiast Lab (Foundations = sections 1-3) ----------

final _run = SectionInfo(
  number: 6,
  tag: 'Run it yourself',
  title: 'Run it yourself',
  tagline: 'Models on your own hardware: sizing, engines, quants, speed',
  quizId: 'quiz_s6',
  lessons: [
    _l('l_will_it_fit', 6, 'Will it fit?', 'VRAM, RAM and speed calculator'),
    _l('l_runtimes', 6, 'The engines', 'llama.cpp, Ollama, LM Studio, vLLM, MLX'),
    _l('l_quant_pick', 6, 'Picking a quant', 'Perplexity, KL divergence, imatrix'),
    _l('l_kv_cache', 6, 'Context costs memory', 'The KV cache'),
    _l('l_moe_home', 6, 'A giant on a gaming PC', 'MoE offloading'),
    _l('l_speed_tricks', 6, 'Guess ahead, check fast', 'Speculative decoding & MTP'),
    _l('l_frontends', 6, 'Beyond the chat box', 'Front-ends, RAG, tools, agents'),
    _l('l_home_rig', 6, 'A real home rig', 'Two GPUs, power and heat'),
    _l('l_split_gpus', 6, 'Splitting a model across GPUs', 'Layer split vs tensor split'),
    _l('l_speech_home', 6, 'Speech at home', 'Whisper, Piper and Windows voices'),
    _l('l_safe_server', 6, 'Keeping a home AI server safe', 'Ports, tokens and agents'),
  ],
);

final _custom = SectionInfo(
  number: 7,
  tag: 'Customize it',
  title: 'Customize it',
  tagline: 'Prompting, RAG, fine-tuning, merging and steering',
  quizId: 'quiz_s7',
  lessons: [
    _l('l_which_custom', 7, 'Prompt, retrieve or train?', 'Choosing the right tool'),
    _l('l_notes_helper', 7, 'Build your own notes helper', 'RAG start to finish'),
    _l('l_tools_mcp', 7, 'Tools and MCP under the hood', 'The JSON the model sees'),
    _l('l_lora', 7, 'Small patches for big models', 'LoRA & QLoRA'),
    _l('l_datasets', 7, 'Teaching by example', 'Fine-tuning data & chat templates'),
    _l('l_merging', 7, 'Mixing models', 'Model merging'),
    _l('l_steering', 7, 'Steering a model', 'Control vectors & abliteration'),
    _l('l_inside', 7, 'Looking inside the model', 'Interpretability'),
  ],
);

final _papers = SectionInfo(
  number: 8,
  tag: 'Read the papers',
  title: 'Read the papers',
  tagline: 'How to read a research paper, and the papers behind today\'s tools',
  quizId: '',
  lessons: [
    _l('l_paper_anatomy', 8, 'How to read a paper', 'Abstract, figures, method, results'),
    _l('l_paper_shelf', 8, 'The paper shelf', 'Annotated papers, from word2vec to R1'),
  ],
);

final _sota = SectionInfo(
  number: 9,
  tag: 'State of the art',
  title: 'State of the art',
  tagline: 'What is current right now, with dates',
  quizId: 'quiz_s9',
  lessons: [
    _l('l_sota_models', 9, 'The models right now', 'Frontier & open weights'),
    _l('l_sota_hardware', 9, 'The hardware right now', 'Datacenter & desk'),
    _l('l_sota_techniques', 9, 'Tricks everyone uses now', 'Reasoning, MoE, long context, agents'),
    _l('l_leaderboards', 9, 'Reading the leaderboards', 'And their traps'),
    _l('l_this_year', 9, 'What changed this year', 'A dated timeline'),
  ],
);

final _industry = SectionInfo(
  number: 10,
  tag: 'Industry map',
  title: 'Industry map',
  tagline: 'Who makes what, the jobs around AI, and how to keep up',
  quizId: '',
  lessons: [
    _l('l_who_makes', 10, 'Who makes what', 'Labs, chips, clouds, open source'),
    _l('l_jobs', 10, 'Jobs around AI', 'Not only researchers'),
    _l('l_keep_up', 10, 'How to keep up', 'Papers, newsletters, communities'),
  ],
);

/// Every track, indexed by number - 1.
final List<SectionInfo> sections = [
  _hardware,
  _training,
  _inference,
  _journey,
  _life,
  _run,
  _custom,
  _papers,
  _sota,
  _industry,
  _newAi,
];

/// The original three sections (the Lab's "Foundations").
List<SectionInfo> get foundations => _foundations;

/// Front-door tracks and Lab tracks (Lab = Foundations first), in display order.
List<SectionInfo> get everydayTracks => [_journey, _newAi, _life];
List<SectionInfo> get labTracks => [_run, _custom, _papers, _sota, _industry];

/// All lessons in journey order, each once.
final List<LessonInfo> allLessons = {
  for (final s in sections)
    for (final l in s.lessons) l.id: l,
}.values.toList();

final Map<String, LessonInfo> _byId = {for (final l in allLessons) l.id: l};

LessonInfo? lessonById(String id) => _byId[id];

SectionInfo sectionOf(LessonInfo l) => sections[l.section - 1];

/// The track a lesson is shown in: [track] if given (a lesson reused in another track), else its home section.
SectionInfo trackOf(LessonInfo l, [int? track]) =>
    track != null && track >= 1 && track <= sections.length && sections[track - 1].lessons.any((x) => x.id == l.id)
    ? sections[track - 1]
    : sectionOf(l);

/// Next lesson inside the same track, or null at the end of the track.
LessonInfo? nextInSection(String id, [int? track]) {
  final l = _byId[id];
  if (l == null) return null;
  final list = trackOf(l, track).lessons;
  final i = list.indexWhere((x) => x.id == id);
  return i + 1 < list.length ? list[i + 1] : null;
}

LessonInfo? prevInSection(String id, [int? track]) {
  final l = _byId[id];
  if (l == null) return null;
  final list = trackOf(l, track).lessons;
  final i = list.indexWhere((x) => x.id == id);
  return i > 0 ? list[i - 1] : null;
}

/// The track after [number] in its own area (Foundations 1 → 2 → 3, Everyday 4 → 11 → 5, Lab 6 → … → 10), or null.
/// Track 11 was added in v2.1; it sits between 4 and 5 on screen but keeps its own number so saved progress stays valid.
SectionInfo? nextTrack(int number) => switch (number) {
  4 => _newAi,
  11 => _life,
  1 || 2 => sections[number],
  >= 6 && < 10 => sections[number],
  _ => null,
};
