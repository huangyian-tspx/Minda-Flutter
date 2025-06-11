import 'package:get/get.dart';
import '../../data/services/user_data_collection_service.dart';
import '../../di.dart';
import 'refinement_controller.dart';

class RefinementBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure UserDataCollectionService is available
    if (!Get.isRegistered<UserDataCollectionService>()) {
      Get.put<UserDataCollectionService>(sl<UserDataCollectionService>());
    }
    
    Get.lazyPut<RefinementController>(() => RefinementController());
  }
} 