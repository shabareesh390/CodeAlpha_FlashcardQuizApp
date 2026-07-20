import 'package:hive/hive.dart';
import '../../domain/entities/subject.dart';

abstract class SubjectLocalDataSource {
  Future<void> cacheSubjects(List<Subject> subjects);
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);
  Future<List<Subject>> getAllSubjects();
}

class SubjectLocalDataSourceImpl implements SubjectLocalDataSource {
  final Box<Subject> _box;

  SubjectLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheSubjects(List<Subject> subjects) async {
    final Map<String, Subject> map = {
      for (var sub in subjects) sub.id: sub
    };
    await _box.putAll(map);
  }

  @override
  Future<void> addSubject(Subject subject) async {
    await _box.put(subject.id, subject);
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _box.put(subject.id, subject);
  }

  @override
  Future<void> deleteSubject(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    return _box.values.toList();
  }
}
