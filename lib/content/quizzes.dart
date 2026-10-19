import '../core/models.dart';

/// Quiz questions per section. Answers must match research/facts.md.
const quizzes = <String, List<QuizQuestion>>{
  'quiz_s1': [
    QuizQuestion('Which memory sits right next to an AI chip, stacked like a skyscraper?',
        ['A hard drive', 'HBM (High Bandwidth Memory)', 'A USB stick', 'CPU cache on the motherboard'], 1,
        'HBM chips are stacked on top of each other and placed beside the GPU, giving it terabytes per second of bandwidth.'),
    QuizQuestion('Why are GPUs better than CPUs at running AI?',
        ['They have bigger fans', 'They do thousands of simple multiplications at the same time',
         'They store more files', 'They connect to the internet faster'], 1,
        'AI is mostly matrix multiplication: huge numbers of simple, independent math steps. That suits an army of GPU cores.'),
    QuizQuestion('Roughly how much memory does it take just to hold a 70-billion-parameter model at 16-bit precision?',
        ['140 MB', '14 GB', '140 GB', '14 TB'], 2,
        '2 bytes per parameter × 70 billion = 140 GB, more than any single GPU holds.'),
    QuizQuestion('What does "bandwidth" describe?',
        ['How long data takes to start arriving', 'How much data can flow per second', 'How hot a chip runs', 'How many cores a chip has'], 1,
        'Bandwidth is the width of the road: how many gigabytes per second can move. Latency is the wait before the first car arrives.'),
    QuizQuestion('Why are the newest AI racks liquid-cooled?',
        ['Liquid is cheaper than air', 'Water carries far more heat than air', 'It makes them quieter for visitors', 'Air would freeze the chips'], 1,
        'Water carries roughly 3,500× more heat than the same volume of air, and an NVL72 rack makes ~120 kW of heat.'),
    QuizQuestion('What does a PUE of 1.5 mean?',
        ['The building uses 50% extra power on top of the computers', 'The chips run at 150% speed', 'There are 1.5 GPUs per server', 'It uses 1.5 litres of water'], 0,
        'PUE = total power ÷ computing power. 1.5 means for every watt of computing, half a watt goes to cooling and losses.'),
    QuizQuestion('About how much electricity did all the world\'s data centres use in 2024?',
        ['0.01% of global electricity', 'About 1.5%', 'About 25%', 'More than half'], 1,
        'The IEA estimates ~415 TWh, about 1.5% of global electricity, and expects it to roughly double by 2030.'),
    QuizQuestion('What links GPUs inside a server so they can share data super fast?',
        ['Wi-Fi', 'USB', 'NVLink', 'Bluetooth'], 2,
        'NVLink is a private express lane between GPUs: 900 GB/s per GPU on H100 and 1.8 TB/s on Blackwell.'),
  ],
  'quiz_s2': [],
  'quiz_s3': [],
};
