import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../subjects/presentation/providers/subjects_provider.dart';
import '../../statistics/presentation/providers/stats_provider.dart';
import '../../../core/providers/data_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final user = ref.watch(currentUserProvider);
    final isDark = themeMode == ThemeMode.dark || 
        (themeMode == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                  child: user?.photoURL == null ? const Icon(Icons.person, size: 48, color: Colors.white) : null,
                ).animate().scale(duration: 400.ms),
                const SizedBox(height: 16),
                Text(
                  user?.displayName ?? 'Explorer',
                  style: Theme.of(context).textTheme.headlineMedium,
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'Not signed in',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme(value);
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined),
                  title: const Text('Backup & Sync'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Syncing data...')),
                    );
                    
                    try {
                      final subjectRepo = ref.read(subjectRepositoryProvider);
                      final flashcardRepo = ref.read(flashcardRepositoryProvider);
                      final statsRepo = ref.read(statsRepositoryProvider);
                      
                      await subjectRepo.syncAllLocalToRemote();
                      await flashcardRepo.syncAllLocalToRemote();
                      await statsRepo.syncAllLocalToRemote();
                      
                      await subjectRepo.syncRemoteToLocal();
                      await statsRepo.syncRemoteToLocal();
                      
                      ref.invalidate(subjectsProvider);
                      ref.invalidate(statsProvider);
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sync completed successfully!'), backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Sync failed: $e'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.error),
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      context.go('/auth');
                    }
                  },
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
