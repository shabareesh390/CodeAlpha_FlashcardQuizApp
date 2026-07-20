import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/subject.dart';

abstract class SubjectRemoteDataSource {
  Future<void> syncSubject(Subject subject, String userId);
  Future<void> deleteSubject(String subjectId, String userId);
  Future<List<Subject>> fetchUserSubjects(String userId);
}

class SubjectRemoteDataSourceImpl implements SubjectRemoteDataSource {
  final FirebaseFirestore _firestore;

  SubjectRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> syncSubject(Subject subject, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subject.id)
        .set(subject.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteSubject(String subjectId, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .doc(subjectId)
        .delete();
  }

  @override
  Future<List<Subject>> fetchUserSubjects(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('subjects')
        .get();
        
    return snapshot.docs
        .map((doc) => Subject.fromJson(doc.data(), doc.id))
        .toList();
  }
}
