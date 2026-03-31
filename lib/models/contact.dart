import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact.g.dart';

@collection
@JsonSerializable()
class Contact {
  @Id()
  int? id;

  final int recordId;
  final String name;
  final String platform;
  final String account;
  final int impressionScore;
  final DateTime? followUpDate;

  Contact({
    this.id,
    required this.recordId,
    required this.name,
    required this.platform,
    required this.account,
    required this.impressionScore,
    this.followUpDate,
  });

  factory Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

  Map<String, dynamic> toJson() => _$ContactToJson(this);
}
