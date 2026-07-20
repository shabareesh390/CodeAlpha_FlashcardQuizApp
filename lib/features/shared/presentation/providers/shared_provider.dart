import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../subjects/domain/entities/subject.dart';
import '../../../flashcards/domain/entities/flashcard.dart';
import '../../data/shared_remote_data_source.dart';

class SharedDeckState {
  final Subject? subject;
  final List<Flashcard> flashcards;
  final bool isLoading;
  final String? error;

  SharedDeckState({
    this.subject,
    this.flashcards = const [],
    this.isLoading = false,
    this.error,
  });

  SharedDeckState copyWith({
    Subject? subject,
    List<Flashcard>? flashcards,
    bool? isLoading,
    String? error,
  }) {
    return SharedDeckState(
      subject: subject ?? this.subject,
      flashcards: flashcards ?? this.flashcards,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final sharedDeckProvider = FutureProvider.autoDispose.family<SharedDeckState, ({String userId, String subjectId})>((ref, arg) async {
  final dataSource = SharedRemoteDataSource();
  try {
    final subject = await dataSource.fetchSubject(arg.userId, arg.subjectId);
    if (subject == null) {
      return SharedDeckState(error: 'Subject not found.');
    }
    final flashcards = await dataSource.fetchFlashcards(arg.userId, arg.subjectId);
    return SharedDeckState(subject: subject, flashcards: flashcards);
  } catch (e) {
    return SharedDeckState(error: e.toString());
  }
});
