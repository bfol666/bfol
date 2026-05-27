class AppConstants {
  AppConstants._();

  // Supabase
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // OpenAI
  static const String openaiApiKey = String.fromEnvironment('OPENAI_API_KEY');

  // App
  static const String appName = 'Moodiary';
  static const String appVersion = '1.0.0';

  // Limits
  static const int maxMediaPerEntry = 9;
}
