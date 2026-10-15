import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/DataSource/MoneySource.dart';
import 'package:self_made_app/DataSource/travel_MoneySource.dart';

const String kBackupAppName = 'self_made_app';
const int kBackupVersion = 1;

class RestoreResult {
  final int moneyCount;
  final int travelCount;

  const RestoreResult({
    required this.moneyCount,
    required this.travelCount,
  });
}

class BackupService {
  static Map<String, dynamic> buildBackupMap() {
    final moneyBoxMap = boxMoneyData.toMap().map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );

    final travelBoxMap = TravelboxMoneyData.toMap().map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );

    return {
      'appName': 'self_made_app',
      'backupVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'moneyBox': moneyBoxMap,
      'travelBox': travelBoxMap,
    };
  }

  static Future<File> exportBackupFile() async {
    final backupMap = buildBackupMap();
    final jsonString = jsonEncode(backupMap);
    final compressedBytes = gzip.encode(utf8.encode(jsonString));

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'self_made_app_backup_${DateTime.now().millisecondsSinceEpoch}.json.gz';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonString, flush: true);
    return file;
  }

  static Future<void> shareBackupFile() async {
    final file = await exportBackupFile();
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'self_made_app backup file',
      subject: 'self_made_app backup',
    );
  }

  
  static Future<RestoreResult?> importBackupFromPicker() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'gz'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    final file = File(result.files.single.path!);
    return restoreFromFile(file);
  }

  static Future<RestoreResult> restoreFromFile(File file) async {
    final bytes = await file.readAsBytes();

    final backupMap = await compute(_decodeBackupBytes, bytes);

    _validateBackupMap(backupMap);

    return restoreFromBackupMap(backupMap);
  }

  static void _validateBackupMap(Map<String, dynamic> backupMap) {
    final appName = backupMap['appName'];
    final backupVersion = backupMap['backupVersion'];

    if (appName != kBackupAppName) {
      throw Exception('唔係本 app 嘅備份檔');
    }

    if (backupVersion != kBackupVersion) {
      throw Exception('backup version 不支援');
    }

    if (!backupMap.containsKey('moneyBox') || !backupMap.containsKey('travelBox')) {
      throw Exception('備份檔格式唔完整');
    }
  }

  static Future<RestoreResult> restoreFromBackupMap(
    Map<String, dynamic> backupMap,
  ) async {
    final moneyRaw = Map<String, dynamic>.from(backupMap['moneyBox'] ?? {});
    final travelRaw = Map<String, dynamic>.from(backupMap['travelBox'] ?? {});

    // 避免 restore 中途資料衝突：先 close / clear / restore
    await boxMoneyData.clear();
    await TravelboxMoneyData.clear();

    for (final entry in moneyRaw.entries) {
      await boxMoneyData.put(
        int.parse(entry.key),
        MoneyData.fromJson(Map<String, dynamic>.from(entry.value)),
      );
    }

    for (final entry in travelRaw.entries) {
      await TravelboxMoneyData.put(
        int.parse(entry.key),
        TravelMoneyData.fromJson(Map<String, dynamic>.from(entry.value)),
      );
    }

    await boxMoneyData.flush();
    await TravelboxMoneyData.flush();

    MoneySource.instance.modifyRecord();

    return RestoreResult(
      moneyCount: moneyRaw.length,
      travelCount: travelRaw.length,
    );
  }
}

Map<String, dynamic> _decodeBackupBytes(List<int> bytes) {
  List<int> decodedBytes;

  final isGzip = bytes.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b;

  if (isGzip) {
    decodedBytes = gzip.decode(bytes);
  } else {
    decodedBytes = bytes;
  }

  final jsonString = utf8.decode(decodedBytes);
  return Map<String, dynamic>.from(jsonDecode(jsonString));
}
