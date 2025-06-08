import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../core/values/app_constants.dart';
import '../../data/services/user_data_collection_service.dart';
import '../../di.dart';
import '../../routes/app_routes.dart';

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

      // === NEW NAVIGATION FLOW ===

      // 1. Navigate to AI Thinking screen immediately
      AppLogger.d("Navigating to AI Thinking screen");
      Get.toNamed(Routes.AI_THINKING);

      // 2. Prepare data for API
      final promptData = userInput.toJson();
      AppLogger.i("Final User Input Data: $promptData");

      // 3. Simulate API processing time (replace with real API call)
      AppLogger.d("Starting API simulation");
      await _simulateAPICall();

      // 4. When API completes, navigate to suggestion list
      // Use offNamed so user can't go back to AI thinking screen
      AppLogger.d("API completed, navigating to suggestion list");
      Get.offNamed(Routes.SUGGESTION_LIST);
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

  /// Simulate API call with realistic timing
  /// Replace this with actual API integration
  Future<void> _simulateAPICall() async {
    AppLogger.d("Simulating API call...");

    // Simulate network delay (3-6 seconds for realistic feel)
    await Future.delayed(const Duration(seconds: 4));

    // Here you would normally call your API:
    // final response = await apiService.generateSuggestions(promptData);
    // Handle the response and store results

    AppLogger.d("API simulation completed");
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
