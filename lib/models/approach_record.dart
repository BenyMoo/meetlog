import 'package:isar/isar.dart';

part 'approach_record.g.dart';

@collection
class ApproachRecord {
  Id id = Isar.autoIncrement;

  final DateTime dateTime;
  final String location;
  final bool isSuccess;
  final String? failReason;
  final String? reflection;
  int sortOrder;

  ApproachRecord({
    this.id = Isar.autoIncrement,
    required this.dateTime,
    required this.location,
    required this.isSuccess,
    this.failReason,
    this.reflection,
    this.sortOrder = 0,
  });

  factory ApproachRecord.fromJson(Map<String, dynamic> json) {
    return ApproachRecord(
      id: json['id'] as int? ?? Isar.autoIncrement,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      isSuccess: json['isSuccess'] as bool,
      failReason: json['failReason'] as String?,
      reflection: json['reflection'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'location': location,
      'isSuccess': isSuccess,
      'failReason': failReason,
      'reflection': reflection,
      'sortOrder': sortOrder,
    };
  }
}
