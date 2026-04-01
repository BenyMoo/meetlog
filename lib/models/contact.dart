import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  final int recordId;
  final String name;
  final String platform;
  final String account;
  final int impressionScore;
  final DateTime? followUpDate;

  Contact({
    this.id = Isar.autoIncrement,
    required this.recordId,
    required this.name,
    required this.platform,
    required this.account,
    required this.impressionScore,
    this.followUpDate,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] as int? ?? Isar.autoIncrement,
      recordId: json['recordId'] as int,
      name: json['name'] as String,
      platform: json['platform'] as String,
      account: json['account'] as String,
      impressionScore: json['impressionScore'] as int,
      followUpDate: json['followUpDate'] != null
          ? DateTime.parse(json['followUpDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordId': recordId,
      'name': name,
      'platform': platform,
      'account': account,
      'impressionScore': impressionScore,
      'followUpDate': followUpDate?.toIso8601String(),
    };
  }
}
