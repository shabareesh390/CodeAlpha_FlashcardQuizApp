import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_local_data_source.dart';
import '../datasources/flashcard_remote_data_source.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class FlashcardRepositoryImpl implements FlashcardRepository {
  final FlashcardLocalDataSource _localDataSource;
  final FlashcardRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  FlashcardRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._authRepository,
  );

  @override
  Future<void> addFlashcard(Flashcard flashcard) async {
    await _localDataSource.addFlashcard(flashcard);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.syncFlashcard(flashcard, user.uid).catchError((_) {
      });
    }
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {
    await _localDataSource.updateFlashcard(flashcard);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.syncFlashcard(flashcard, user.uid).catchError((_) {});
    }
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    await _localDataSource.deleteFlashcard(id);

    final user = _authRepository.currentUser;
    if (user != null) {
      _remoteDataSource.deleteFlashcard(id, user.uid).catchError((_) {});
    }
  }

  @override
  Future<List<Flashcard>> getFlashcardsBySubject(String subjectId) async {
    return _localDataSource.getFlashcardsBySubject(subjectId);
  }

  @override
  Future<void> syncRemoteToLocal() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final remoteCards = await _remoteDataSource.fetchUserFlashcards(user.uid);
        await _localDataSource.cacheFlashcards(remoteCards);
      } catch (e) {
      }
    }
  }

  @override
  Future<void> syncAllLocalToRemote() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      try {
        final localFlashcards = await _localDataSource.getAllFlashcards();
        for (var flashcard in localFlashcards) {
          await _remoteDataSource.syncFlashcard(flashcard, user.uid);
        }
      } catch (e) {
      }
    }
  }
}
