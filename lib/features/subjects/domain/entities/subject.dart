import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

@HiveType(typeId: 0)
class Subject extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String iconCode;
  
  @HiveField(3)
  final int colorCode;
  
  @HiveField(4)
  final int cardCount;
  
  @HiveField(5)
  final bool isCustom;

  const Subject({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorCode,
    this.cardCount = 0,
    this.isCustom = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json, String id) {
    return Subject(
      id: id,
      name: json['name'] as String,
      iconCode: json['iconCode'] as String,
      colorCode: json['colorCode'] as int,
      cardCount: json['cardCount'] as int? ?? 0,
      isCustom: json['isCustom'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'iconCode': iconCode,
      'colorCode': colorCode,
      'cardCount': cardCount,
      'isCustom': isCustom,
    };
  }

  Subject copyWith({
    String? name,
    String? iconCode,
    int? colorCode,
    int? cardCount,
    bool? isCustom,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorCode: colorCode ?? this.colorCode,
      cardCount: cardCount ?? this.cardCount,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  List<Object?> get props => [id, name, iconCode, colorCode, cardCount, isCustom];
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCode: fields[2] as String,
      colorCode: fields[3] as int,
      cardCount: fields[4] as int? ?? 0,
      isCustom: fields[5] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorCode)
      ..writeByte(4)
      ..write(obj.cardCount)
      ..writeByte(5)
      ..write(obj.isCustom);
  }
}
