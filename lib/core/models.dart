import 'package:flutter/widgets.dart';

/// A citable source. Shown on the Sources page and in fact sheets.
class Source {
  const Source(this.id, this.title, {this.url, this.publisher, this.year});
  final String id;
  final String title;
  final String? url;
  final String? publisher;
  final String? year;
}

/// A verified fact (see research/facts.md). The app shows numbers only through facts.
class Fact {
  const Fact(this.id, this.text, {required this.sources, this.value});
  final String id;
  final String text;
  final String? value;
  final List<String> sources;
}

/// Engineering term ↔ everyday term.
class GlossaryTerm {
  const GlossaryTerm(this.term, this.everyday, this.definition, {this.section = 0, this.aliases = const []});
  final String term;
  final String everyday;
  final String definition;
  final int section;
  final List<String> aliases;
}

class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.answer, this.explain);
  final String question;
  final List<String> options;
  final int answer;
  final String explain;
}

/// One lesson screen in a section.
class LessonInfo {
  const LessonInfo({
    required this.id,
    required this.section,
    required this.title,
    required this.builder,
    this.subtitle = '',
  });
  final String id;
  final int section;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

/// Which side of the app a track belongs to: the front door for everyone, or the Enthusiast Lab.
enum Area { everyday, lab }

/// A track of lessons (sections 1-3 are the original journey, now the Lab's "Foundations").
/// A track may reuse lessons whose home is another track (the Everyday short journey does);
/// a lesson's [LessonInfo.section] is always its home track.
class SectionInfo {
  const SectionInfo({
    required this.number,
    required this.title,
    required this.tagline,
    required this.lessons,
    required this.quizId,
    this.area = Area.lab,
    this.tag = '',
  });
  final int number;
  final String title;
  final String tagline;
  final List<LessonInfo> lessons;

  /// Empty = no quiz at the end of this track.
  final String quizId;
  final Area area;

  /// Short label on hubs and lesson headers ("Hardware", "Run it yourself").
  final String tag;

  /// Sections 1-3 keep their "Section n" names; the newer tracks are named by their tag.
  String get label => number <= 3 ? 'Section $number' : tag;
}

/// An annotated research paper on the Lab's paper shelf (generated into content/papers.dart).
/// [sourceId] is its entry in the source library, which holds the bundled copy.
class Paper {
  const Paper({
    required this.sourceId,
    required this.short,
    required this.year,
    required this.authors,
    required this.oneIdea,
    required this.summary,
    required this.whyItMattered,
    required this.inYourTools,
    required this.readThis,
    required this.skipThis,
    required this.terms,
    required this.check,
  });
  final String sourceId, short, year, authors, oneIdea, summary, whyItMattered, inYourTools, skipThis;
  final List<String> readThis;
  final List<(String, String)> terms;
  final List<QuizQuestion> check;
}

class PaperGroup {
  const PaperGroup(this.title, this.papers);
  final String title;
  final List<Paper> papers;
}
