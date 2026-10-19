/// Bit's words for each lesson: intro bubbles (shown at the top) and the key idea (shown at the end).
/// Markup: `[[term]]` links a glossary term, `**bold**` for emphasis.
class LessonText {
  const LessonText({required this.intro, required this.keyIdea});
  final List<String> intro;
  final String keyIdea;
}

const narration = <String, LessonText>{
  // Filled in from design/narrative.md.
};

LessonText narrationFor(String lessonId) =>
    narration[lessonId] ?? const LessonText(intro: ['Let\'s explore this together!'], keyIdea: '');
