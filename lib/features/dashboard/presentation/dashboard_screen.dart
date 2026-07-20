import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../subjects/presentation/providers/subjects_provider.dart';
import '../../flashcards/presentation/providers/flashcards_provider.dart';
import '../../statistics/presentation/providers/stats_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final subjectsState = ref.watch(subjectsProvider);
    final statsState = ref.watch(statsProvider);
    
    int totalCards = 0;
    if (subjectsState is AsyncData) {
      totalCards = subjectsState.value!.fold(0, (sum, sub) => sum + sub.cardCount);
    }                                                                           

    String accuracyText = 'N/A';
    String dailyGoalText = '0/30';
    String streakText = '0 Days';

    if (statsState is AsyncData && statsState.value != null) {
      final stats = statsState.value!;
      
      if (stats.totalAnswers > 0) {
        final accuracy = (stats.totalCorrect / stats.totalAnswers * 100).round();
        accuracyText = '$accuracy%';
      }

      dailyGoalText = '${stats.cardsReviewedToday}/${stats.dailyGoal}';
      streakText = '${stats.streakDays} Days';
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user?.displayName?.split(' ')[0] ?? 'Explorer'}!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Ready to master something new?",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.white) : null,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 32),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(context, 'Total Cards', totalCards.toString(), Icons.style, AppColors.primary),
              _buildStatCard(context, 'Accuracy', accuracyText, Icons.check_circle, AppColors.secondary),
              _buildStatCard(context, 'Daily Goal', dailyGoalText, Icons.track_changes, AppColors.warning),
              _buildStatCard(context, 'Streak', streakText, Icons.local_fire_department, AppColors.error),
            ],
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          
          if (subjectsState is AsyncData && subjectsState.value!.isNotEmpty) ...[
            Text(
              'Continue Learning',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            _buildContinueLearningCard(context, ref, subjectsState.value!.first),
          ] else if (subjectsState is AsyncData && subjectsState.value!.isEmpty) ...[
            Text(
              'Continue Learning',
              style: Theme.of(context).textTheme.titleLarge,
            ).animate().fadeIn(delay: 400.ms),
            
            const SizedBox(height: 16),
            
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.school_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('No subjects yet', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Create a subject in the Subjects tab to start learning.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ]
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContinueLearningCard(BuildContext context, WidgetRef ref, subject) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ref.read(selectedSubjectIdProvider.notifier).setSubjectId(subject.id);
          context.push('/viewer');
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(subject.colorCode).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.book, color: Color(subject.colorCode), size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.cardCount} flashcards',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.0,
                      backgroundColor: AppColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      borderRadius: BorderRadius.circular(8),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0);
  }
}
