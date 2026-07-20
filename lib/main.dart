import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/router/app_router.dart';
import 'features/subjects/domain/entities/subject.dart';
import 'features/flashcards/domain/entities/flashcard.dart';
import 'features/statistics/domain/entities/user_stats.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(SubjectAdapter());
  Hive.registerAdapter(FlashcardAdapter());
  Hive.registerAdapter(UserStatsAdapter());
  
  // Open boxes
  await Hive.openBox<Subject>('subjects');
  await Hive.openBox<Flashcard>('flashcards');
  await Hive.openBox<UserStats>('stats');
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign In
  await GoogleSignIn.instance.initialize();

  runApp(
    const ProviderScope(
      child: FlashMindApp(),
    ),
  );
}

class FlashMindApp extends ConsumerWidget {
  const FlashMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'FlashMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
