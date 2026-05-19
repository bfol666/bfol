import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize local storage service
  final localStorageService = LocalStorageService();
  await localStorageService.initialize();

  // TODO: Initialize Supabase with real credentials
  // final supabaseService = SupabaseService();
  // await supabaseService.initialize(
  //   AppConstants.supabaseUrl,
  //   AppConstants.supabaseAnonKey,
  // );

  runApp(
    const ProviderScope(
      child: MoodiaryApp(),
    ),
  );
}
