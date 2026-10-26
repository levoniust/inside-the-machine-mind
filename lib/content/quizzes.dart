import '../core/models.dart';
import 'quiz_s2.dart';
import 'quiz_s3.dart';
import 'quiz_s5.dart';
import 'quiz_s6.dart';
import 'quiz_s7.dart';
import 'quiz_s9.dart';

/// Quiz questions per section. Answers must match research/facts.md.
const quizS1 = <QuizQuestion>[
  QuizQuestion(
    'Which memory sits right next to an AI chip, stacked like a skyscraper?',
    ['A hard drive', 'HBM (High Bandwidth Memory)', 'A USB stick', 'CPU cache on the motherboard'],
    1,
    'HBM chips are stacked on top of each other and placed beside the GPU, giving it terabytes per second of bandwidth.',
  ),
  QuizQuestion(
    'Why are GPUs better than CPUs at running AI?',
    [
      'They have bigger and faster fans',
      'They do thousands of simple sums at once',
      'They can store many more files',
      'They connect to the internet faster',
    ],
    1,
    'AI is mostly matrix multiplication: huge numbers of simple, independent math steps. That suits an army of GPU cores.',
  ),
  QuizQuestion(
    'Roughly how much memory does it take just to hold a 70-billion-parameter model at 16-bit precision?',
    ['140 MB', '14 GB', '140 GB', '14 TB'],
    2,
    '2 bytes per parameter × 70 billion = 140 GB, more than any single GPU holds.',
  ),
  QuizQuestion(
    'What does "bandwidth" describe?',
    [
      'How long data takes to start arriving',
      'How much data can flow per second',
      'How hot a chip runs',
      'How many cores a chip has',
    ],
    1,
    'Bandwidth is the width of the road: how many gigabytes per second can move. Latency is the wait before the first car arrives.',
  ),
  QuizQuestion(
    'Why are the newest AI racks liquid-cooled?',
    [
      'Liquid is cheaper than air',
      'Water carries far more heat than air',
      'It makes them quieter for visitors',
      'Water makes the chips compute more accurately',
    ],
    1,
    'Water carries roughly 3,500× more heat than the same volume of air, and an NVL72 rack makes ~120 kW of heat.',
  ),
  QuizQuestion(
    'What does a PUE of 1.5 mean?',
    [
      'The building uses 50% extra power on top of the computers',
      'The chips run at 150% speed',
      'There are 1.5 GPUs per server',
      'It uses 1.5 litres of water',
    ],
    0,
    'PUE = total power ÷ computing power. 1.5 means for every watt of computing, half a watt goes to cooling and losses.',
  ),
  QuizQuestion(
    'About how much electricity did all the world\'s data centres use in 2024?',
    ['0.01% of global electricity', 'About 1.5%', 'About 25%', 'More than half'],
    1,
    'The IEA estimates ~415 TWh, about 1.5% of global electricity, and expects it to more than double, to ~945 TWh, by 2030.',
  ),
  QuizQuestion(
    'What links GPUs inside a server so they can share data super fast?',
    ['Wi-Fi', 'USB', 'NVLink', 'Bluetooth'],
    2,
    'NVLink is a private express lane between GPUs: 900 GB/s per GPU on H100 and 1.8 TB/s on Blackwell.',
  ),
  QuizQuestion(
    'Almost all the math inside an AI model is one operation. Which?',
    ['Square roots of every knob', 'Matrix multiplication', 'Sorting long lists of words', 'Counting letters in words'],
    1,
    'Every token passes through giant grids of knobs by matrix multiplication: about one multiply and one add per knob.',
  ),
  QuizQuestion(
    'Why do AI chips like using FP8 or FP4 numbers instead of FP32?',
    [
      'They are more exact than FP32',
      'Phones can only read those formats',
      'They take less memory and are faster',
      'They stop the model from making mistakes',
    ],
    3,
    'Fewer bits per number means a smaller model and faster math. Neural networks tolerate the rounding surprisingly well.',
  ),
  QuizQuestion(
    'Roughly how many GPUs did xAI\'s first Colossus cluster in Memphis start with?',
    ['About 1,000', 'About 10,000', 'About 100,000', 'About 10 million'],
    2,
    'Around 100,000 H100 GPUs, installed in about 122 days in 2024.',
  ),
];

/// The Everyday short journey re-uses verified questions from the lessons it visits.
final quizS4 = <QuizQuestion>[
  quizS1[1],
  quizS1[6],
  quizS2[0],
  quizS2[1],
  quizS2[2],
  quizS2[9],
  quizS3[0],
  quizS3[4],
  quizS3[7],
  quizS3[6],
];

final quizzes = <String, List<QuizQuestion>>{
  'quiz_s1': quizS1,
  'quiz_s2': quizS2,
  'quiz_s3': quizS3,
  'quiz_s4': quizS4,
  'quiz_s5': quizS5,
  'quiz_s6': quizS6,
  'quiz_s7': quizS7,
  'quiz_s9': quizS9,
};
