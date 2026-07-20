import '../../domain/entities/subject.dart';
import '../../domain/repositories/subject_repository.dart';
import '../datasources/subject_local_data_source.dart';
import '../datasources/subject_remote_data_source.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class SubjectRepositoryImpl implements SubjectRepository {
  final SubjectLocalDataSource _localDataSource;
  final SubjectRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  SubjectRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._authRepository,
  );

  @override
  Future<void> addSubject(Subject subject) async {
    await _localDataSource.addSubject(subject);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.syncSubject(subject, user.uid).catchError((_) {});
    }
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    await _localDataSource.updateSubject(subject);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.syncSubject(subject, user.uid).catchError((_) {});
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    await _localDataSource.deleteSubject(id);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.deleteSubject(id, user.uid).catchError((_) {});
    }
  }

  @override
  Future<List<Subject>> getAllSubjects() async {
    return _localDataSource.getAllSubjects();
  }

  @override
  Future<void> syncRemoteToLocal() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final remoteSubjects = await _remoteDataSource.fetchUserSubjects(user.uid);
        await _localDataSource.cacheSubjects(remoteSubjects);
      } catch (e) {
      }
    }
  }

  @override
  Future<void> syncAllLocalToRemote() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final localSubjects = await _localDataSource.getAllSubjects();
        for (var subject in localSubjects) {
          await _remoteDataSource.syncSubject(subject, user.uid);
        }
      } catch (e) {
      }
    }
  }
}
