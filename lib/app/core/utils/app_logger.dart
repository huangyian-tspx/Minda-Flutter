import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  // Log cho debug (màu xanh lá)
  static void d(String message) {
    if (kDebugMode) {
      developer.log('✅ [DEBUG] $message');
    }
  }

  // Log cho lỗi (màu đỏ)
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log('❌ [ERROR] $message', error: error, stackTrace: stackTrace);
    }
  }

  // Log cho thông tin (màu xanh dương)
  static void i(String message) {
    if (kDebugMode) {
      developer.log('ℹ️ [INFO] $message');
    }
  }
} 