import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_master/data/models/questions_response_model.dart';
import 'package:quiz_master/data/result_mapper.dart';
import 'package:quiz_master/models/question.dart';

void main() {
  group('ResultMapper Unit Tests', () {
    test('toQuestions maps empty API results list to empty list', () {
      final questions = ResultMapper.toQuestions([]);
      expect(questions, isEmpty);
    });

    test('toQuestions filters out invalid questions and maps valid ones', () {
      final apiResults = [
        Result(
          question: 'Valid question?',
          correctAnswer: 'Yes',
          incorrectAnswers: ['No', 'Maybe'],
          difficulty: 'easy',
          category: 'General',
        ),
        Result(
          question: null, // Invalid
          correctAnswer: 'Yes',
          incorrectAnswers: ['No'],
          difficulty: 'hard',
          category: 'General',
        ),
        Result(
          question: 'Invalid incorrect answers?',
          correctAnswer: 'Yes',
          incorrectAnswers: [], // Invalid
          difficulty: 'medium',
          category: 'General',
        ),
      ];

      final questions = ResultMapper.toQuestions(apiResults);
      expect(questions.length, equals(1));
      expect(questions[0].text, equals('Valid question?'));
      expect(questions[0].difficulty, equals(Difficulty.easy));
      expect(questions[0].category, equals('General'));
      expect(questions[0].options, containsAll(['Yes', 'No', 'Maybe']));
    });

    test('toQuestions decodes HTML entities correctly', () {
      final apiResults = [
        Result(
          question: 'Is &quot;Flutter&quot; &amp; &ldquo;Dart&rdquo; easy?',
          correctAnswer: 'Yes &#039;sure&#039;',
          incorrectAnswers: ['No', 'Maybe &ndash; not sure'],
          difficulty: 'medium',
          category: 'General',
        ),
      ];

      final questions = ResultMapper.toQuestions(apiResults);
      expect(questions.length, equals(1));
      expect(questions[0].text, equals('Is "Flutter" & "Dart" easy?'));
      expect(questions[0].correctAnswer, equals("Yes 'sure'"));
      expect(questions[0].options, contains("Maybe – not sure"));
    });
  });
}
