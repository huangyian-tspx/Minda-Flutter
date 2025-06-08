import 'package:get/get.dart';
import 'information_input_controller.dart';

/// Binding for Information Input module
/// Handles dependency injection for the Information Input screen
class InformationInputBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy put the controller - it will be created when first accessed
    Get.lazyPut<InformationInputController>(
      () => InformationInputController(),
    );
  }
} 