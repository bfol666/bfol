import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/ai_service.dart';
import '../../core/constants/app_constants.dart';
import 'auth_provider.dart';
import 'entry_provider.dart';
import 'ai_provider.dart';

// ── Service providers ──

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(apiKey: AppConstants.openaiApiKey);
});

// ── Feature providers ──

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(localStorage, supabaseService);
});

final entryProvider = StateNotifierProvider<EntryNotifier, EntryState>((ref) {
  final localStorage = ref.watch(localStorageServiceProvider);
  return EntryNotifier(localStorage);
});

final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AINotifier(aiService);
});
