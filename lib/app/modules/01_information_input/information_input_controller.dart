import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../routes/app_routes.dart';

class InformationInputController extends BaseController {
  
  void goToRefinement() {
    Get.toNamed(Routes.REFINEMENT);
  }
  
  void fetchData() async {
    showLoading();
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    hideLoading();
  }
} 