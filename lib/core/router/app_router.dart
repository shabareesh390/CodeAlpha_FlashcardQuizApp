import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../core/widgets/main_screen.dart';
import '../../features/flashcards/presentation/flashcard_viewer_screen.dart';
import '../../features/shared/presentation/shared_viewer_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/viewer',
        builder: (context, state) => const FlashcardViewerScreen(),
      ),
      GoRoute(
        path: '/shared/:userId/:subjectId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          final subjectId = state.pathParameters['subjectId']!;
          return SharedViewerScreen(userId: userId, subjectId: subjectId);
        },
      ),
    ],
  );
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
