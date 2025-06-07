import 'package:get/get.dart';
import 'refinement_controller.dart';

class RefinementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefinementController>(() => RefinementController());
  }
} 