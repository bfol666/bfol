import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  late final SupabaseClient _client;

  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Auth
  Future<AuthResponse> signUp(String email, String password) async {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  // Entries
  Future<List<Map<String, dynamic>>> getEntries(String userId) async {
    final response = await _client
        .from('entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createEntry(Map<String, dynamic> data) async {
    final response =
        await _client.from('entries').insert(data).select().single();
    return response;
  }

  // Weekly Reports
  Future<Map<String, dynamic>?> getWeeklyReport(
      String userId, String weekStart) async {
    final response = await _client
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
    await _client.storage.from(bucket).uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: contentType),
        );
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
