import '../../domain/entities/user_stats.dart';
import '../../domain/repositories/stats_repository.dart';
import '../datasources/stats_local_data_source.dart';
import '../datasources/stats_remote_data_source.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class StatsRepositoryImpl implements StatsRepository {
  final StatsLocalDataSource _localDataSource;
  final StatsRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  StatsRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._authRepository,
  );

  @override
  Future<void> updateStats(UserStats stats) async {
    await _localDataSource.saveStats(stats);
    
    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.syncStats(stats, user.uid).catchError((_) {});
    }
  }

  @override
  Future<UserStats> getStats(String userId) async {
    var stats = await _localDataSource.getStats(userId);
    if (stats == null) {
      stats = UserStats(id: userId, lastReviewDate: DateTime.now().subtract(const Duration(days: 1)));
      await _localDataSource.saveStats(stats);
    }
    return stats;
  }

  @override
  Future<void> syncRemoteToLocal() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final remoteStats = await _remoteDataSource.fetchStats(user.uid);
        if (remoteStats != null) {
          await _localDataSource.saveStats(remoteStats);
        }
      } catch (e) {
        // Handle error quietly in background
      }
    }
  }

  @override
  Future<void> syncAllLocalToRemote() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      final localStats = await _localDataSource.getStats(user.uid);
      if (localStats != null) {
        await _remoteDataSource.syncStats(localStats, user.uid);
      }
    }
  }
}
