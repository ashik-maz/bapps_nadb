class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final int totalScore;
  final int maxScore;
  final List<AnswerRecord> answers;

  const QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalScore,
    required this.maxScore,
    required this.answers,
  });

  double get percentage =>
      totalQuestions == 0 ? 0 : correctAnswers / totalQuestions * 100;

  String get grade {
    if (percentage >= 90) return 'S';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  String get gradeMessage {
    if (percentage >= 90) return 'Outstanding!';
    if (percentage >= 80) return 'Excellent!';
    if (percentage >= 70) return 'Great job!';
    if (percentage >= 60) return 'Good effort!';
    if (percentage >= 50) return 'Keep practicing!';
    return 'Try again!';
  }
}

class AnswerRecord {
  final String questionId;
  final int? selectedIndex;
  final int correctIndex;
  final bool isCorrect;
  final int pointsEarned;

  const AnswerRecord({
    required this.questionId,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isCorrect,
    required this.pointsEarned,
  });
}
