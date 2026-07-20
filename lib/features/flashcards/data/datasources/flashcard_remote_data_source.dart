import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/flashcard.dart';

abstract class FlashcardRemoteDataSource {
  Future<void> syncFlashcard(Flashcard flashcard, String userId);
  Future<void> deleteFlashcard(String flashcardId, String userId);
  Future<List<Flashcard>> fetchUserFlashcards(String userId);
}

class FlashcardRemoteDataSourceImpl implements FlashcardRemoteDataSource {
  final FirebaseFirestore _firestore;

  FlashcardRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> syncFlashcard(Flashcard flashcard, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcard.id)
        .set(flashcard.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteFlashcard(String flashcardId, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .doc(flashcardId)
        .delete();
  }

  @override
  Future<List<Flashcard>> fetchUserFlashcards(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .get();
        
    return snapshot.docs
        .map((doc) => Flashcard.fromJson(doc.data(), doc.id))
        .toList();
  }
}
