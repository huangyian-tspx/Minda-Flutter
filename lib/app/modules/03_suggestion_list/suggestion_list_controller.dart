import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/api_response.dart';
import '../../data/models/topic_suggestion_model.dart';
import '../../data/repositories/topic_repository.dart';
import '../../routes/app_routes.dart';

class SuggestionListController extends BaseController {
  final _repository = TopicRepository();
  var suggestionData = Rxn<TopicSuggestionModel>();

  void goToProjectDetail(dynamic projectData) {
    Get.toNamed(Routes.PROJECT_DETAIL, arguments: projectData);
  }

  void goBackToRefinement() {
    Get.back();
  }

  void loadSuggestions() async {
    showLoading();

    // Tạo params để gửi API
    final params = {
      'interests': ['Technology', 'AI', 'Mobile Development'],
      'difficulty': 'intermediate',
      'timeframe': '3_months',
    };

    final response = await _repository.getTopicSuggestions(params);
    hideLoading();

    switch (response) {
      case Success(data: final data):
        suggestionData.value = data;
        AppLogger.d(
          "Fetch topics successfully! Got ${data.topics.length} topics",
        );
        break;
      case Failure(error: final error):
        AppLogger.e("Failed to fetch topics: ${error.error}");
        Get.snackbar(
          'Error',
          'Failed to load suggestions: ${error.error}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }

  void searchTopics(String query) async {
    showLoading();

    final queries = {'q': query, 'limit': 10};
    final response = await _repository.searchTopics(queries);
    hideLoading();

    switch (response) {
      case Success(data: final data):
        suggestionData.value = data;
        AppLogger.d(
          "Search topics successfully! Found ${data.topics.length} topics",
        );
        break;
      case Failure(error: final error):
        AppLogger.e("Failed to search topics: ${error.error}");
        Get.snackbar(
          'Error',
          'Search failed: ${error.error}',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }
}
