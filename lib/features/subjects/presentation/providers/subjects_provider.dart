import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';

class SubjectsNotifier extends AsyncNotifier<List<Subject>> {
  late final SubjectRepository _repository;

  @override
  Future<List<Subject>> build() async {
    _repository = ref.watch(subjectRepositoryProvider);
    // Ensure sync happens in background and updates UI when done
    _repository.syncRemoteToLocal().then((_) async {
      final updated = await _repository.getAllSubjects();
      state = AsyncData(updated);
    });
    return _repository.getAllSubjects();
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _repository.addSubject(subject);
      // Reload subjects to update the state
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _repository.getAllSubjects());
    } catch (e) {
      // Error handling can be managed by the UI via listener or snackbar
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _repository.updateSubject(subject);
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _repository.getAllSubjects());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() => _repository.getAllSubjects());
    } catch (e) {
      rethrow;
    }
  }
}

final subjectsProvider = AsyncNotifierProvider<SubjectsNotifier, List<Subject>>(() {
  return SubjectsNotifier();
});
