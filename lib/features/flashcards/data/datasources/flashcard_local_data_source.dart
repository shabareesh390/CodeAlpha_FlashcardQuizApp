import 'package:hive/hive.dart';
import '../../domain/entities/flashcard.dart';

abstract class FlashcardLocalDataSource {
  Future<void> cacheFlashcards(List<Flashcard> flashcards);
  Future<void> addFlashcard(Flashcard flashcard);
  Future<void> updateFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String id);
  Future<List<Flashcard>> getFlashcardsBySubject(String subjectId);
  Future<List<Flashcard>> getAllFlashcards();
}

class FlashcardLocalDataSourceImpl implements FlashcardLocalDataSource {
  final Box<Flashcard> _box;

  FlashcardLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheFlashcards(List<Flashcard> flashcards) async {
    final Map<String, Flashcard> map = {
      for (var card in flashcards) card.id: card
    };
    await _box.putAll(map);
  }

  @override
  Future<void> addFlashcard(Flashcard flashcard) async {
    await _box.put(flashcard.id, flashcard);
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {
    await _box.put(flashcard.id, flashcard);
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Flashcard>> getFlashcardsBySubject(String subjectId) async {
    return _box.values.where((card) => card.subjectId == subjectId).toList();
  }

  @override
  Future<List<Flashcard>> getAllFlashcards() async {
    return _box.values.toList();
  }
}
