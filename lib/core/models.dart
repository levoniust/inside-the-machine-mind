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

class SectionInfo {
  const SectionInfo({
    required this.number,
    required this.title,
    required this.tagline,
    required this.lessons,
    required this.quizId,
  });
  final int number;
  final String title;
  final String tagline;
  final List<LessonInfo> lessons;
  final String quizId;
}
