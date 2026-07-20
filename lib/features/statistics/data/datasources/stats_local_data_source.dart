import 'package:hive/hive.dart';
import '../../domain/entities/user_stats.dart';

abstract class StatsLocalDataSource {
  Future<void> saveStats(UserStats stats);
  Future<UserStats?> getStats(String id);
}

class StatsLocalDataSourceImpl implements StatsLocalDataSource {
  final Box<UserStats> _box;

  StatsLocalDataSourceImpl(this._box);

  @override
  Future<void> saveStats(UserStats stats) async {
    await _box.put(stats.id, stats);
  }

  @override
  Future<UserStats?> getStats(String id) async {
    return _box.get(id);
  }
}
