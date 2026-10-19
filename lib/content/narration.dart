import 'narration_s1.dart';
import 'narration_s2.dart';
import 'narration_s3.dart';

/// Bit's words for each lesson: intro bubbles (shown at the top) and the key idea (shown at the end).
/// Markup: `[[term]]` links a glossary term, `**bold**` for emphasis.
class LessonText {
  const LessonText({required this.intro, required this.keyIdea});
  final List<String> intro;
  final String keyIdea;
}

/// All narration, generated per section from `design/narrative-sN.md` (tools/narr2dart.py).
const narration = <String, LessonText>{...narrationS1, ...narrationS2, ...narrationS3, ...narrationExtras};

/// Hand-written narration for screens outside the three sections.
const narrationExtras = <String, LessonText>{};

LessonText narrationFor(String lessonId) =>
    narration[lessonId] ?? const LessonText(intro: ['Let\'s explore this together!'], keyIdea: '');
