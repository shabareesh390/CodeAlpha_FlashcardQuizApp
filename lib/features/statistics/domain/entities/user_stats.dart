import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

@HiveType(typeId: 2)
class UserStats extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int totalCorrect;

  @HiveField(2)
  final int totalAnswers;

  @HiveField(3)
  final int dailyGoal;

  @HiveField(4)
  final int cardsReviewedToday;

  @HiveField(5)
  final int streakDays;

  @HiveField(6)
  final DateTime lastReviewDate;

  const UserStats({
    required this.id,
    this.totalCorrect = 0,
    this.totalAnswers = 0,
    this.dailyGoal = 30,
    this.cardsReviewedToday = 0,
    this.streakDays = 0,
    required this.lastReviewDate,
  });

  factory UserStats.fromJson(Map<String, dynamic> json, String id) {
    return UserStats(
      id: id,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalAnswers: json['totalAnswers'] as int? ?? 0,
      dailyGoal: json['dailyGoal'] as int? ?? 30,
      cardsReviewedToday: json['cardsReviewedToday'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastReviewDate: json['lastReviewDate'] != null 
          ? DateTime.parse(json['lastReviewDate'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCorrect': totalCorrect,
      'totalAnswers': totalAnswers,
      'dailyGoal': dailyGoal,
      'cardsReviewedToday': cardsReviewedToday,
      'streakDays': streakDays,
      'lastReviewDate': lastReviewDate.toIso8601String(),
    };
  }

  UserStats copyWith({
    int? totalCorrect,
    int? totalAnswers,
    int? dailyGoal,
    int? cardsReviewedToday,
    int? streakDays,
    DateTime? lastReviewDate,
  }) {
    return UserStats(
      id: id,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      cardsReviewedToday: cardsReviewedToday ?? this.cardsReviewedToday,
      streakDays: streakDays ?? this.streakDays,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        totalCorrect,
        totalAnswers,
        dailyGoal,
        cardsReviewedToday,
        streakDays,
        lastReviewDate,
      ];
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = 2;

  @override
  UserStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStats(
      id: fields[0] as String,
      totalCorrect: fields[1] as int? ?? 0,
      totalAnswers: fields[2] as int? ?? 0,
      dailyGoal: fields[3] as int? ?? 30,
      cardsReviewedToday: fields[4] as int? ?? 0,
      streakDays: fields[5] as int? ?? 0,
      lastReviewDate: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalCorrect)
      ..writeByte(2)
      ..write(obj.totalAnswers)
      ..writeByte(3)
      ..write(obj.dailyGoal)
      ..writeByte(4)
      ..write(obj.cardsReviewedToday)
      ..writeByte(5)
      ..write(obj.streakDays)
      ..writeByte(6)
      ..write(obj.lastReviewDate);
  }
}
