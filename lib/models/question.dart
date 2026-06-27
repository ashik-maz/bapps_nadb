class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String category;
  final Difficulty difficulty;
  final String? explanation;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.category,
    this.difficulty = Difficulty.medium,
    this.explanation,
  });

  String get correctAnswer => options[correctIndex];
}

enum Difficulty { easy, medium, hard }

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  int get points {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 10;
      case Difficulty.hard:
        return 20;
    }
  }
}
