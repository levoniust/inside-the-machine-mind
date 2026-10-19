import 'package:flutter/material.dart';

import '../content/lessons.dart';
import '../screens/extras/quiz_screen.dart';
import '../screens/home/section_hub.dart';

Route<T> _route<T>(WidgetBuilder b, String name) =>
    MaterialPageRoute<T>(builder: b, settings: RouteSettings(name: name));

/// Open a lesson on top of the current screen.
Future<void> openLesson(BuildContext context, String id) {
  final l = lessonById(id);
  if (l == null) return Future.value();
  return Navigator.of(context).push(_route(l.builder, '/lesson/$id'));
}

/// Replace the current lesson with another (Back/Next inside a section).
void replaceLesson(BuildContext context, String id) {
  final l = lessonById(id);
  if (l == null) return;
  Navigator.of(context).pushReplacement(_route(l.builder, '/lesson/$id'));
}

Future<void> openSection(BuildContext context, int number) =>
    Navigator.of(context).push(_route((_) => SectionHub(number: number), '/section/$number'));

Future<void> openQuiz(BuildContext context, String quizId) =>
    Navigator.of(context).push(_route((_) => QuizScreen(quizId: quizId), '/quiz/$quizId'));

void replaceQuiz(BuildContext context, String quizId) =>
    Navigator.of(context).pushReplacement(_route((_) => QuizScreen(quizId: quizId), '/quiz/$quizId'));

Future<void> openPage(BuildContext context, Widget page, String name) =>
    Navigator.of(context).push(_route((_) => page, name));
