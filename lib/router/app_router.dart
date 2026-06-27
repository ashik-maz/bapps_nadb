import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/questions_data.dart';
import '../models/question.dart';
import '../models/quiz_result.dart';
import '../provider/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/result_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const quiz = '/quiz/:title';
  static const result = '/result';

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRouter.splash,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final status = authProvider.status;
        final location = state.uri.toString();

        // Still initializing — stay on splash
        if (status == AuthStatus.unknown) {
          return location == splash ? null : splash;
        }

        final isAuthenticated = status == AuthStatus.authenticated;
        final isOnAuthPage = location == login;

        // Authenticated users should not see auth pages (redirect to home)
        if (isAuthenticated && (isOnAuthPage || location == splash)) {
          return home;
        }

        // Unauthenticated users can only access auth pages (redirect to login)
        if (!isAuthenticated && !isOnAuthPage && location != splash) {
          return login;
        }

        return null; // no redirect needed
      },
      routes: [
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: login,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: CurveTween(curve: Curves.easeIn).animate(animation),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: home,
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: quiz,
          pageBuilder: (context, state) {
            final String title = state.pathParameters['title'] ?? 'Quiz';
            List<Question> questions = QuestionsData.flutterQuestions;

            // Support passing dynamic questions via state.extra
            if (state.extra is List<Question>) {
              questions = state.extra as List<Question>;
            } else if (state.extra is Map<String, dynamic>) {
              final extraMap = state.extra as Map<String, dynamic>;
              if (extraMap['questions'] is List<Question>) {
                questions = extraMap['questions'] as List<Question>;
              }
            }

            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: QuizScreen(
                questions: questions,
                title: title,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                );
              },
            );
          },
        ),
        GoRoute(
          path: result,
          pageBuilder: (context, state) {
            final Map<String, dynamic> extra =
                state.extra as Map<String, dynamic>;
            final QuizResult resultObj = extra['result'] as QuizResult;
            final List<Question> questions = extra['questions'] as List<Question>;

            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: ResultScreen(
                result: resultObj,
                questions: questions,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                );
              },
            );
          },
        ),
      ],
      errorBuilder: (context, state) =>
          Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
    );
  }
}
