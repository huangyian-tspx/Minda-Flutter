import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_constants.dart';
import '../../data/services/user_data_collection_service.dart';
import '../../di.dart';
import '../../routes/app_routes.dart';

/// Controller for Information Input (Step 1) screen
/// This controller delegates all state management to UserDataCollectionService
/// keeping the controller thin and focused on UI logic
class InformationInputController extends BaseController {
  // Inject the central data collection service
  final collectionService = sl<UserDataCollectionService>();

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("InformationInputController initialized");
    // Log current state for debugging
    collectionService.logCurrentState();
  }

  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Có thể show snackbar hoặc log lỗi
      print('Không thể mở link: $url');
    }
  }

  // Level selection methods
  void selectLevel(String level) {
    AppLogger.d("User selected level: $level");
    collectionService.updateLevel(level);
  }

  // Interest management methods
  void toggleInterest(String interest) {
    AppLogger.d("User toggled interest: $interest");
    collectionService.toggleInterest(interest);
  }

  // Main goal management methods
  void selectMainGoal(String mainGoal) {
    AppLogger.d("User selected main goal: $mainGoal");
    collectionService.updateMainGoal(mainGoal);
  }

  void showAddMainGoalDialog() {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text(AppConstants.dialogAddMainGoal),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: AppConstants.dialogHintMainGoal,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppConstants.dialogButtonCancel),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                collectionService.addCustomMainGoal(textController.text.trim());
                Get.back();
              }
            },
            child: const Text(AppConstants.dialogButtonAdd),
          ),
        ],
      ),
    );
  }

  void removeCustomMainGoal(String customGoal) {
    collectionService.removeCustomMainGoal(customGoal);
  }

  // Technology management methods
  void toggleTechnology(String technology) {
    AppLogger.d("User toggled technology: $technology");
    collectionService.toggleTechnology(technology);
  }

  void showAddTechnologyDialog() {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text(AppConstants.dialogAddTechnology),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: AppConstants.dialogHintTechnology,
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppConstants.dialogButtonCancel),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                collectionService.addCustomTechnology(
                  textController.text.trim(),
                );
                Get.back();
              }
            },
            child: const Text(AppConstants.dialogButtonAdd),
          ),
        ],
      ),
    );
  }

  void removeCustomTechnology(String customTech) {
    collectionService.removeCustomTechnology(customTech);
  }

  // Validation and navigation
  void navigateToRefinement() {
    AppLogger.d("Attempting to navigate to refinement step");

    // Get current user input for validation
    final userInput = collectionService.userInput.value;

    // Validate Step 1 requirements
    if (userInput.level == null) {
      AppLogger.e("Validation failed: No level selected");
      Get.snackbar(
        AppConstants.validationIncompleteData,
        AppConstants.validationSelectLevel,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (userInput.interests.isEmpty) {
      AppLogger.e("Validation failed: No interests selected");
      Get.snackbar(
        AppConstants.validationIncompleteData,
        AppConstants.validationSelectInterests,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (userInput.mainGoal == null) {
      AppLogger.e("Validation failed: No main goal selected");
      Get.snackbar(
        AppConstants.validationIncompleteData,
        AppConstants.validationSelectGoal,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (userInput.technologies.isEmpty) {
      AppLogger.e("Validation failed: No technologies selected");
      Get.snackbar(
        AppConstants.validationIncompleteData,
        AppConstants.validationSelectTechnologies,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // If validation passes, log and navigate
    AppLogger.d("Step 1 validation passed, navigating to refinement");
    collectionService.logCurrentState();
    Get.toNamed(Routes.REFINEMENT);
  }

  // Helper getters for the view to check selection state
  bool isLevelSelected(String level) {
    return collectionService.userInput.value.level == level;
  }

  bool isInterestSelected(String interest) {
    return collectionService.userInput.value.interests.contains(interest);
  }

  bool isMainGoalSelected(String mainGoal) {
    return collectionService.userInput.value.mainGoal == mainGoal;
  }

  bool isTechnologySelected(String technology) {
    return collectionService.userInput.value.technologies.contains(technology);
  }

  // Check if option is custom (not in default list)
  bool isCustomMainGoal(String mainGoal) {
    return collectionService.customMainGoals.contains(mainGoal);
  }

  bool isCustomTechnology(String technology) {
    return collectionService.customTechnologies.contains(technology);
  }

  // Get selection counts for UI feedback
  int get selectedInterestsCount =>
      collectionService.userInput.value.interests.length;

  int get selectedTechnologiesCount =>
      collectionService.userInput.value.technologies.length;

  bool get hasSelectedLevel => collectionService.userInput.value.level != null;
  bool get hasSelectedMainGoal =>
      collectionService.userInput.value.mainGoal != null;

  bool get canProceed => collectionService.isStep1Valid();

  // Get all available options (default + custom)
  List<String> get allMainGoals => collectionService.getAllMainGoals();
  List<String> get allTechnologies => collectionService.getAllTechnologies();

  // Debug method for development
  void clearAllSelections() {
    AppLogger.d("Clearing all selections");
    collectionService.clearAllData();
  }
}
