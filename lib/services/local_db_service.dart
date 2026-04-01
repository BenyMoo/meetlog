import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/approach_record.dart';
import '../models/contact.dart';

class LocalDbService {
  static final LocalDbService instance = LocalDbService._internal();
  LocalDbService._internal();

  late Isar isar;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [ApproachRecordSchema, ContactSchema],
      directory: dir.path,
      inspector: true,
    );

    _isInitialized = true;
  }

  Future<int> addRecord(ApproachRecord record, {Contact? contact}) async {
    return await isar.writeTxn(() async {
      final recordId = await isar.approachRecords.put(record);

      if (contact != null) {
        final newContact = Contact(
          id: contact.id,
          recordId: recordId,
          name: contact.name,
          platform: contact.platform,
          account: contact.account,
          impressionScore: contact.impressionScore,
          impression: contact.impression,
          hobby: contact.hobby,
          createdAt: contact.createdAt,
        );
        await isar.contacts.put(newContact);
      }

      return recordId;
    });
  }

  Future<List<ApproachRecord>> getAllRecords() async {
    final records = await isar.approachRecords.where().findAll();
    final hasCustomOrder = records.any((r) => r.sortOrder > 0);
    if (hasCustomOrder) {
      records.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } else {
      records.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    }
    return records;
  }

  Future<List<Contact>> getAllContacts() async {
    final contacts = await isar.contacts.where().findAll();
    final hasCustomOrder = contacts.any((c) => c.sortOrder > 0);
    if (hasCustomOrder) {
      contacts.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } else {
      contacts.sort((a, b) => b.id.compareTo(a.id));
    }
    return contacts;
  }

  Future<ApproachRecord?> getRecordById(int id) async {
    return await isar.approachRecords.get(id);
  }

  Future<void> updateRecordOrder(int id, int order) async {
    await isar.writeTxn(() async {
      final record = await isar.approachRecords.get(id);
      if (record != null) {
        final updatedRecord = ApproachRecord(
          id: record.id,
          dateTime: record.dateTime,
          location: record.location,
          isSuccess: record.isSuccess,
          failReason: record.failReason,
          reflection: record.reflection,
          sortOrder: order,
        );
        await isar.approachRecords.put(updatedRecord);
      }
    });
  }

  Future<void> updateContactOrder(int id, int order) async {
    await isar.writeTxn(() async {
      final contact = await isar.contacts.get(id);
      if (contact != null) {
        final updatedContact = Contact(
          id: contact.id,
          recordId: contact.recordId,
          name: contact.name,
          platform: contact.platform,
          account: contact.account,
          impressionScore: contact.impressionScore,
          impression: contact.impression,
          hobby: contact.hobby,
          followUpDate: contact.followUpDate,
          createdAt: contact.createdAt,
          sortOrder: order,
        );
        await isar.contacts.put(updatedContact);
      }
    });
  }

  Future<void> deleteContact(int id) async {
    await isar.writeTxn(() async {
      await isar.contacts.delete(id);
    });
  }

  Future<List<Contact>> getContactsByRecordId(int recordId) async {
    final contacts = await isar.contacts.where().findAll();
    return contacts.where((c) => c.recordId == recordId).toList();
  }

  Future<void> deleteRecord(int id) async {
    await isar.writeTxn(() async {
      final contacts = await isar.contacts.where().findAll();
      for (final contact in contacts) {
        if (contact.recordId == id) {
          await isar.contacts.delete(contact.id);
        }
      }
      await isar.approachRecords.delete(id);
    });
  }

  Future<void> insertTestData() async {
    final now = DateTime.now();

    final testRecords = [
      ApproachRecord(
        dateTime: now.subtract(const Duration(days: 1)),
        location: '星巴克',
        isSuccess: true,
      ),
      ApproachRecord(
        dateTime: now.subtract(const Duration(days: 2)),
        location: '地铁2号线',
        isSuccess: false,
        failReason: '太紧张',
        reflection: '下次要更自信一些，提前准备好开场白。',
      ),
      ApproachRecord(
        dateTime: now.subtract(const Duration(days: 3)),
        location: '商场',
        isSuccess: true,
      ),
    ];

    final testContacts = [
      Contact(
        recordId: 0,
        name: 'Lina',
        platform: '微信',
        account: 'lina_wx',
        impressionScore: 4,
        followUpDate: now.add(const Duration(days: 1)),
      ),
      Contact(
        recordId: 0,
        name: '穿白裙的女孩',
        platform: '小红书',
        account: 'white_dress_123',
        impressionScore: 5,
        followUpDate: now.add(const Duration(days: 2)),
      ),
    ];

    await isar.writeTxn(() async {
      for (int i = 0; i < testRecords.length; i++) {
        final recordId = await isar.approachRecords.put(testRecords[i]);
        if (i < testContacts.length) {
          testContacts[i] = Contact(
            recordId: recordId,
            name: testContacts[i].name,
            platform: testContacts[i].platform,
            account: testContacts[i].account,
            impressionScore: testContacts[i].impressionScore,
            followUpDate: testContacts[i].followUpDate,
          );
          await isar.contacts.put(testContacts[i]);
        }
      }
    });
  }

  Future<String?> exportData() async {
    final records = await getAllRecords();
    final contacts = await getAllContacts();

    final data = {
      'records': records.map((r) => r.toJson()).toList(),
      'contacts': contacts.map((c) => c.toJson()).toList(),
      'exportTime': DateTime.now().toIso8601String(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    String? outputPath;
    try {
      outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '导出备份数据',
        fileName: 'meetlog_backup.json',
        bytes: Uint8List.fromList(utf8.encode(jsonString)),
      );
    } catch (e) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/meetlog_backup.json');
      await file.writeAsString(jsonString);
      outputPath = file.path;
    }

    return outputPath;
  }

  Future<bool> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: '选择备份文件',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await isar.writeTxn(() async {
        await isar.clear();

        final recordsJson = data['records'] as List<dynamic>?;
        if (recordsJson != null) {
          for (final recordJson in recordsJson) {
            final record = ApproachRecord.fromJson(recordJson as Map<String, dynamic>);
            await isar.approachRecords.put(record);
          }
        }

        final contactsJson = data['contacts'] as List<dynamic>?;
        if (contactsJson != null) {
          for (final contactJson in contactsJson) {
            final contact = Contact.fromJson(contactJson as Map<String, dynamic>);
            await isar.contacts.put(contact);
          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.clear();
    });
  }

  Stream<void> get recordsWatch => isar.approachRecords.watchLazy();
  Stream<void> get contactsWatch => isar.contacts.watchLazy();
}
