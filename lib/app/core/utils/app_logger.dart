import 'package:flutter/foundation.dart';

class AppLogger {
  // Log cho debug (màu xanh lá)
  static void d(String message) {
    if (kDebugMode) {
      print('🔍 DEBUG: $message');
    }
  }

  // Log cho thông tin (màu xanh dương)
  static void i(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void w(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  // Log cho lỗi (màu đỏ)
  static void e(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }
}
