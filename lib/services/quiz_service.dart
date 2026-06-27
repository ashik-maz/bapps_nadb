import 'package:dio/dio.dart';

import '../data/models/questions_response_model.dart';

// https://
// opentdb.com/
// api.php
// ?amount=10

class QuizService {
  static const _baseUrl = 'https://opentdb.com';

  final Dio _dio;

  QuizService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

  Future<QuestionsResponseModel> fetchQuestions({int amount = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api.php',
        queryParameters: {'amount': amount},
      );
      final data = response.data;

      if (data == null) {
        throw QuizServiceException('Empty response from server.');
      }

      final QuestionsResponseModel model = QuestionsResponseModel.fromJson(
        data,
      );

      // OpenTDB uses response_code 0 for success.
      // Code 1 = no results, 2 = invalid param, 3 = token not found, 4 = token empty.
      if (model.responseCode != 0) {
        throw QuizServiceException(_mapResponseCode(model.responseCode));
      }

      return model;
    } on DioException catch (e) {
      throw QuizServiceException(_mapDioError(e));
    }
  }
}

class QuizServiceException implements Exception {
  final String message;
  const QuizServiceException(this.message);

  @override
  String toString() => message;
}

String _mapResponseCode(int? code) {
  switch (code) {
    case 1:
      return 'Not enough questions available. Try fewer questions.';
    case 2:
      return 'Invalid request parameters.';
    case 3:
    case 4:
      return 'Session token issue. Please restart the app.';
    default:
      return 'Unexpected API response (code $code).';
  }
}

String _mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Request timed out. Check your connection.';
    case DioExceptionType.connectionError:
      return 'No internet connection.';
    default:
      return 'Network error: ${e.message}';
  }
}
