import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/data_providers.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../../../subjects/presentation/providers/subjects_provider.dart';

class SelectedSubjectIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setSubjectId(String id) {
    state = id;
  }
}

final selectedSubjectIdProvider = NotifierProvider<SelectedSubjectIdNotifier, String?>(() {
  return SelectedSubjectIdNotifier();
});

class FlashcardsNotifier extends AsyncNotifier<List<Flashcard>> {
  late final FlashcardRepository _repository;

  @override
  Future<List<Flashcard>> build() async {
    _repository = ref.watch(flashcardRepositoryProvider);
    final subjectId = ref.watch(selectedSubjectIdProvider);
    
    if (subjectId == null) {
      return [];
    }

    _repository.syncRemoteToLocal().then((_) async {
      final updated = await _repository.getFlashcardsBySubject(subjectId);
      state = AsyncData(updated);
    });
    return _repository.getFlashcardsBySubject(subjectId);
  }

  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      await _repository.addFlashcard(flashcard);
      final subjectId = ref.read(selectedSubjectIdProvider);
      if (subjectId != null) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _repository.getFlashcardsBySubject(subjectId));
        
        final subjectRepo = ref.read(subjectRepositoryProvider);
        final subjects = await subjectRepo.getAllSubjects();
        final subjectIndex = subjects.indexWhere((s) => s.id == subjectId);
        if (subjectIndex != -1) {
          final subject = subjects[subjectIndex];
          final updatedSubject = subject.copyWith(cardCount: subject.cardCount + 1);
          ref.read(subjectsProvider.notifier).updateSubject(updatedSubject);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await _repository.updateFlashcard(flashcard);
      final subjectId = ref.read(selectedSubjectIdProvider);
      if (subjectId != null) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _repository.getFlashcardsBySubject(subjectId));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFlashcard(String id) async {
    try {
      await _repository.deleteFlashcard(id);
      final subjectId = ref.read(selectedSubjectIdProvider);
      if (subjectId != null) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _repository.getFlashcardsBySubject(subjectId));
        
        final subjectRepo = ref.read(subjectRepositoryProvider);
        final subjects = await subjectRepo.getAllSubjects();
        final subjectIndex = subjects.indexWhere((s) => s.id == subjectId);
        if (subjectIndex != -1) {
          final subject = subjects[subjectIndex];
          final newCount = subject.cardCount > 0 ? subject.cardCount - 1 : 0;
          final updatedSubject = subject.copyWith(cardCount: newCount);
          ref.read(subjectsProvider.notifier).updateSubject(updatedSubject);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

final flashcardsProvider = AsyncNotifierProvider<FlashcardsNotifier, List<Flashcard>>(() {
  return FlashcardsNotifier();
});
