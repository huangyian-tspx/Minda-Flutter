import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../routes/app_routes.dart';

class RefinementController extends BaseController {
  
  void goToSuggestionList() {
    Get.toNamed(Routes.SUGGESTION_LIST);
  }
  
  void goBackToInput() {
    Get.back();
  }
  
  void startOver() {
    Get.offAllNamed(Routes.INFORMATION_INPUT);
  }
} 