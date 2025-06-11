import 'package:get/get.dart';
import '../../data/services/user_data_collection_service.dart';
import '../../di.dart';
import 'suggestion_list_controller.dart';

class SuggestionListBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure UserDataCollectionService is available for OpenRouter API
    if (!Get.isRegistered<UserDataCollectionService>()) {
      Get.put<UserDataCollectionService>(sl<UserDataCollectionService>());
    }
    
    Get.lazyPut<SuggestionListController>(() => SuggestionListController());
  }
} 