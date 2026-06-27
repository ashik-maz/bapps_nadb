// {
//    "response_code": 0,
//    "results": [
//        {
//            "type": "multiple",
//               "difficulty": "easy",
//               "category": "Entertainment: Video Games",
//               "question": "In the video game, Half-life, what event started the Half-life universe as we know today?",
//               "correct_answer": "The Resonance Cascade",
//               "incorrect_answers": [
//                      "World War 3",
//                      "The Xen Attack",
//                      "The Black Mesa Nuke"
//               ]
//          }
//      ]
// }

class QuestionsResponseModel {
  final int? responseCode;
  final List<Result>? results;

  QuestionsResponseModel({this.responseCode, this.results});

  factory QuestionsResponseModel.fromJson(Map<String, dynamic> json) =>
      QuestionsResponseModel(
        responseCode: json["response_code"],
        results: json["results"] == null
            ? []
            : List<Result>.from(
                json["results"]!.map((x) => Result.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "response_code": responseCode,
    "results": results == null
        ? []
        : List<dynamic>.from(results!.map((x) => x.toJson())),
  };
}

class Result {
  final String? type;
  final String? difficulty;
  final String? category;
  final String? question;
  final String? correctAnswer;
  final List<String>? incorrectAnswers;

  Result({
    this.type,
    this.difficulty,
    this.category,
    this.question,
    this.correctAnswer,
    this.incorrectAnswers,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    type: json["type"]!,
    difficulty: json["difficulty"]!,
    category: json["category"],
    question: json["question"],
    correctAnswer: json["correct_answer"],
    incorrectAnswers: json["incorrect_answers"] == null
        ? []
        : List<String>.from(json["incorrect_answers"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "difficulty": difficulty,
    "category": category,
    "question": question,
    "correct_answer": correctAnswer,
    "incorrect_answers": incorrectAnswers == null
        ? []
        : List<dynamic>.from(incorrectAnswers!.map((x) => x)),
  };
}
