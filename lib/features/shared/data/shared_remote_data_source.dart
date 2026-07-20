import 'package:cloud_firestore/cloud_firestore.dart';
import '../../subjects/domain/entities/subject.dart';
import '../../flashcards/domain/entities/flashcard.dart';

class SharedRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Subject?> fetchSubject(String userId, String subjectId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subjectId)
        .get();

    if (doc.exists && doc.data() != null) {
      return Subject.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<Flashcard>> fetchFlashcards(String userId, String subjectId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('flashcards')
        .where('subjectId', isEqualTo: subjectId)
        .get();

    return snapshot.docs
        .map((doc) => Flashcard.fromJson(doc.data(), doc.id))
        .toList();
  }
}
