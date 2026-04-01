import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/approach_record.dart';
import '../models/contact.dart';
import '../services/local_db_service.dart';

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService.instance;
});

final recordsProvider = StreamProvider<List<ApproachRecord>>((ref) {
  final dbService = ref.watch(localDbServiceProvider);

  final controller = StreamController<List<ApproachRecord>>();

  Future<void> fetchData() async {
    final records = await dbService.getAllRecords();
    if (!controller.isClosed) {
      controller.add(records);
    }
  }

  fetchData();

  final subscription = dbService.recordsWatch.listen((_) {
    fetchData();
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final dbService = ref.watch(localDbServiceProvider);

  final controller = StreamController<List<Contact>>();

  Future<void> fetchData() async {
    final contacts = await dbService.getAllContacts();
    if (!controller.isClosed) {
      controller.add(contacts);
    }
  }

  fetchData();

  final subscription = dbService.contactsWatch.listen((_) {
    fetchData();
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

final recordsByDateRangeProvider = Provider.family<List<ApproachRecord>, ({DateTime start, DateTime end})>((ref, range) {
  final recordsAsync = ref.watch(recordsProvider);

  return recordsAsync.whenOrNull(
    data: (records) => records.where((r) =>
      r.dateTime.isAfter(range.start) &&
      r.dateTime.isBefore(range.end)
    ).toList(),
  ) ?? [];
});

final contactsByRecordIdProvider = Provider.family<List<Contact>, int>((ref, recordId) {
  final contactsAsync = ref.watch(contactsProvider);

  return contactsAsync.whenOrNull(
    data: (contacts) => contacts.where((c) => c.recordId == recordId).toList(),
  ) ?? [];
});

final successRateProvider = Provider<double>((ref) {
  final recordsAsync = ref.watch(recordsProvider);

  return recordsAsync.whenOrNull(
    data: (records) {
      if (records.isEmpty) return 0.0;
      final successCount = records.where((r) => r.isSuccess).length;
      return successCount / records.length;
    },
  ) ?? 0.0;
});

final failReasonStatsProvider = Provider<Map<String, int>>((ref) {
  final recordsAsync = ref.watch(recordsProvider);

  return recordsAsync.whenOrNull(
    data: (records) {
      final stats = <String, int>{};
      for (final record in records) {
        if (!record.isSuccess && record.failReason != null) {
          stats[record.failReason!] = (stats[record.failReason!] ?? 0) + 1;
        }
      }
      return stats;
    },
  ) ?? {};
});
