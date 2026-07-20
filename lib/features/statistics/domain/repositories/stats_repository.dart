import '../entities/user_stats.dart';

abstract class StatsRepository {
  Future<void> updateStats(UserStats stats);
  Future<UserStats> getStats(String userId);
  Future<void> syncRemoteToLocal();
  Future<void> syncAllLocalToRemote();
}
