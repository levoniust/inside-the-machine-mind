/// "New in this version" for the Enthusiast Lab hub. Refresh every release (the app is offline on purpose,
/// so freshness comes with updates); keep [labNewsDate] honest.
class LabNews {
  const LabNews(this.text, {this.lessonId});
  final String text;
  final String? lessonId;
}

const labNewsDate = 'Oct 2026';

const labNews = [
  LabNews('The Enthusiast Lab opens: run models yourself, customize them, read the papers, keep up.'),
  LabNews('Will it fit? A calculator for VRAM, RAM, context and speed.', lessonId: 'l_will_it_fit'),
  LabNews(
    'The paper shelf: annotated walkthroughs from word2vec to DeepSeek-R1, each with a bundled copy.',
    lessonId: 'l_paper_shelf',
  ),
  LabNews(
    'State of the art, dated: the models, hardware and tricks that are current right now.',
    lessonId: 'l_sota_models',
  ),
];
