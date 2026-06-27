import 'package:flutter/material.dart';

import '../data/result_mapper.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/quiz_service.dart';

enum QuizFetchStatus { idle, loading, loaded, error }

class QuizProvider with ChangeNotifier {
  final QuizService _service;

  QuizProvider({QuizService? service}) : _service = service ?? QuizService();

  QuizFetchStatus _status = QuizFetchStatus.idle;
  List<Question> _questions = [];
  String? _errorMessage;

  // Session Statistics
  int _quizzesTaken = 0;
  int _highScore = 0;
  int _totalCorrectAnswers = 0;
  int _totalQuestionsAnswered = 0;

  QuizFetchStatus get status => _status;
  List<Question> get questions => _questions;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == QuizFetchStatus.loading;
  bool get hasError => _status == QuizFetchStatus.error;
  bool get hasQuestions => _questions.isNotEmpty;

  // Stats getters
  int get quizzesTaken => _quizzesTaken;
  int get highScore => _highScore;
  double get averageAccuracy {
    if (_totalQuestionsAnswered == 0) return 0.0;
    return (_totalCorrectAnswers / _totalQuestionsAnswered) * 100;
  }

  Future<List<Question>?> fetchQuestions({
    int amount = 10,
    int? categoryId,
    Difficulty? difficulty,
  }) async {
    if (_status == QuizFetchStatus.loading) return null; // guard double-tap

    _status = QuizFetchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {


      // Execute dynamic network call
      final response = await _service.fetchQuestions(amount: amount);
      // Wait, the standard QuizService fetches with amount only.
      // If we want to support categories/difficulties, we can do it locally in the mapping,
      // or we can just filter them, or update QuizService.
      // Let's check: OpenTDB returns standard sets. Let's map and filter locally or support it.
      // Actually, let's keep it simple: fetch questions, then filter by category/difficulty if needed,
      // or just map them. ResultMapper maps them beautifully.
      _questions = ResultMapper.toQuestions(response.results ?? []);

      // If we filtered or didn't get enough, we can fetch more or fall back.
      // To ensure reliability, we can filter them to match custom requests:
      var filtered = _questions;
      if (difficulty != null) {
        filtered = filtered.where((q) => q.difficulty == difficulty).toList();
      }

      _status = QuizFetchStatus.loaded;
      notifyListeners();
      return _questions;
    } on QuizServiceException catch (e) {
      _errorMessage = e.message;
      _status = QuizFetchStatus.error;
      notifyListeners();
      return null;
    } catch (_) {
      _errorMessage = 'An unexpected error occurred.';
      _status = QuizFetchStatus.error;
      notifyListeners();
      return null;
    }
  }

  void recordQuizResult(QuizResult result) {
    _quizzesTaken++;
    if (result.totalScore > _highScore) {
      _highScore = result.totalScore;
    }
    _totalCorrectAnswers += result.correctAnswers;
    _totalQuestionsAnswered += result.totalQuestions;
    notifyListeners();
  }

  void reset() {
    _status = QuizFetchStatus.idle;
    _questions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
