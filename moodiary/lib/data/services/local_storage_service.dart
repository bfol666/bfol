import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class LocalStorageService {
  static const String _entriesBox = 'entries_cache';
  static const String _draftBox = 'drafts';

  late Box<String> _entriesBoxInstance;
  late Box<String> _draftsBoxInstance;

  Future<void> initialize() async {
    await Hive.initFlutter();
    _entriesBoxInstance = await Hive.openBox<String>(_entriesBox);
    _draftsBoxInstance = await Hive.openBox<String>(_draftBox);
  }

  // Cached entries for offline access
  Future<void> cacheEntries(List<Entry> entries) async {
    await _entriesBoxInstance.clear();
    for (final entry in entries) {
      await _entriesBoxInstance.put(entry.id, jsonEncode(entry.toJson()));
    }
  }

  List<Entry> getCachedEntries() {
    return _entriesBoxInstance.values.map((json) {
      return Entry.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }).toList();
  }

  // Draft saving
  Future<void> saveDraft(String key, Map<String, dynamic> data) async {
    await _draftsBoxInstance.put(key, jsonEncode(data));
  }

  Map<String, dynamic>? getDraft(String key) {
    final json = _draftsBoxInstance.get(key);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> deleteDraft(String key) async {
    await _draftsBoxInstance.delete(key);
  }

  Future<void> clearAllDrafts() async {
    await _draftsBoxInstance.clear();
  }
}
