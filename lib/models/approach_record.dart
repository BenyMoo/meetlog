import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'approach_record.g.dart';

@collection
@JsonSerializable()
class ApproachRecord {
  @Id()
  int? id;

  final DateTime dateTime;
  final String location;
  final bool isSuccess;
  final String? failReason;
  final String? reflection;

  ApproachRecord({
    this.id,
    required this.dateTime,
    required this.location,
    required this.isSuccess,
    this.failReason,
    this.reflection,
  });

  factory ApproachRecord.fromJson(Map<String, dynamic> json) =>
      _$ApproachRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ApproachRecordToJson(this);
}
