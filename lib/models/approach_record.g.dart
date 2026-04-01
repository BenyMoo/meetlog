// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'approach_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetApproachRecordCollection on Isar {
  IsarCollection<ApproachRecord> get approachRecords => this.collection();
}

const ApproachRecordSchema = CollectionSchema(
  name: r'ApproachRecord',
  id: 1902114767714774248,
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
    )
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
  {
    final value = object.failReason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.location.length * 3;
  {
    final value = object.reflection;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
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
    dateTime: reader.readDateTime(offsets[0]),
    failReason: reader.readStringOrNull(offsets[1]),
    id: id,
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _approachRecordGetId(ApproachRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _approachRecordGetLinks(ApproachRecord object) {
  return [];
}

void _approachRecordAttach(
    IsarCollection<dynamic> col, Id id, ApproachRecord object) {
  object.id = id;
}

extension ApproachRecordQueryWhereSort
    on QueryBuilder<ApproachRecord, ApproachRecord, QWhere> {
  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ApproachRecordQueryWhere
    on QueryBuilder<ApproachRecord, ApproachRecord, QWhereClause> {
  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ApproachRecordQueryFilter
    on QueryBuilder<ApproachRecord, ApproachRecord, QFilterCondition> {
  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'failReason',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'failReason',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'failReason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'failReason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'failReason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'failReason',
        value: '',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      failReasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'failReason',
        value: '',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      isSuccessEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSuccess',
        value: value,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'location',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'location',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'location',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      locationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'location',
        value: '',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reflection',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reflection',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reflection',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'reflection',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'reflection',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reflection',
        value: '',
      ));
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterFilterCondition>
      reflectionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'reflection',
        value: '',
      ));
    });
  }
}

extension ApproachRecordQueryObject
    on QueryBuilder<ApproachRecord, ApproachRecord, QFilterCondition> {}

extension ApproachRecordQueryLinks
    on QueryBuilder<ApproachRecord, ApproachRecord, QFilterCondition> {}

extension ApproachRecordQuerySortBy
    on QueryBuilder<ApproachRecord, ApproachRecord, QSortBy> {
  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByFailReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failReason', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByFailReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failReason', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> sortByIsSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccess', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByIsSuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccess', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> sortByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflection', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      sortByReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflection', Sort.desc);
    });
  }
}

extension ApproachRecordQuerySortThenBy
    on QueryBuilder<ApproachRecord, ApproachRecord, QSortThenBy> {
  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByFailReason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failReason', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByFailReasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'failReason', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> thenByIsSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccess', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByIsSuccessDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSuccess', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy> thenByLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'location', Sort.desc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByReflection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflection', Sort.asc);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QAfterSortBy>
      thenByReflectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reflection', Sort.desc);
    });
  }
}

extension ApproachRecordQueryWhereDistinct
    on QueryBuilder<ApproachRecord, ApproachRecord, QDistinct> {
  QueryBuilder<ApproachRecord, ApproachRecord, QDistinct> distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QDistinct> distinctByFailReason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'failReason', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QDistinct>
      distinctByIsSuccess() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSuccess');
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QDistinct> distinctByLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'location', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ApproachRecord, ApproachRecord, QDistinct> distinctByReflection(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reflection', caseSensitive: caseSensitive);
    });
  }
}

extension ApproachRecordQueryProperty
    on QueryBuilder<ApproachRecord, ApproachRecord, QQueryProperty> {
  QueryBuilder<ApproachRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ApproachRecord, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<ApproachRecord, String?, QQueryOperations> failReasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'failReason');
    });
  }

  QueryBuilder<ApproachRecord, bool, QQueryOperations> isSuccessProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSuccess');
    });
  }

  QueryBuilder<ApproachRecord, String, QQueryOperations> locationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'location');
    });
  }

  QueryBuilder<ApproachRecord, String?, QQueryOperations> reflectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reflection');
    });
  }
}
