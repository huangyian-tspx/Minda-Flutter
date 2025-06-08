import 'dart:async';

import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_constants.dart';

/// Controller for AI Thinking screen
/// Manages dynamic text messages that change during API processing
class AIThinkingController extends BaseController {
  // Observable text that changes dynamically
  final thinkingText = AppConstants.aiThinkingMessages.first.obs;

  // Timer for changing messages
  late Timer _timer;
  int _messageIndex = 0;

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("AIThinkingController initialized");

    // Start timer to change messages every 2.5 seconds
    _startMessageTimer();
  }

  /// Start timer for cycling through thinking messages
  void _startMessageTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _messageIndex =
          (_messageIndex + 1) % AppConstants.aiThinkingMessages.length;
      thinkingText.value = AppConstants.aiThinkingMessages[_messageIndex];
      AppLogger.d("Changed thinking message to: ${thinkingText.value}");
    });
  }

  /// Stop the message timer
  void stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
      AppLogger.d("Message timer stopped");
    }
  }

  /// Update thinking message manually (for specific API states)
  void updateMessage(String message) {
    thinkingText.value = message;
    AppLogger.d("Manual message update: $message");
  }

  @override
  void onClose() {
    // Critical: Cancel timer to prevent memory leaks
    _timer.cancel();
    AppLogger.d("AIThinkingController disposed");
    super.onClose();
  }
}
