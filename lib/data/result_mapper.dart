import 'dart:math';

import '../models/question.dart';
import 'models/questions_response_model.dart';

class ResultMapper {
  /// Maps a list of [Result] from the API into domain [Question] objects.
  static List<Question> toQuestions(List<Result> results) {
    return results
        .where(
          (r) =>
              r.question != null &&
              r.correctAnswer != null &&
              r.incorrectAnswers != null &&
              r.incorrectAnswers!.isNotEmpty,
        )
        .map(_toQuestion)
        .toList();
  }

  static Question _toQuestion(Result r) {
    final correct = _decode(r.correctAnswer!);
    final incorrect = r.incorrectAnswers!.map(_decode).toList();

    // Build shuffled options and track the correct index.
    final options = [correct, ...incorrect]..shuffle(Random());
    final correctIndex = options.indexOf(correct);

    return Question(
      id: _decode(r.question!).hashCode.toString(),
      text: _decode(r.question!),
      options: options,
      correctIndex: correctIndex,
      category: _decode(r.category ?? 'General'),
      difficulty: _mapDifficulty(r.difficulty),
    );
  }

  static Difficulty _mapDifficulty(String? value) {
    switch (value?.toLowerCase()) {
      case 'easy':
        return Difficulty.easy;
      case 'hard':
        return Difficulty.hard;
      default:
        return Difficulty.medium;
    }
  }

  /// Decodes common HTML entities returned by OpenTDB.
  static String _decode(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—');
  }
}
