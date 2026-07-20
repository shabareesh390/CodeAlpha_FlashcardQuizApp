import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/flashcards/data/datasources/flashcard_local_data_source.dart';
import '../../features/flashcards/data/datasources/flashcard_remote_data_source.dart';
import '../../features/flashcards/data/repositories/flashcard_repository_impl.dart';
import '../../features/flashcards/domain/entities/flashcard.dart';
import '../../features/flashcards/domain/repositories/flashcard_repository.dart';
import '../../features/subjects/data/datasources/subject_local_data_source.dart';
import '../../features/subjects/data/datasources/subject_remote_data_source.dart';
import '../../features/subjects/data/repositories/subject_repository_impl.dart';
import '../../features/subjects/domain/entities/subject.dart';
import '../../features/subjects/domain/repositories/subject_repository.dart';
import '../../features/statistics/data/datasources/stats_local_data_source.dart';
import '../../features/statistics/data/datasources/stats_remote_data_source.dart';
import '../../features/statistics/data/repositories/stats_repository_impl.dart';
import '../../features/statistics/domain/entities/user_stats.dart';
import '../../features/statistics/domain/repositories/stats_repository.dart';

// Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Local Data Sources (Hive)
final subjectLocalDataSourceProvider = Provider<SubjectLocalDataSource>((ref) {
  final box = Hive.box<Subject>('subjects');
  return SubjectLocalDataSourceImpl(box);
});

final flashcardLocalDataSourceProvider = Provider<FlashcardLocalDataSource>((ref) {
  final box = Hive.box<Flashcard>('flashcards');
  return FlashcardLocalDataSourceImpl(box);
});

final statsLocalDataSourceProvider = Provider<StatsLocalDataSource>((ref) {
  final box = Hive.box<UserStats>('stats');
  return StatsLocalDataSourceImpl(box);
});

// Remote Data Sources (Firestore)
final subjectRemoteDataSourceProvider = Provider<SubjectRemoteDataSource>((ref) {
  return SubjectRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final flashcardRemoteDataSourceProvider = Provider<FlashcardRemoteDataSource>((ref) {
  return FlashcardRemoteDataSourceImpl(ref.watch(firestoreProvider));
});

final statsRemoteDataSourceProvider = Provider<StatsRemoteDataSource>((ref) {
  return StatsRemoteDataSourceImpl();
});

// Repositories
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepositoryImpl(
    ref.watch(subjectLocalDataSourceProvider),
    ref.watch(subjectRemoteDataSourceProvider),
    ref.watch(authRepositoryProvider),
  );
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepositoryImpl(
    ref.watch(flashcardLocalDataSourceProvider),
    ref.watch(flashcardRemoteDataSourceProvider),
    ref.watch(authRepositoryProvider),
  );
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepositoryImpl(
    ref.watch(statsLocalDataSourceProvider),
    ref.watch(statsRemoteDataSourceProvider),
    ref.watch(authRepositoryProvider),
  );
});
