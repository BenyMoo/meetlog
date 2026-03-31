// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

part of 'contact.dart';

extension GetContactCollection on Isar {
  IsarCollection<Contact> get contacts => this.collection();
}

const ContactSchema = CollectionSchema<Contact>(
  name: r'Contact',
  id: 1879136485039702142,
  properties: {
    r'account': PropertySchema(
      id: 0,
      name: r'account',
      type: IsarType.string,
    ),
    r'followUpDate': PropertySchema(
      id: 1,
      name: r'followUpDate',
      type: IsarType.dateTime,
    ),
    r'impressionScore': PropertySchema(
      id: 2,
      name: r'impressionScore',
      type: IsarType.long,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'platform': PropertySchema(
      id: 4,
      name: r'platform',
      type: IsarType.string,
    ),
    r'recordId': PropertySchema(
      id: 5,
      name: r'recordId',
      type: IsarType.long,
    ),
  },
  estimateSize: _contactEstimateSize,
  serialize: _contactSerialize,
  deserialize: _contactDeserialize,
  deserializeProp: _contactDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _contactGetId,
  getLinks: _contactGetLinks,
  attach: _contactAttach,
  version: '3.1.0+1',
);

int _contactEstimateSize(
  Contact object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.account.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.platform.length * 3;
  return bytesCount;
}

void _contactSerialize(
  Contact object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.account);
  writer.writeDateTime(offsets[1], object.followUpDate);
  writer.writeLong(offsets[2], object.impressionScore);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.platform);
  writer.writeLong(offsets[5], object.recordId);
}

Contact _contactDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Contact(
    id: id,
    recordId: reader.readLong(offsets[5]),
    name: reader.readString(offsets[3]),
    platform: reader.readString(offsets[4]),
    account: reader.readString(offsets[0]),
    impressionScore: reader.readLong(offsets[2]),
    followUpDate: reader.readDateTimeOrNull(offsets[1]),
  );
  return object;
}

P _contactDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return reader.readString(offset) as P;
    case 1:
      return reader.readDateTimeOrNull(offset) as P;
    case 2:
      return reader.readLong(offset) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readString(offset) as P;
    case 5:
      return reader.readLong(offset) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _contactGetId(Contact object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _contactGetLinks(Contact object) {
  return [];
}

void _contactAttach(
  IsarCollection<dynamic> col,
  Id id,
  Contact object,
) {
  object.id = id;
}

Contact _$ContactFromJson(Map<String, dynamic> json) => Contact(
      id: json['id'] as int?,
      recordId: json['recordId'] as int,
      name: json['name'] as String,
      platform: json['platform'] as String,
      account: json['account'] as String,
      impressionScore: json['impressionScore'] as int,
      followUpDate: json['followUpDate'] == null
          ? null
          : DateTime.parse(json['followUpDate'] as String),
    );

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'id': instance.id,
      'recordId': instance.recordId,
      'name': instance.name,
      'platform': instance.platform,
      'account': instance.account,
      'impressionScore': instance.impressionScore,
      'followUpDate': instance.followUpDate?.toIso8601String(),
    };
