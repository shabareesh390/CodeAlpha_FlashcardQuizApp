import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        context.go('/dashboard');
      } else {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/FlashMind.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.easeOutBack)
            .fadeIn(duration: 800.ms),
            const SizedBox(height: 24),
            Text(
              'FlashMind',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                letterSpacing: -1,
              ),
            )
            .animate(delay: 400.ms)
            .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 600.ms),
            const SizedBox(height: 8),
            Text(
              'Master anything, effortlessly.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            )
            .animate(delay: 600.ms)
            .slideY(begin: 0.5, end: 0, duration: 600.ms, curve: Curves.easeOutCubic)
            .fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
