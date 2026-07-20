import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_stats.dart';

abstract class StatsRemoteDataSource {
  Future<void> syncStats(UserStats stats, String userId);
  Future<UserStats?> fetchStats(String userId);
}

class StatsRemoteDataSourceImpl implements StatsRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> syncStats(UserStats stats, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc(stats.id)
        .set(stats.toJson(), SetOptions(merge: true));
  }

  @override
  Future<UserStats?> fetchStats(String userId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc(userId) // Using userId as stats id
        .get();

    if (doc.exists && doc.data() != null) {
      return UserStats.fromJson(doc.data()!, doc.id);
    }
    return null;
  }
}
