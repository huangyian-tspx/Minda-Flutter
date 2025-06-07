import 'package:get/get.dart';
import 'suggestion_list_controller.dart';

class SuggestionListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SuggestionListController>(() => SuggestionListController());
  }
} 