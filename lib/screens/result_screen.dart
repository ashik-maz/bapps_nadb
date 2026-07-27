import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../models/question.dart';
import '../models/quiz_result.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_celebration.dart';
import '../widgets/review_card.dart';

class ResultScreen extends StatefulWidget {
  final QuizResult result;
  final List<Question> questions;

  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;
  late final Animation<int> _countAnim;
  bool _showReview = false;

  void _shareResult() {
    final r = widget.result;
    final text = '🎯 Quiz Master Result\n'
        '${r.gradeMessage} I scored ${r.totalScore}/${r.maxScore} '
        '(${r.percentage.toStringAsFixed(0)}%) — Grade ${r.grade}.\n'
        '✅ ${r.correctAnswers}/${r.totalQuestions} correct answers.';
    // Fix standard share_plus syntax from template bug
    Share.share(text);
  }

  Color _gradeColor(String grade) {
    switch (grade) {
      case 'S':
        return const Color(0xFF6366F1); // Indigo
      case 'A':
        return AppTheme.successGreen;
      case 'B':
        return const Color(0xFF0EA5E9); // Sky blue
      case 'C':
        return AppTheme.warningAmber;
      case 'D':
        return const Color(0xFFF97316); // Orange
      default:
        return AppTheme.errorRed;
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _progressAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _countAnim = IntTween(
      begin: 0,
      end: widget.result.totalScore,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showConfetti = r.grade == 'S' || r.grade == 'A' || r.grade == 'B';

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Custom App Bar
                _customResultAppBar(context, isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Score Summary Card
                        _heroCard(r, isDark),
                        const SizedBox(height: 20),
                        // Stats row
                        _buildStatsRow(r, isDark),
                        const SizedBox(height: 24),
                        // Action buttons
                        _buildActionButtons(context, isDark),
                        const SizedBox(height: 28),
                        // Review section
                        _buildReviewSection(isDark),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating canvas confetti Celebration
            if (showConfetti)
              const IgnorePointer(
                child: ConfettiCelebration(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _customResultAppBar(BuildContext context, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF0F172A) : AppTheme.primaryBlue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go(AppRouter.home),
            icon: const Icon(Icons.home_rounded, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Quiz Result',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          IconButton(
            onPressed: _shareResult,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(QuizResult r, bool isDark) {
    final primaryColor = _gradeColor(r.grade);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151F32) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EDF8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryColor.withOpacity(0.4)),
            ),
            child: Text(
              r.gradeMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Glowing sweep Score Ring
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return SizedBox(
                width: 150,
                height: 150,
                child: CustomPaint(
                  painter: _ScoreRingPainter(
                    progress: _progressAnim.value * (r.percentage / 100),
                    color: primaryColor,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_countAnim.value}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
                            fontFamily: 'Nunito',
                          ),
                        ),
                        Text(
                          'Score Pts',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF64748B) : AppTheme.neutralGrey,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Grade text
          Text(
            'Grade ${r.grade}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: primaryColor,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${r.percentage.toStringAsFixed(0)}% accuracy in this quiz',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF64748B) : AppTheme.neutralGrey,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(QuizResult r, bool isDark) {
    final correctCount = r.answers.where((a) => a.isCorrect).length;
    final skippedCount = r.answers.where((a) => a.selectedIndex == null).length;
    final wrongCount = r.answers.where((a) => a.selectedIndex != null && !a.isCorrect).length;

    return Row(
      children: [
        _StatChip(
          label: 'Correct',
          value: '$correctCount',
          icon: Icons.check_circle_rounded,
          color: AppTheme.successGreen,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Wrong',
          value: '$wrongCount',
          icon: Icons.cancel_rounded,
          color: AppTheme.errorRed,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Skipped',
          value: '$skippedCount',
          icon: Icons.help_outline_rounded,
          color: AppTheme.warningAmber,
        ),
        const SizedBox(width: 8),
        _StatChip(
          label: 'Ratio',
          value: '${r.totalScore}/${r.maxScore}',
          icon: Icons.stars_rounded,
          color: const Color(0xFF6366F1),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => setState(() => _showReview = !_showReview),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: Icon(
            _showReview ? Icons.keyboard_arrow_up_rounded : Icons.expand_more_rounded,
            size: 20,
          ),
          label: Text(
            _showReview ? 'Hide Reviews' : 'Review Answers',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRouter.home),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(
              color: isDark ? const Color(0xFF6366F1) : AppTheme.primaryBlue,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.home_rounded, size: 20),
          label: const Text(
            'Back to Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(bool isDark) {
    if (!_showReview) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Answer Review',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0D1B2A),
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.result.answers.length, (i) {
          final record = widget.result.answers[i];
          final question = widget.questions.firstWhere(
            (q) => q.id == record.questionId,
            orElse: () => Question(id: record.questionId, text: 'Question not found', options: ['N/A', 'N/A', 'N/A', 'N/A'], correctIndex: 0, category: 'Unknown'),
          );
          return ReviewCard(index: i, question: question, record: record);
        }),
      ],
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _ScoreRingPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    // Track color depending on theme
    final trackColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EDF8);

    // Background track
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.color != color || old.isDark != isDark;
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : color,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF64748B) : AppTheme.neutralGrey,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
