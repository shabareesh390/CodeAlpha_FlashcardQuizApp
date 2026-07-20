import '../entities/flashcard.dart';

abstract class FlashcardRepository {
  Future<void> addFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String id);
  Future<List<Flashcard>> getFlashcardsBySubject(String subjectId);
  Future<void> syncRemoteToLocal();
  Future<void> syncAllLocalToRemote();
}
