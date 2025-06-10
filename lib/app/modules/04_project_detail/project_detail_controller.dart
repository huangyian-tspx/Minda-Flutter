import 'package:get/get.dart';
import '../../core/base/scrollable_page_controller.dart';
import '../../data/models/topic_suggestion_model.dart';
import 'expandable_list_controller.dart';

class ProjectDetailController extends ScrollablePageController {
  final topic = Rxn<ProjectTopic>();
  
  // Controllers for expandable lists
  late final ExpandableListController coreFeaturesController;
  late final ExpandableListController advancedFeaturesController;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize expandable list controllers
    coreFeaturesController = ExpandableListController();
    advancedFeaturesController = ExpandableListController();
    
    // Lấy dữ liệu được truyền từ màn hình trước
    if (Get.arguments != null) {
      if (Get.arguments is ProjectTopic) {
        topic.value = Get.arguments;
      } else if (Get.arguments is Topic) {
        // Convert Topic to ProjectTopic
        topic.value = ProjectTopic.fromTopic(Get.arguments);
      }
    }
  }

  @override
  void onClose() {
    coreFeaturesController.dispose();
    advancedFeaturesController.dispose();
    super.onClose();
  }

  // --- Logic cho các nút Action ---
  void createChecklist() {
    // TODO: Implement logic tạo checklist
    Get.snackbar(
      'Tính năng sắp ra mắt', 
      'Chức năng tạo checklist sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareToTeam() {
    // TODO: Sử dụng package share_plus để chia sẻ nội dung
    Get.snackbar(
      'Tính năng sắp ra mắt', 
      'Chức năng chia sẻ cho team sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void createNotionDocs() {
    // TODO: Implement logic tích hợp Notion (nếu có)
    Get.snackbar(
      'Tính năng sắp ra mắt', 
      'Chức năng tạo tài liệu Notion sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void suggestLibraries() {
    // TODO: Hiển thị Get.bottomSheet với danh sách thư viện gợi ý
    Get.snackbar(
      'Tính năng sắp ra mắt', 
      'Chức năng gợi ý thư viện sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
