import 'package:get/get.dart';

import '../../core/base/scrollable_page_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_enums.dart';
import '../../data/models/ai_response_model.dart';
import '../../data/models/api_response.dart';
import '../../data/models/topic_suggestion_model.dart';
import '../../data/repositories/topic_repository.dart';
import '../../routes/app_routes.dart';

enum SuggestionFilter { safe, challenging }

class SuggestionListController extends ScrollablePageController {
  final _repository = TopicRepository();
  var suggestionData = Rxn<TopicSuggestionModel>();

  // AI Response data để filter theo category
  var aiResponseData = Rxn<AIProjectResponse>();

  final selectedFilter = SuggestionFilter.safe.obs;

  @override
  void onInit() {
    super.onInit();

    // Check if data được pass từ arguments
    final arguments = Get.arguments;
    if (arguments != null && arguments is TopicSuggestionModel) {
      AppLogger.d(
        "Received suggestion data from arguments: ${arguments.topics.length} topics",
      );
      suggestionData.value = arguments;

      // Try to parse back to AIProjectResponse để có filter functionality
      _parseDataForFiltering(arguments);
    } else {
      AppLogger.e(
        "No suggestion data received from arguments - will load demo/API data",
      );
      // Có thể load demo data hoặc call API ở đây nếu cần
    }
  }

  /// Parse TopicSuggestionModel back to AIProjectResponse để support filtering
  void _parseDataForFiltering(TopicSuggestionModel data) {
    try {
      // Tách topics theo category dựa trên ID pattern hoặc difficulty
      final safeProjects = <Topic>[];
      final challengingProjects = <Topic>[];

      for (final topic in data.topics) {
        // Check ID pattern hoặc difficulty để phân loại
        if (topic.id.startsWith('safe_') ||
            topic.difficulty.toLowerCase().contains('an toàn') ||
            topic.difficulty.toLowerCase().contains('dễ qua môn')) {
          safeProjects.add(topic);
        } else if (topic.id.startsWith('challenge_') ||
            topic.difficulty.toLowerCase().contains('thử thách') ||
            topic.difficulty.toLowerCase().contains('điểm cao')) {
          challengingProjects.add(topic);
        } else {
          // Fallback: nếu không xác định được, add vào safe
          safeProjects.add(topic);
        }
      }

      aiResponseData.value = AIProjectResponse(
        safeProjects: safeProjects,
        challengingProjects: challengingProjects,
      );

      AppLogger.d(
        "Parsed data: ${safeProjects.length} safe + ${challengingProjects.length} challenging projects",
      );
    } catch (e) {
      AppLogger.e("Error parsing data for filtering: $e");
    }
  }

  List<Topic> get filteredSuggestionList {
    if (aiResponseData.value == null) {
      // Fallback to all topics if no AI response data
      return suggestionData.value?.topics ?? [];
    }

    switch (selectedFilter.value) {
      case SuggestionFilter.safe:
        return aiResponseData.value!.safeProjects;
      case SuggestionFilter.challenging:
        return aiResponseData.value!.challengingProjects;
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
        AppLogger.e("Failed to fetch topics: ${error.message}");
        Get.snackbar(
          'Error',
          'Failed to load suggestions: ${error.message}',
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
        AppLogger.e("Failed to search topics: ${error.message}");
        Get.snackbar(
          'Error',
          'Search failed: ${error.message}',
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
