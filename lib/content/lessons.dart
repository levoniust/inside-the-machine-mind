import 'package:flutter/widgets.dart';

import '../core/models.dart';
import '../widgets/lesson_scaffold.dart';

// Each lesson's screen lives in lib/screens/s<N>/<id>.dart. Lessons without a screen yet
// show a placeholder (PlaceholderLesson) so the app always runs.

WidgetBuilder _todo(String id) => (_) => PlaceholderLesson(lessonId: id);

LessonInfo _l(String id, int section, String title, [String subtitle = '', WidgetBuilder? builder]) =>
    LessonInfo(id: id, section: section, title: title, subtitle: subtitle, builder: builder ?? _todo(id));

final List<SectionInfo> sections = [
  SectionInfo(
    number: 1,
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
  ),
  SectionInfo(
    number: 2,
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
      _l('s2_parallel', 2, 'Splitting the work', 'Parallelism'),
      _l('s2_things_break', 2, 'When things break', 'Failures & checkpoints'),
      _l('s2_testing', 2, 'Exams along the way', 'Benchmarks'),
      _l('s2_post_training', 2, 'From parrot to assistant', 'Fine-tuning & RLHF'),
      _l('s2_safety', 2, 'Testing for safety', 'Red-teaming'),
      _l('s2_scaling_laws', 2, 'Bigger = smarter?', 'Scaling laws'),
      _l('s2_big_small', 2, 'Big models and small models'),
      _l('s2_making_small', 2, 'How small models are made', 'Distillation, quantization, MoE'),
    ],
  ),
  SectionInfo(
    number: 3,
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
      _l('s3_frontier', 3, 'A frontier model in the datacenter'),
      _l('s3_serving', 3, 'Serving a billion people'),
      _l('s3_beyond_text', 3, 'Beyond words', 'Images, voice & agents'),
      _l('s3_timeline', 3, 'What people do with it', 'From AlphaGo to Opus 5.5'),
      _l('s3_robots', 3, 'Minds with bodies', 'Robots'),
      _l('s3_science', 3, 'Minds for science and the world'),
      _l('s3_answer', 3, 'The answer arrives'),
    ],
  ),
];

/// All lessons in journey order.
final List<LessonInfo> allLessons = [for (final s in sections) ...s.lessons];

final Map<String, LessonInfo> _byId = {for (final l in allLessons) l.id: l};

LessonInfo? lessonById(String id) => _byId[id];

SectionInfo sectionOf(LessonInfo l) => sections[l.section - 1];

/// Next lesson inside the same section, or null at the end of the section.
LessonInfo? nextInSection(String id) {
  final l = _byId[id];
  if (l == null) return null;
  final list = sectionOf(l).lessons;
  final i = list.indexWhere((x) => x.id == id);
  return i + 1 < list.length ? list[i + 1] : null;
}

LessonInfo? prevInSection(String id) {
  final l = _byId[id];
  if (l == null) return null;
  final list = sectionOf(l).lessons;
  final i = list.indexWhere((x) => x.id == id);
  return i > 0 ? list[i - 1] : null;
}
