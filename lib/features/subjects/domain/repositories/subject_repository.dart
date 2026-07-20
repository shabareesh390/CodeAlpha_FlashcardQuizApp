import '../entities/subject.dart';

abstract class SubjectRepository {
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);
  Future<List<Subject>> getAllSubjects();
  Future<void> syncRemoteToLocal();
  Future<void> syncAllLocalToRemote();
}
