import 'package:get/get.dart';
import 'information_input_controller.dart';

class InformationInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformationInputController>(() => InformationInputController());
  }
} 