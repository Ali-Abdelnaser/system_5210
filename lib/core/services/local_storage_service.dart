import 'package:hive_flutter/hive_flutter.dart';

abstract class LocalStorageService {
  Future<void> init();
  Future<void> save(String boxName, String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String boxName, String key);
  Future<void> delete(String boxName, String key);
  Future<List<Map<String, dynamic>>> getAll(String boxName);
}

class HiveStorageService implements LocalStorageService {
  @override
  Future<void> init() async {
    await Hive.initFlutter();
  }

  Future<Box> _getBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  @override
  Future<void> save(
    String boxName,
    String key,
    Map<String, dynamic> data,
  ) async {
    final box = await _getBox(boxName);
    await box.put(key, data);
  }

  @override
  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await _getBox(boxName);
    final data = box.get(key);
    if (data != null) {
      return Map<String, dynamic>.from(data as Map);
    }
    return null;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String boxName) async {
    final box = await _getBox(boxName);
    return box.values.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
