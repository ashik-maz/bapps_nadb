import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_master/provider/quiz_provider.dart';
import 'package:quiz_master/router/app_router.dart';

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
  int? _selectedIndex; // Locked-in selected index after submission
  int? _tempSelectedIndex; // Temporarily selected index before submission
  bool _answered = false;
  final List<AnswerRecord> _records = [];

  // Gamification state
  int _streak = 0;
  int _maxStreak = 0;

  // Timer state
  Timer? _timer;
  int _timeLeft = 15; // 15 seconds per question
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
    if (_answered) return;

    // Time expired: record as skipped (null selectedIndex)
    setState(() {
      _tempSelectedIndex = null;
      _selectedIndex = null;
      _answered = true;
      _streak = 0; // Break streak
    });

    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: null,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: false,
        pointsEarned: 0,
      ),
    );
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _tempSelectedIndex = index;
    });
  }

  void _submitAnswer() {
    if (_answered || _tempSelectedIndex == null) return;
    _cancelTimer();

    final isCorrect = _tempSelectedIndex == _currentQuestion.correctIndex;
    int points = isCorrect ? _currentQuestion.difficulty.points : 0;

    // Streak tracker logic
    int newStreak = _streak;
    int bonus = 0;
    if (isCorrect) {
      newStreak++;
      if (newStreak > _maxStreak) {
        _maxStreak = newStreak;
      }
      // Every 3 correct in a row grants +5 pts streak bonus
      if (newStreak > 0 && newStreak % 3 == 0) {
        bonus = 5;
      }
    } else {
      newStreak = 0;
    }

    setState(() {
      _selectedIndex = _tempSelectedIndex;
      _answered = true;
      _streak = newStreak;
      _score += (points + bonus);
    });

    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: _selectedIndex,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: isCorrect,
        pointsEarned: points + bonus,
      ),
    );
  }

  void _skipQuestion() {
    if (_answered) return;
    _cancelTimer();

    // Skip logs a null selection record
    _records.add(
      AnswerRecord(
        questionId: _currentQuestion.id,
        selectedIndex: null,
        correctIndex: _currentQuestion.correctIndex,
        isCorrect: false,
        pointsEarned: 0,
      ),
    );

    _nextQuestion();
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _tempSelectedIndex = null;
        _answered = false;
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

    // Save history statistics in provider
    context.read<QuizProvider>().recordQuizResult(result);

    context.go(
      AppRouter.result,
      extra: {'result': result, 'questions': widget.questions},
    );
  }

  AnswerState _stateForOption(int index) {
    if (!_answered) {
      return _tempSelectedIndex == index ? AnswerState.selected : AnswerState.neutral;
    }
    if (index == _currentQuestion.correctIndex) {
      return _selectedIndex == index
          ? AnswerState.correct
          : AnswerState.revealed;
    }
    if (index == _selectedIndex) return AnswerState.wrong;
    return AnswerState.neutral;
  }

  static const List<String> _letters = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = _currentIndex == widget.questions.length - 1;
    final progress = (_currentIndex + 1) / widget.questions.length;

    // Timer circle color based on remaining time
    final timerColor = _timeLeft > 8
        ? (isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue)
        : _timeLeft > 3
            ? AppTheme.warningAmber
            : AppTheme.errorRed;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP HEADER APP BAR ---
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
                  const SizedBox(width: 48), // Balancing spacer
                ],
              ),
            ),

            // --- ANIMATED PROGRESS BAR ---
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
                    // --- STATUS ROW (Score, Streak, Timer) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Points
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

                        // Animated Circular Timer
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

                        // Streak
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

                    // --- QUESTION CARD ---
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
                          // Tag row
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

                          // Question Text
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

                          // Options
                          ...List.generate(
                            _currentQuestion.options.length,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnswerButton(
                                label: _currentQuestion.options[i],
                                optionLetter: _letters[i],
                                state: _stateForOption(i),
                                onTap: () => _selectAnswer(i),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- CONTROLS SECTION ---
                    if (!_answered) ...[
                      Row(
                        children: [
                          // Skip Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _skipQuestion,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.skip_next_rounded, size: 20),
                              label: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Submit Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _tempSelectedIndex == null ? null : _submitAnswer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                              label: const Text(
                                'Submit',
                                style: TextStyle(
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
                    ] else ...[
                      // --- IMMEDIATE FEEDBACK / EXPLANATION CARD ---
                      AnimatedOpacity(
                        opacity: _answered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _selectedIndex == _currentQuestion.correctIndex
                                ? const Color(0xFFE8F5E9)
                                : _selectedIndex == null
                                    ? const Color(0xFFFFF8E1)
                                    : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedIndex == _currentQuestion.correctIndex
                                  ? const Color(0xFF81C784).withOpacity(0.5)
                                  : _selectedIndex == null
                                      ? const Color(0xFFFFD54F).withOpacity(0.5)
                                      : const Color(0xFFE57373).withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _selectedIndex == _currentQuestion.correctIndex
                                        ? Icons.check_circle_rounded
                                        : _selectedIndex == null
                                            ? Icons.hourglass_empty_rounded
                                            : Icons.cancel_rounded,
                                    color: _selectedIndex == _currentQuestion.correctIndex
                                        ? AppTheme.successGreen
                                        : _selectedIndex == null
                                            ? AppTheme.warningAmber
                                            : AppTheme.errorRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _selectedIndex == _currentQuestion.correctIndex
                                        ? 'Correct Answer!'
                                        : _selectedIndex == null
                                            ? 'Time Expired!'
                                            : 'Wrong Answer!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      fontFamily: 'Nunito',
                                      color: _selectedIndex == _currentQuestion.correctIndex
                                          ? AppTheme.successGreen
                                          : _selectedIndex == null
                                              ? AppTheme.warningAmber
                                              : AppTheme.errorRed,
                                    ),
                                  ),
                                ],
                              ),
                              if (_currentQuestion.explanation != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  _currentQuestion.explanation!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Nunito',
                                    color: Color(0xFF1E293B),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // NEXT BUTTON
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'Complete & Score' : 'Next Question',
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
