import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_master/data/models/questions_response_model.dart';
import 'package:quiz_master/data/result_mapper.dart';
import 'package:quiz_master/models/question.dart';
import 'package:quiz_master/provider/auth_provider.dart';

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

  group('Mock AuthProvider Unit Tests', () {
    test('initial status is unknown, then becomes unauthenticated', () async {
      final auth = AuthProvider();
      expect(auth.status, equals(AuthStatus.unknown));

      // Wait for initial check delay
      await Future.delayed(const Duration(milliseconds: 1600));
      expect(auth.status, equals(AuthStatus.unauthenticated));
      expect(auth.isAuthenticated, isFalse);
    });

    test('signInWithEmail validates input and logs in', () async {
      final auth = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 1600));

      // Invalid email
      var success = await auth.signInWithEmail('invalid-email', '123456');
      expect(success, isFalse);
      expect(auth.status, equals(AuthStatus.unauthenticated));
      expect(auth.errorMessage, isNotNull);

      // Short password
      success = await auth.signInWithEmail('user@test.com', '123');
      expect(success, isFalse);
      expect(auth.status, equals(AuthStatus.unauthenticated));
      expect(auth.errorMessage, isNotNull);

      // Valid credentials
      success = await auth.signInWithEmail('user@test.com', '123456');
      expect(success, isTrue);
      expect(auth.status, equals(AuthStatus.authenticated));
      expect(auth.userEmail, equals('user@test.com'));
      expect(auth.isAuthenticated, isTrue);
    });

    test('continueAsGuest logs in as guest', () async {
      final auth = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 1600));

      await auth.continueAsGuest();
      expect(auth.status, equals(AuthStatus.authenticated));
      expect(auth.userEmail, equals('guest@quizmaster.com'));
      expect(auth.isAuthenticated, isTrue);
    });

    test('signOut resets authentication status', () async {
      final auth = AuthProvider();
      await Future.delayed(const Duration(milliseconds: 1600));

      await auth.continueAsGuest();
      expect(auth.isAuthenticated, isTrue);

      await auth.signOut();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.status, equals(AuthStatus.unauthenticated));
      expect(auth.userEmail, isNull);
    });
  });
}
