import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/supabase_service.dart';
import 'presentation/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Chinese locale
  await initializeDateFormatting('zh_CN');

  // Initialize Hive for local storage
  await Hive.initFlutter();

  final localStorageService = LocalStorageService();
  await localStorageService.initialize();
  await localStorageService.initAuthBox();

  // Initialize Supabase if credentials are configured
  final supabaseService = SupabaseService();
  await supabaseService.initialize(
    AppConstants.supabaseUrl,
    AppConstants.supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
        supabaseServiceProvider.overrideWithValue(supabaseService),
      ],
      child: const MoodiaryApp(),
    ),
  );
}
