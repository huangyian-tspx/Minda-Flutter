import 'package:get/get.dart';
import 'ai_thinking_controller.dart';

/// Binding for AI Thinking module
/// Handles dependency injection for the AI Thinking screen
class AIThinkingBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put the controller - it will be created when first accessed
    Get.lazyPut<AIThinkingController>(
      () => AIThinkingController(),
    );
  }
} 