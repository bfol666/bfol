import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? _client;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize(String url, String anonKey) async {
    if (url.isEmpty || anonKey.isEmpty) return;
    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _client = Supabase.instance.client;
      _initialized = true;
    } catch (_) {
      _initialized = false;
    }
  }

  SupabaseClient get client {
    if (!_initialized || _client == null) {
      throw StateError('Supabase is not initialized. Configure SUPABASE_URL and SUPABASE_ANON_KEY.');
    }
    return _client!;
  }

  // Auth
  Future<AuthResponse> signUp(String email, String password) async {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  // Entries
  Future<List<Map<String, dynamic>>> getEntries(String userId) async {
    final c = client;
    final response = await c
        .from('entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> data) async {
    final c = client;
    final response =
        await c.from('entries').insert(data).select().single();
    return response;
  }

  // Weekly Reports
  Future<Map<String, dynamic>?> getWeeklyReport(
      String userId, String weekStart) async {
    final c = client;
    final response = await c
        .from('weekly_reports')
        .select()
        .eq('user_id', userId)
        .eq('week_start', weekStart)
        .maybeSingle();
    return response;
  }

  // Storage
  Future<String> uploadMedia(String bucket, String path, List<int> bytes,
      {String? contentType}) async {
    await client.storage.from(bucket).uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: contentType),
        );
    return client.storage.from(bucket).getPublicUrl(path);
  }
}
