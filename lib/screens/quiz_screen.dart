import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/auth_provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/router/app_router.dart';
import 'package:quiz_master/services/firestore_service.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../theme/app_theme.dart';
import '../widgets/answer_buttons.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const QuizScreen({super.key, required this.questions, required this.title});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _tempSelectedIndex;
  final List<AnswerRecord> _records = [];

  int _streak = 0;
  int _maxStreak = 0;

  Timer? _timer;
  int _timeLeft = 15;
  static const int _maxTime = 15;

  Question get _currentQuestion => widget.questions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  void _startTimer() {
    _cancelTimer();
    setState(() {
      _timeLeft = _maxTime;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _onTimeExpired();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onTimeExpired() {
    _cancelTimer();
    if (_records.length > _currentIndex) return;

    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: null,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: false,
        pointsEarned: 0,
      ),
    );
    _streak = 0;

    _nextQuestion();
  }

  void _selectAnswer(int index) {
    setState(() {
      _tempSelectedIndex = index;
    });
  }

  void _proceedWithAnswer() {
    _cancelTimer();

    final isCorrect = _tempSelectedIndex == _currentQuestion.correctIndex;
    int points = isCorrect ? _currentQuestion.difficulty.points : 0;

    int newStreak = _streak;
    int bonus = 0;
    if (_tempSelectedIndex != null) {
      if (isCorrect) {
        newStreak++;
        if (newStreak > _maxStreak) {
          _maxStreak = newStreak;
        }
        if (newStreak > 0 && newStreak % 3 == 0) {
          bonus = 5;
        }
      } else {
        newStreak = 0;
      }
    } else {
      newStreak = 0;
    }

    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: _tempSelectedIndex,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: isCorrect,
        pointsEarned: points + bonus,
      ),
    );

    _score += (points + bonus);
    _streak = newStreak;

    _nextQuestion();
  }

  void _showEndExamDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Exam Early', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to end the exam now? All remaining questions will be marked as skipped, and you will be scored based on your current answers.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endExamEarly();
            },
            child: const Text('End & Score', style: TextStyle(fontFamily: 'Nunito')),
          ),
        ],
      ),
    );
  }

  void _endExamEarly() {
    _cancelTimer();
    while (_records.length < widget.questions.length) {
      final nextQ = widget.questions[_records.length];
      _records.add(
        AnswerRecord(
          questionId: nextQ.id,
          selectedIndex: null,
          correctIndex: nextQ.correctIndex,
          isCorrect: false,
          pointsEarned: 0,
        ),
      );
    }
    _finishQuiz();
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _tempSelectedIndex = null;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _cancelTimer();
    final maxScore = widget.questions.fold<int>(
      0,
      (sum, q) => sum + q.difficulty.points,
    );

    final result = QuizResult(
      totalQuestions: widget.questions.length,
      correctAnswers: _records.where((r) => r.isCorrect).length,
      totalScore: _score,
      maxScore: maxScore,
      answers: _records,
    );

    final auth = context.read<AuthProvider>();
    final quizProvider = context.read<QuizProvider>();
    final uid = quizProvider.subscriberMobile ?? auth.userMobile ?? auth.userEmail ?? auth.user?.uid ?? 'guest';
    final userName = auth.userName ?? 'Prostuti Examinee';
    final userEmail = auth.userEmail ?? uid;

    // Save exam result to Firestore so History & Leaderboard work immediately
    FirestoreService().saveExamResult(uid, userName, userEmail, result);
    quizProvider.recordQuizResult(result);

    context.go(
      AppRouter.result,
      extra: {'result': result, 'questions': widget.questions},
    );
  }

  AnswerState _stateForOption(int index) {
    return _tempSelectedIndex == index ? AnswerState.selected : AnswerState.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentIndex == widget.questions.length - 1;
    final progress = (_currentIndex + 1) / widget.questions.length;

    final timerColor = _timeLeft > 8
        ? (isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue)
        : _timeLeft > 3
            ? AppTheme.warningAmber
            : AppTheme.errorRed;

    String nextLabel;
    IconData nextIcon;
    if (_tempSelectedIndex == null) {
      nextLabel = isLast ? 'Skip & Finish' : 'Skip / Next';
      nextIcon = isLast ? Icons.emoji_events_rounded : Icons.skip_next_rounded;
    } else {
      nextLabel = isLast ? 'Finish Exam' : 'Next';
      nextIcon = isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: isDark ? const Color(0xFF0F172A) : AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Quit Exam', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                          content: const Text('Are you sure you want to quit the exam? Your progress will be lost.', style: TextStyle(fontFamily: 'Nunito')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito')),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.go(AppRouter.home);
                              },
                              child: const Text('Quit', style: TextStyle(fontFamily: 'Nunito')),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showEndExamDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    ),
                    icon: const Icon(Icons.flag_rounded, size: 18),
                    label: const Text(
                      'End',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? const Color(0xFF06B6D4) : AppTheme.accentCyan),
              minHeight: 6,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                '$_score pts',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: CircularProgressIndicator(
                                value: _timeLeft / _maxTime,
                                strokeWidth: 4,
                                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                              ),
                            ),
                            Text(
                              '$_timeLeft',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: timerColor,
                                  fontFamily: 'Nunito'),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _streak > 0
                                ? const Color(0xFFFFECEB)
                                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(12),
                            border: _streak > 0
                                ? Border.all(color: const Color(0xFFEF5350).withOpacity(0.3))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: _streak > 0 ? const Color(0xFFEF5350) : Colors.grey,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Streak: $_streak',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Nunito',
                                  color: _streak > 0 ? const Color(0xFFEF5350) : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF151F32) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EDF8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _currentQuestion.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                              Text(
                                '+${_currentQuestion.difficulty.points} pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF818CF8) : AppTheme.primaryBlue,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            'Q${_currentIndex + 1}. ${_currentQuestion.text}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                              fontFamily: 'Nunito',
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

                          ...List.generate(
                            _currentQuestion.options.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnswerButton(
                                label: _currentQuestion.options[i],
                                optionLetter: String.fromCharCode(65 + i),
                                state: _stateForOption(i),
                                onTap: () => _selectAnswer(i),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showEndExamDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorRed,
                              side: const BorderSide(
                                color: AppTheme.errorRed,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.stop_circle_rounded, size: 20),
                            label: const Text(
                              'End Exam',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _proceedWithAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                            ),
                            icon: Icon(nextIcon, size: 20),
                            label: Text(
                              nextLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
