import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    debugPrint('📝 [INFO] $message');
  }

  static void warn(String message) {
    debugPrint('⚠️ [WARN] $message');
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ [ERROR] $message');
    if (error != null) debugPrint('   $error');
    if (stackTrace != null) debugPrint('   $stackTrace');
  }

  static void ai(String message) {
    debugPrint('🤖 [AI] $message');
  }
}
