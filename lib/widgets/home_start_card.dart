import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/questions_data.dart';
import '../theme/app_theme.dart';

class HomeStartCard extends StatelessWidget {
  final double screenWidth;
  const HomeStartCard({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A90E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background decoration circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(70),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(50),
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flutter Quiz',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${QuestionsData.flutterQuestions.length} questions  •  Mixed difficulty',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withAlpha(175),
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: screenWidth * 0.45,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => QuizScreen(
                    //       questions: QuestionsData.flutterQuestions,
                    //       title: 'Flutter Quiz',
                    //     ),
                    //   ),
                    // );
                    context.push('/quiz/Flutter Quiz', extra: QuestionsData.flutterQuestions);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(0, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Quiz'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
