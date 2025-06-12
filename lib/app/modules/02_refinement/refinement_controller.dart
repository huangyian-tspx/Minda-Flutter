import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_constants.dart';
import '../../data/models/api_response.dart';
import '../../data/services/openrouter_api_service.dart';
import '../../data/services/user_data_collection_service.dart';
import '../../di.dart';
import '../../routes/app_routes.dart';
import '../ai_thinking/ai_thinking_controller.dart';

/// Controller for Refinement (Step 2) screen
/// Manages additional project details and finalizes user input collection
class RefinementController extends BaseController {
  // Inject the central data collection service
  final collectionService = sl<UserDataCollectionService>();

  // Text controllers for text input fields
  final specialReqController = TextEditingController();
  final problemController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("RefinementController initialized");

    // Initialize controllers with existing data if any
    final currentData = collectionService.userInput.value;
    if (currentData.specialRequirements != null) {
      specialReqController.text = currentData.specialRequirements!;
    }
    if (currentData.problemToSolve != null) {
      problemController.text = currentData.problemToSolve!;
    }

    // Listen to text changes and update service
    specialReqController.addListener(() {
      collectionService.updateSpecialRequirements(specialReqController.text);
    });

    problemController.addListener(() {
      collectionService.updateProblemToSolve(problemController.text);
    });

    // Log current state for debugging
    collectionService.logCurrentState();
  }

  // Project duration management
  void updateProjectDuration(double months) {
    AppLogger.d("User updated project duration: $months months");
    collectionService.updateProjectDuration(months);
  }

  // Product type management
  void toggleProductType(String productType) {
    AppLogger.d("User toggled product type: $productType");
    collectionService.toggleProductType(productType);
  }

  void showAddProductTypeDialog() {
    final TextEditingController textController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text(AppConstants.dialogAddProductType),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: AppConstants.dialogHintProductType,
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
                collectionService.addCustomProductType(
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

  void removeCustomProductType(String customType) {
    collectionService.removeCustomProductType(customType);
  }

  // ========== TEAM SIZE MANAGEMENT ==========

  /// Increment team size with validation
  void incrementTeamSize() {
    AppLogger.d("User wants to increment team size");
    collectionService.incrementTeamSize();
  }

  /// Decrement team size with validation
  void decrementTeamSize() {
    AppLogger.d("User wants to decrement team size");
    collectionService.decrementTeamSize();
  }

  /// Update team size directly (for text input if needed)
  void updateTeamSize(int size) {
    AppLogger.d("User updated team size to: $size");
    collectionService.updateTeamSize(size);
  }

  /// Validate team size and show error if invalid
  bool validateTeamSize() {
    final currentSize = collectionService.currentTeamSize;
    if (currentSize < AppConstants.minTeamSize ||
        currentSize > AppConstants.maxTeamSize) {
      AppLogger.e("Invalid team size: $currentSize");
      Get.snackbar(
        AppConstants.validationIncompleteData,
        AppConstants.validationInvalidTeamSize,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  // Validation and final submission
  void submitAndGenerate() async {
    AppLogger.d("Attempting to submit and generate suggestions");

    try {
      final userInput = collectionService.userInput.value;

      // Step 1 validation
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

      // Step 2 validation
      if (userInput.productTypes.isEmpty) {
        AppLogger.e("Validation failed: No product types selected");
        Get.snackbar(
          AppConstants.validationIncompleteData,
          AppConstants.validationSelectProductTypes,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // NEW: Team size validation
      if (!validateTeamSize()) {
        AppLogger.e("Validation failed: Invalid team size");
        return; // validateTeamSize() already shows error message
      }

      // === NEW NAVIGATION FLOW ===

      // 1. Navigate to AI Thinking screen immediately
      AppLogger.d("Navigating to AI Thinking screen");
      Get.toNamed(Routes.AI_THINKING);

      // 2. Prepare data for API
      final promptData = userInput.toJson();
      AppLogger.i("Final User Input Data: $promptData");

      // 3. Call real OpenRouter API
      AppLogger.d("Starting OpenRouter API call");
      await _callOpenRouterAPI();
    } catch (error) {
      AppLogger.e("Error during submission: $error");

      // If we're on AI thinking screen, go back to refinement
      if (Get.currentRoute == Routes.AI_THINKING) {
        Get.back();
      }

      Get.snackbar(
        'Lỗi',
        'Đã có lỗi xảy ra. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Call OpenRouter API để generate project suggestions
  Future<void> _callOpenRouterAPI() async {
    try {
      AppLogger.d("Calling OpenRouter API...");

      // Update thinking message nếu có thể
      if (Get.isRegistered<AIThinkingController>()) {
        final thinkingController = Get.find<AIThinkingController>();
        thinkingController.updateMessage("Đang gửi thông tin đến AI...");
      }

      // Call OpenRouter API
      final response = await OpenRouterAPIService.instance
          .generateProjectSuggestions();

      switch (response) {
        case Success(data: final suggestionData):
          AppLogger.d(
            "API call successful! Got ${suggestionData.topics.length} suggestions",
          );

          // Update thinking message
          if (Get.isRegistered<AIThinkingController>()) {
            final thinkingController = Get.find<AIThinkingController>();
            thinkingController.updateMessage(
              "Đã nhận được ${suggestionData.topics.length} đề xuất dự án!",
            );
          }

          // Wait a bit để user thấy success message
          await Future.delayed(const Duration(milliseconds: 1500));

          // Navigate to suggestion list with data
          AppLogger.d("Navigating to suggestion list");
          Get.offNamed(Routes.SUGGESTION_LIST, arguments: suggestionData);
          break;

        case Failure(error: final error):
          AppLogger.e("API call failed: ${error.message}");

          // Update thinking message với error
          if (Get.isRegistered<AIThinkingController>()) {
            final thinkingController = Get.find<AIThinkingController>();
            thinkingController.updateMessage(
              "Đã có lỗi xảy ra: ${error.message}",
            );
          }

          // Wait để user đọc error message
          await Future.delayed(const Duration(seconds: 2));

          // Go back to refinement screen
          Get.back();

          // Show error snackbar
          Get.snackbar(
            'Lỗi AI',
            error.message,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 5),
          );
          break;
      }
    } catch (e) {
      AppLogger.e("Unexpected error in API call: $e");

      // Update thinking message với error
      if (Get.isRegistered<AIThinkingController>()) {
        final thinkingController = Get.find<AIThinkingController>();
        thinkingController.updateMessage("Lỗi không xác định: ${e.toString()}");
      }

      await Future.delayed(const Duration(seconds: 2));
      Get.back();

      Get.snackbar(
        'Lỗi',
        'Đã có lỗi không xác định. Vui lòng thử lại.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Helper getters for the view
  bool isProductTypeSelected(String productType) {
    return collectionService.userInput.value.productTypes.contains(productType);
  }

  bool isCustomProductType(String productType) {
    return collectionService.customProductTypes.contains(productType);
  }

  double get currentProjectDuration =>
      collectionService.userInput.value.projectDurationInMonths;

  int get selectedProductTypesCount =>
      collectionService.userInput.value.productTypes.length;

  bool get canProceed => collectionService.isDataComplete();

  // Get all available product types (default + custom)
  List<String> get allProductTypes => collectionService.getAllProductTypes();

  // ========== TEAM SIZE GETTERS ==========

  /// Current team size
  int get currentTeamSize => collectionService.currentTeamSize;

  /// Team size description for UI display
  String get teamSizeDescription => collectionService.teamSizeDescription;

  /// Check if this is a solo project
  bool get isSoloProject => collectionService.isSoloProject;

  /// Check if this is a small team
  bool get isSmallTeam => collectionService.isSmallTeam;

  /// Check if this is a large team
  bool get isLargeTeam => collectionService.isLargeTeam;

  /// Check if can increment team size
  bool get canIncrementTeamSize => currentTeamSize < AppConstants.maxTeamSize;

  /// Check if can decrement team size
  bool get canDecrementTeamSize => currentTeamSize > AppConstants.minTeamSize;

  // Navigation helper
  void goBack() {
    Get.back();
  }

  // Debug method
  void clearAllSelections() {
    AppLogger.d("Clearing all selections");
    collectionService.clearAllData();
    specialReqController.clear();
    problemController.clear();
  }

  @override
  void onClose() {
    specialReqController.dispose();
    problemController.dispose();
    super.onClose();
  }
}
