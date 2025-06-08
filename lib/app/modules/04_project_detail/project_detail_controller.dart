import 'package:get/get.dart';
import 'package:mind_ai_app/app/data/models/project_detail_model.dart';
import 'expandable_item_data.dart';

import '../../core/base/scrollable_page_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/api_response.dart';
import '../../data/repositories/topic_repository.dart';
import '../../routes/app_routes.dart';

class ProjectDetailController extends ScrollablePageController {
  final _repository = TopicRepository();
  var projectDetails = ProjectDetailModel(
    id: '',
    name: '',
    description: '',
  ).obs;

  // Demo data for expandable list
  final List<ExpandableItemData> featureItems = [
    ExpandableItemData(
      title: 'Tính năng đăng nhập',
      content: 'Cho phép người dùng đăng nhập bằng email, Google hoặc Apple ID. Hỗ trợ xác thực hai lớp.',
    ),
    ExpandableItemData(
      title: 'Quản lý dự án',
      content: 'Người dùng có thể tạo, chỉnh sửa, xóa và theo dõi tiến độ dự án của mình một cách trực quan.',
    ),
    ExpandableItemData(
      title: 'Thông báo real-time',
      content: 'Nhận thông báo tức thì khi có cập nhật mới về dự án hoặc khi có thành viên mới tham gia.',
    ),
    ExpandableItemData(
      title: 'Báo cáo & Thống kê',
      content: 'Cung cấp các biểu đồ, số liệu thống kê giúp người dùng đánh giá hiệu quả dự án.',
    ),
  ];

  dynamic get projectData => Get.arguments;

  void goBackToSuggestionList() {
    Get.back();
  }

  void goToHomePage() {
    Get.offAllNamed(Routes.INFORMATION_INPUT);
  }

  void loadProjectDetails() async {
    showLoading();

    // Lấy project ID từ arguments hoặc sử dụng default
    String projectId = '1';
    if (projectData != null && projectData['id'] != null) {
      projectId = projectData['id'].toString();
    }

    final response = await _repository.getProjectDetail(projectId);
    hideLoading();

    switch (response) {
      case Success(data: final data):
        projectDetails.value = data;
        AppLogger.d("Load project details successfully for ID: $projectId");
        break;
      case Failure(error: final error):
        AppLogger.e("Failed to load project details: ${error.error}");
        Get.snackbar(
          'Error',
          'Failed to load project details: ${error.error}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }
}
