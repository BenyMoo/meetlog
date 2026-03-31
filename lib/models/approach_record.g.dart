// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

part of 'approach_record.dart';

extension GetApproachRecordCollection on Isar {
  IsarCollection<ApproachRecord> get approachRecords => this.collection();
}

const ApproachRecordSchema = CollectionSchema<ApproachRecord>(
  name: r'ApproachRecord',
  id: 4123859221408395521,
  properties: {
    r'dateTime': PropertySchema(
      id: 0,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'failReason': PropertySchema(
      id: 1,
      name: r'failReason',
      type: IsarType.string,
    ),
    r'isSuccess': PropertySchema(
      id: 2,
      name: r'isSuccess',
      type: IsarType.bool,
    ),
    r'location': PropertySchema(
      id: 3,
      name: r'location',
      type: IsarType.string,
    ),
    r'reflection': PropertySchema(
      id: 4,
      name: r'reflection',
      type: IsarType.string,
    ),
  },
  estimateSize: _approachRecordEstimateSize,
  serialize: _approachRecordSerialize,
  deserialize: _approachRecordDeserialize,
  deserializeProp: _approachRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _approachRecordGetId,
  getLinks: _approachRecordGetLinks,
  attach: _approachRecordAttach,
  version: '3.1.0+1',
);

int _approachRecordEstimateSize(
  ApproachRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  final failReason = object.failReason;
  if (failReason != null) {
    bytesCount += 3 + failReason.length * 3;
  }
  bytesCount += 3 + object.location.length * 3;
  final reflection = object.reflection;
  if (reflection != null) {
    bytesCount += 3 + reflection.length * 3;
  }
  return bytesCount;
}

void _approachRecordSerialize(
  ApproachRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.dateTime);
  writer.writeString(offsets[1], object.failReason);
  writer.writeBool(offsets[2], object.isSuccess);
  writer.writeString(offsets[3], object.location);
  writer.writeString(offsets[4], object.reflection);
}

ApproachRecord _approachRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ApproachRecord(
    id: id,
    dateTime: reader.readDateTime(offsets[0]),
    failReason: reader.readStringOrNull(offsets[1]),
    isSuccess: reader.readBool(offsets[2]),
    location: reader.readString(offsets[3]),
    reflection: reader.readStringOrNull(offsets[4]),
  );
  return object;
}

P _approachRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return reader.readDateTime(offset) as P;
    case 1:
      return reader.readStringOrNull(offset) as P;
    case 2:
      return reader.readBool(offset) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readStringOrNull(offset) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _approachRecordGetId(ApproachRecord object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _approachRecordGetLinks(ApproachRecord object) {
  return [];
}

void _approachRecordAttach(
  IsarCollection<dynamic> col,
  Id id,
  ApproachRecord object,
) {
  object.id = id;
}

ApproachRecord _$ApproachRecordFromJson(Map<String, dynamic> json) =>
    ApproachRecord(
      id: json['id'] as int?,
      dateTime: DateTime.parse(json['dateTime'] as String),
      location: json['location'] as String,
      isSuccess: json['isSuccess'] as bool,
      failReason: json['failReason'] as String?,
      reflection: json['reflection'] as String?,
    );

Map<String, dynamic> _$ApproachRecordToJson(ApproachRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dateTime': instance.dateTime.toIso8601String(),
      'location': instance.location,
      'isSuccess': instance.isSuccess,
      'failReason': instance.failReason,
      'reflection': instance.reflection,
    };
