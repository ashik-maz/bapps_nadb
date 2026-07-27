import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../services/firestore_service.dart';

enum QuizFetchStatus { idle, loading, loaded, error }

class QuizProvider with ChangeNotifier {
  QuizFetchStatus _status = QuizFetchStatus.idle;
  List<Question> _questions = [];
  String? _errorMessage;

  // BDapps Subscription State
  bool _isSubscribed = false; // Default unsubscribed demo access
  String? _subscriberMobile;

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
  bool get isSubscribed => _isSubscribed;
  String? get subscriberMobile => _subscriberMobile;

  int get quizzesTaken => _quizzesTaken;
  int get highScore => _highScore;
  double get averageAccuracy {
    if (_totalQuestionsAnswered == 0) return 0.0;
    return (_totalCorrectAnswers / _totalQuestionsAnswered) * 100;
  }

  void setSubscriptionState(bool subscribed, {String? mobile}) {
    _isSubscribed = subscribed;
    _subscriberMobile = mobile;
    notifyListeners();
  }

  /// Fetches questions from dedicated Firestore collections:
  /// IT -> questions_cse_it
  /// General Knowledge -> questions_gk
  /// Bangla -> questions_bangla
  /// English -> questions_english
  /// Mixed -> 60% IT, 20% Bangla, 20% English
  /// Filters out previously seen questions so subscribers never see duplicate questions!
  Future<List<Question>?> fetchQuestions({
    int amount = 25,
    String category = 'Mixed',
    Difficulty? difficulty,
    String? userIdentifier,
  }) async {
    if (_status == QuizFetchStatus.loading) return null;

    _status = QuizFetchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final db = FirebaseFirestore.instance;
      final firestoreService = FirestoreService();
      final String identifier = userIdentifier ?? _subscriberMobile ?? '';
      
      // Retrieve seen question IDs for this subscriber
      final Set<String> seenIds = await firestoreService.getSeenQuestionIds(identifier);

      List<Question> selected = [];
      final random = Random();

      if (category == 'Mixed') {
        int cseCount = (amount * 0.60).round();
        int banglaCount = (amount * 0.20).round();
        int englishCount = amount - cseCount - banglaCount;

        final cseSnap = await db.collection('questions_cse_it').get();
        final banglaSnap = await db.collection('questions_bangla').get();
        final englishSnap = await db.collection('questions_english').get();

        var cseList = _parseDocs(cseSnap.docs).where((q) => !seenIds.contains(q.id)).toList();
        var banglaList = _parseDocs(banglaSnap.docs).where((q) => !seenIds.contains(q.id)).toList();
        var englishList = _parseDocs(englishSnap.docs).where((q) => !seenIds.contains(q.id)).toList();

        // Fallbacks if user has seen all questions in a collection
        if (cseList.isEmpty) cseList = _parseDocs(cseSnap.docs);
        if (banglaList.isEmpty) banglaList = _parseDocs(banglaSnap.docs);
        if (englishList.isEmpty) englishList = _parseDocs(englishSnap.docs);

        cseList.shuffle(random);
        banglaList.shuffle(random);
        englishList.shuffle(random);

        selected.addAll(cseList.take(cseCount));
        selected.addAll(banglaList.take(banglaCount));
        selected.addAll(englishList.take(englishCount));
      } else {
        String collectionName = 'questions_bangla';
        if (category == 'IT' || category == 'CSE/IT') collectionName = 'questions_cse_it';
        if (category == 'General Knowledge' || category == 'GK') collectionName = 'questions_gk';
        if (category == 'Bangla') collectionName = 'questions_bangla';
        if (category == 'English') collectionName = 'questions_english';

        var snapshot = await db.collection(collectionName).get();
        
        // Fallback for General Knowledge if empty in initial setup
        if (snapshot.docs.isEmpty && collectionName == 'questions_gk') {
          snapshot = await db.collection('questions_bangla_gk').get();
        }

        final List<Question> allQuestions = _parseDocs(snapshot.docs);
        
        // Filter out previously seen questions for this subscriber
        var unseenQuestions = allQuestions.where((q) => !seenIds.contains(q.id)).toList();

        if (difficulty != null) {
          unseenQuestions = unseenQuestions.where((q) => q.difficulty == difficulty).toList();
        }

        // If user has seen all questions in this category, reset pool to all questions
        if (unseenQuestions.isEmpty) {
          unseenQuestions = allQuestions;
          if (difficulty != null) {
            unseenQuestions = unseenQuestions.where((q) => q.difficulty == difficulty).toList();
          }
        }

        if (unseenQuestions.isEmpty) {
          throw Exception('No questions found in collection $collectionName');
        }

        unseenQuestions.shuffle(random);
        selected = unseenQuestions.take(amount).toList();
      }

      selected.shuffle(random);
      _questions = selected;

      // Mark the selected questions as seen for this subscriber so they never repeat
      final selectedIds = selected.map((q) => q.id).toList();
      await firestoreService.markQuestionsAsSeen(identifier, selectedIds);

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

  List<Question> _parseDocs(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return docs.map((doc) {
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
