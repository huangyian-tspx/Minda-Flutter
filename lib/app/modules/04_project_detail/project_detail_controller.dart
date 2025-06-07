import 'package:get/get.dart';
import 'package:mind_ai_app/app/data/models/project_detail_model.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/api_response.dart';
import '../../data/repositories/topic_repository.dart';
import '../../routes/app_routes.dart';

class ProjectDetailController extends BaseController {
  final _repository = TopicRepository();
  var projectDetails = ProjectDetailModel(
    id: '',
    name: '',
    description: '',
  ).obs;

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
