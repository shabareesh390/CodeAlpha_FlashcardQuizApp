import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/stats_repository.dart';

class StatsNotifier extends AsyncNotifier<UserStats> {
  late final StatsRepository _repository;
  String? _userId;

  @override
  Future<UserStats> build() async {
    _repository = ref.watch(statsRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    _userId = user?.uid ?? 'guest';

    _repository.syncRemoteToLocal().then((_) async {
      final updated = await _repository.getStats(_userId!);
      state = AsyncData(updated);
    });
    return _repository.getStats(_userId!);
  }

  Future<void> recordAnswer({required bool isCorrect}) async {
    if (_userId == null) return;
    
    final currentStats = state.value;
    if (currentStats == null) return;

    final now = DateTime.now();
    bool isNewDay = false;
    
    if (currentStats.lastReviewDate.year != now.year ||
        currentStats.lastReviewDate.month != now.month ||
        currentStats.lastReviewDate.day != now.day) {
      isNewDay = true;
    }

    int newStreak = currentStats.streakDays;
    if (isNewDay) {
      final difference = now.difference(currentStats.lastReviewDate).inDays;
      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      } else {
        if (currentStats.streakDays == 0) {
            newStreak = 1;
        }
      }
    } else {
        if (currentStats.streakDays == 0) {
            newStreak = 1;
        }
    }

    final newCardsReviewedToday = isNewDay ? 1 : currentStats.cardsReviewedToday + 1;
    final newTotalCorrect = currentStats.totalCorrect + (isCorrect ? 1 : 0);
    final newTotalAnswers = currentStats.totalAnswers + 1;

    final updatedStats = currentStats.copyWith(
      totalCorrect: newTotalCorrect,
      totalAnswers: newTotalAnswers,
      cardsReviewedToday: newCardsReviewedToday,
      streakDays: newStreak,
      lastReviewDate: now,
    );

    try {
      await _repository.updateStats(updatedStats);
      state = AsyncData(updatedStats);
    } catch (e) {
    }
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, UserStats>(() {
  return StatsNotifier();
});
