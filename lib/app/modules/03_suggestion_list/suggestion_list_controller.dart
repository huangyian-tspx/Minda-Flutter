import 'package:get/get.dart';

import '../../core/base/scrollable_page_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_enums.dart';
import '../../data/models/api_response.dart';
import '../../data/models/topic_suggestion_model.dart';
import '../../data/repositories/topic_repository.dart';
import '../../routes/app_routes.dart';

enum SuggestionFilter { safe, challenging }

class SuggestionListController extends ScrollablePageController {
  final _repository = TopicRepository();
  var suggestionData = Rxn<TopicSuggestionModel>();

  // Favorite management
  final RxSet<String> favoriteTopicIds = <String>{}.obs;

  final selectedFilter = SuggestionFilter.safe.obs;

  List<Topic> get filteredSuggestionList {
    if (suggestionData.value == null) return [];
    // For demo, just return all topics for both filters
    // Replace with .safeTopics/.challengingTopics if your model supports
    switch (selectedFilter.value) {
      case SuggestionFilter.safe:
        return suggestionData.value!.topics;
      case SuggestionFilter.challenging:
        return suggestionData.value!.topics;
    }
  }

  void onFilterChanged(SuggestionFilter newFilter) {
    if (selectedFilter.value != newFilter) {
      selectedFilter.value = newFilter;
    }
  }

  void onTopicCardTapped(Topic topic) {
    Get.toNamed(Routes.PROJECT_DETAIL, arguments: topic);
  }

  void toggleFavorite(String topicId) {
    if (favoriteTopicIds.contains(topicId)) {
      favoriteTopicIds.remove(topicId);
    } else {
      favoriteTopicIds.add(topicId);
    }
    update();
  }

  bool isFavorite(String topicId) => favoriteTopicIds.contains(topicId);

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

  @override
  void handleAppBarAction(PopupMenuAction action) {
    switch (action) {
      case PopupMenuAction.restartFromBeginning:
        Get.offAllNamed('/information-input');
        break;
      case PopupMenuAction.favoriteProjects:
        // TODO: Navigate to favorites screen
        break;
      case PopupMenuAction.settings:
        // TODO: Navigate to settings screen
        break;
      default:
        super.handleAppBarAction(action);
        break;
    }
  }
}
