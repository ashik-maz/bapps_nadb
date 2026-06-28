import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';

enum QuizFetchStatus { idle, loading, loaded, error }

class QuizProvider with ChangeNotifier {
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

  /// Fetches questions from Firestore, shuffling and selecting a subset
  /// that ensures all categories are represented when category is 'All'.
  Future<List<Question>?> fetchQuestions({
    int amount = 25,
    String category = 'All',
    Difficulty? difficulty,
  }) async {
    if (_status == QuizFetchStatus.loading) return null;

    _status = QuizFetchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch all questions from the Firestore 'questions' collection
      final snapshot = await FirebaseFirestore.instance.collection('questions').get();
      if (snapshot.docs.isEmpty) {
        throw Exception('No questions found in Firestore database.');
      }

      final List<Question> allQuestions = snapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          id: data['id'] ?? doc.id,
          text: data['text'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctIndex: int.tryParse(data['correctIndex']?.toString() ?? '0') ?? 0,
          category: data['category'] ?? 'General',
          difficulty: _mapDifficulty(data['difficulty']?.toString()),
          explanation: data['explanation'],
        );
      }).toList();

      // 2. Filter by category if a specific one is selected
      var filtered = allQuestions;
      if (category != 'All') {
        filtered = filtered.where((q) => q.category == category).toList();
      }

      // 3. Filter by difficulty if selected
      if (difficulty != null) {
        filtered = filtered.where((q) => q.difficulty == difficulty).toList();
      }

      if (filtered.isEmpty) {
        throw Exception('No questions matched the selected criteria.');
      }

      // 4. Sample selected questions arbitrarily but ensuring representation of all fields
      List<Question> selected = [];
      final random = Random();

      if (category == 'All') {
        // Group by category to ensure balanced representation
        final Map<String, List<Question>> grouped = {};
        for (var q in filtered) {
          grouped.putIfAbsent(q.category, () => []).add(q);
        }

        // Shuffle questions in each category group
        for (var key in grouped.keys) {
          grouped[key]!.shuffle(random);
        }

        final categoriesList = grouped.keys.toList();
        int index = 0;

        // Round robin pick from each category group until target amount is reached
        while (selected.length < amount && categoriesList.isNotEmpty) {
          final cat = categoriesList[index % categoriesList.length];
          if (grouped[cat]!.isNotEmpty) {
            selected.add(grouped[cat]!.removeLast());
            index++;
          } else {
            // Remove empty category from round robin pool
            categoriesList.removeAt(index % categoriesList.length);
          }
        }
      } else {
        // Just shuffle and take the requested amount
        filtered.shuffle(random);
        selected = filtered.take(amount).toList();
      }

      // Final shuffle of the selected items to mix categories
      selected.shuffle(random);

      _questions = selected;
      _status = QuizFetchStatus.loaded;
      notifyListeners();
      return _questions;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
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
}
