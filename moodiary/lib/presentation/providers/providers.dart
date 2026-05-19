import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/supabase_service.dart';
import '../../data/services/ai_service.dart';
import '../../core/constants/app_constants.dart';
import 'auth_provider.dart';
import 'entry_provider.dart';
import 'ai_provider.dart';

// Service providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final service = SupabaseService();
  // Initialization happens in main.dart
  return service;
});

final aiServiceProvider = Provider<AIService>((ref) {
  return AIService(apiKey: AppConstants.openaiApiKey);
});

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});

// Entry provider
final entryProvider = StateNotifierProvider<EntryNotifier, EntryState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return EntryNotifier(supabaseService);
});

// AI provider
final aiProvider = StateNotifierProvider<AINotifier, AIState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AINotifier(aiService);
});
