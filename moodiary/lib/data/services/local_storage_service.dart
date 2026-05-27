import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/entry.dart';

class LocalStorageService {
  static const String _entriesBox = 'entries_cache';

  late Box<String> _entriesBoxInstance;

  Future<void> initialize() async {
    _entriesBoxInstance = await Hive.openBox<String>(_entriesBox);
  }

  // ── Entry CRUD ──

  Future<void> addEntry(Entry entry) async {
    await _entriesBoxInstance.put(entry.id, jsonEncode(entry.toJson()));
  }

  Future<void> deleteEntry(String id) async {
    await _entriesBoxInstance.delete(id);
  }

  /// Bulk cache (used for sync)
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

  // ── Simple local auth (MVP; replace with Supabase later) ──

  static const String _authBox = 'auth_cache';
  late Box<String> _authBoxInstance;

  Future<void> initAuthBox() async {
    _authBoxInstance = await Hive.openBox<String>(_authBox);
  }

  bool get isLoggedIn => _authBoxInstance.get('status') == 'authenticated';

  Future<void> setLoggedIn(bool value) async {
    await _authBoxInstance.put(
        'status', value ? 'authenticated' : 'unauthenticated');
  }

  String? get currentUserId {
    final id = _authBoxInstance.get('user_id');
    return id;
  }

  Future<void> setCurrentUserId(String id) async {
    await _authBoxInstance.put('user_id', id);
  }

}
