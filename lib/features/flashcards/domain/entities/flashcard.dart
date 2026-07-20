import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

@HiveType(typeId: 1)
class Flashcard extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String subjectId;

  @HiveField(2)
  final String question;

  @HiveField(3)
  final String answer;

  @HiveField(4)
  final bool isLearned;

  @HiveField(5)
  final bool isFavorite;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? lastReviewedAt;

  const Flashcard({
    required this.id,
    required this.subjectId,
    required this.question,
    required this.answer,
    this.isLearned = false,
    this.isFavorite = false,
    required this.createdAt,
    this.lastReviewedAt,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json, String id) {
    return Flashcard(
      id: id,
      subjectId: json['subjectId'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      isLearned: json['isLearned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastReviewedAt: json['lastReviewedAt'] != null 
          ? DateTime.parse(json['lastReviewedAt'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'question': question,
      'answer': answer,
      'isLearned': isLearned,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
    };
  }

  Flashcard copyWith({
    String? subjectId,
    String? question,
    String? answer,
    bool? isLearned,
    bool? isFavorite,
    DateTime? lastReviewedAt,
  }) {
    return Flashcard(
      id: id,
      subjectId: subjectId ?? this.subjectId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      isLearned: isLearned ?? this.isLearned,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        subjectId,
        question,
        answer,
        isLearned,
        isFavorite,
        createdAt,
        lastReviewedAt,
      ];
}

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 1;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      question: fields[2] as String,
      answer: fields[3] as String,
      isLearned: fields[4] as bool? ?? false,
      isFavorite: fields[5] as bool? ?? false,
      createdAt: fields[6] as DateTime,
      lastReviewedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.answer)
      ..writeByte(4)
      ..write(obj.isLearned)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.lastReviewedAt);
  }
}
