import 'package:get/get.dart';

import '../../core/utils/app_logger.dart';
import '../../core/values/app_constants.dart';
import '../models/user_input_data.dart';

/// Central service for collecting and managing user input data throughout the flow
/// This service acts as a single source of truth for all user inputs
class UserDataCollectionService {
  // Observable user input data
  final userInput = UserInputData().obs;

  // Custom options that users can add
  final customMainGoals = <String>[].obs;
  final customTechnologies = <String>[].obs;
  final customProductTypes = <String>[].obs;

  // Level selection
  void updateLevel(String level) {
    AppLogger.d("Updating user level: $level");
    userInput.update((val) {
      val?.level = level;
    });
  }

  // Interest management
  void toggleInterest(String interest) {
    AppLogger.d("Toggling interest: $interest");
    userInput.update((val) {
      final currentInterests = Set<String>.from(val!.interests);
      if (currentInterests.contains(interest)) {
        currentInterests.remove(interest);
        AppLogger.d("Removed interest: $interest");
      } else {
        currentInterests.add(interest);
        AppLogger.d("Added interest: $interest");
      }
      val.interests = currentInterests;
    });
  }

  void clearInterests() {
    userInput.update((val) {
      val?.interests = <String>{};
    });
  }

  // Main goal selection with custom support
  void updateMainGoal(String mainGoal) {
    AppLogger.d("Updating main goal: $mainGoal");
    userInput.update((val) {
      val?.mainGoal = mainGoal;
    });
  }

  void addCustomMainGoal(String customGoal) {
    if (customGoal.trim().isNotEmpty &&
        !customMainGoals.contains(customGoal.trim())) {
      AppLogger.d("Adding custom main goal: $customGoal");
      customMainGoals.add(customGoal.trim());
      updateMainGoal(customGoal.trim());
    }
  }

  void removeCustomMainGoal(String customGoal) {
    AppLogger.d("Removing custom main goal: $customGoal");
    customMainGoals.remove(customGoal);
    // If this was the selected goal, clear selection
    if (userInput.value.mainGoal == customGoal) {
      userInput.update((val) {
        val?.mainGoal = null;
      });
    }
  }

  // Get all available main goals (default + custom)
  List<String> getAllMainGoals() {
    return [...AppConstants.mainGoals, ...customMainGoals];
  }

  // Technology management with custom support
  void toggleTechnology(String technology) {
    AppLogger.d("Toggling technology: $technology");
    userInput.update((val) {
      final currentTechnologies = Set<String>.from(val!.technologies);
      if (currentTechnologies.contains(technology)) {
        currentTechnologies.remove(technology);
        AppLogger.d("Removed technology: $technology");
      } else {
        currentTechnologies.add(technology);
        AppLogger.d("Added technology: $technology");
      }
      val.technologies = currentTechnologies;
    });
  }

  void addCustomTechnology(String customTech) {
    if (customTech.trim().isNotEmpty &&
        !customTechnologies.contains(customTech.trim())) {
      AppLogger.d("Adding custom technology: $customTech");
      customTechnologies.add(customTech.trim());
      // Also select it
      userInput.update((val) {
        final currentTechnologies = Set<String>.from(val!.technologies);
        currentTechnologies.add(customTech.trim());
        val.technologies = currentTechnologies;
      });
    }
  }

  void removeCustomTechnology(String customTech) {
    AppLogger.d("Removing custom technology: $customTech");
    customTechnologies.remove(customTech);
    // Also remove from selected technologies
    userInput.update((val) {
      final currentTechnologies = Set<String>.from(val!.technologies);
      currentTechnologies.remove(customTech);
      val.technologies = currentTechnologies;
    });
  }

  // Get all available technologies (default + custom)
  List<String> getAllTechnologies() {
    return [...AppConstants.technologies, ...customTechnologies];
  }

  void clearTechnologies() {
    userInput.update((val) {
      val?.technologies = <String>{};
    });
  }

  // ========== STEP 2 METHODS ==========

  // Project duration management
  void updateProjectDuration(double months) {
    AppLogger.d("Updating project duration: $months months");
    userInput.update((val) {
      val?.projectDurationInMonths = months;
    });
  }

  // Product type management with custom support
  void toggleProductType(String productType) {
    AppLogger.d("Toggling product type: $productType");
    userInput.update((val) {
      final currentTypes = Set<String>.from(val!.productTypes);
      if (currentTypes.contains(productType)) {
        currentTypes.remove(productType);
        AppLogger.d("Removed product type: $productType");
      } else {
        currentTypes.add(productType);
        AppLogger.d("Added product type: $productType");
      }
      val.productTypes = currentTypes;
    });
  }

  void addCustomProductType(String customType) {
    if (customType.trim().isNotEmpty &&
        !customProductTypes.contains(customType.trim())) {
      AppLogger.d("Adding custom product type: $customType");
      customProductTypes.add(customType.trim());
      // Also select it
      userInput.update((val) {
        final currentTypes = Set<String>.from(val!.productTypes);
        currentTypes.add(customType.trim());
        val.productTypes = currentTypes;
      });
    }
  }

  void removeCustomProductType(String customType) {
    AppLogger.d("Removing custom product type: $customType");
    customProductTypes.remove(customType);
    // Also remove from selected types
    userInput.update((val) {
      final currentTypes = Set<String>.from(val!.productTypes);
      currentTypes.remove(customType);
      val.productTypes = currentTypes;
    });
  }

  // Get all available product types (default + custom)
  List<String> getAllProductTypes() {
    return [...AppConstants.productTypes, ...customProductTypes];
  }

  // Special requirements management
  void updateSpecialRequirements(String text) {
    AppLogger.d(
      "Updating special requirements: ${text.length > 50 ? text.substring(0, 50) + '...' : text}",
    );
    userInput.update((val) {
      val?.specialRequirements = text.trim().isEmpty ? null : text.trim();
    });
  }

  // Problem to solve management
  void updateProblemToSolve(String text) {
    AppLogger.d(
      "Updating problem to solve: ${text.length > 50 ? text.substring(0, 50) + '...' : text}",
    );
    userInput.update((val) {
      val?.problemToSolve = text.trim().isEmpty ? null : text.trim();
    });
  }

  // ========== TEAM SIZE MANAGEMENT ==========

  /// Update team size với validation
  void updateTeamSize(int size) {
    AppLogger.d("Updating team size: $size");

    // Validate team size range
    if (size < 1) {
      AppLogger.e("Invalid team size: $size (minimum: 1)");
      size = 1;
    } else if (size > 10) {
      AppLogger.e("Invalid team size: $size (maximum: 10)");
      size = 10;
    }

    userInput.update((val) {
      val?.teamSize = size;
    });

    AppLogger.d(
      "Team size updated to: $size (${userInput.value.teamSizeDescription})",
    );
  }

  /// Increment team size với validation
  void incrementTeamSize() {
    final currentSize = userInput.value.teamSize;
    if (currentSize < 10) {
      updateTeamSize(currentSize + 1);
    } else {
      AppLogger.d("Cannot increment team size: already at maximum (10)");
    }
  }

  /// Decrement team size với validation
  void decrementTeamSize() {
    final currentSize = userInput.value.teamSize;
    if (currentSize > 1) {
      updateTeamSize(currentSize - 1);
    } else {
      AppLogger.d("Cannot decrement team size: already at minimum (1)");
    }
  }

  /// Get team size context for UI
  String get teamSizeDescription => userInput.value.teamSizeDescription;
  bool get isSoloProject => userInput.value.isSoloProject;
  bool get isSmallTeam => userInput.value.isSmallTeam;
  bool get isLargeTeam => userInput.value.isLargeTeam;
  int get currentTeamSize => userInput.value.teamSize;

  // Validation methods
  bool isStep1Valid() => userInput.value.isStep1Valid();
  bool isStep2Valid() => userInput.value.isStep2Valid();
  bool isDataComplete() => userInput.value.isComplete();

  // Reset all data including custom options
  void clearAllData() {
    AppLogger.d("Clearing all user input data");
    userInput.value = UserInputData();
    customMainGoals.clear();
    customTechnologies.clear();
    customProductTypes.clear();
  }

  // Get current data as immutable copy
  UserInputData getCurrentData() {
    return userInput.value.copyWith(
      level: userInput.value.level,
      interests: Set<String>.from(userInput.value.interests),
      mainGoal: userInput.value.mainGoal,
      technologies: Set<String>.from(userInput.value.technologies),
      projectDurationInMonths: userInput.value.projectDurationInMonths,
      productTypes: Set<String>.from(userInput.value.productTypes),
      specialRequirements: userInput.value.specialRequirements,
      problemToSolve: userInput.value.problemToSolve,
      teamSize: userInput.value.teamSize,
    );
  }

  // Debug helper
  void logCurrentState() {
    AppLogger.d("Current user input state: ${userInput.value}");
    AppLogger.d("Custom main goals: $customMainGoals");
    AppLogger.d("Custom technologies: $customTechnologies");
    AppLogger.d("Custom product types: $customProductTypes");
    AppLogger.d(
      "Team context: ${teamSizeDescription} (${currentTeamSize} members)",
    );
  }
}
