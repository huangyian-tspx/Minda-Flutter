class UserInputData {
  // Step 1 data
  String? level;
  Set<String> interests;
  String? mainGoal;
  Set<String> technologies;

  // Step 2 data
  double projectDurationInMonths;
  Set<String> productTypes;
  String? specialRequirements;
  String? problemToSolve;

  UserInputData({
    this.level,
    this.interests = const {},
    this.mainGoal,
    this.technologies = const {},
    this.projectDurationInMonths = 3.0, // Default value
    this.productTypes = const {},
    this.specialRequirements,
    this.problemToSolve,
  });

  // Helper methods for validation
  bool isStep1Valid() {
    return level != null && 
           interests.isNotEmpty &&
           mainGoal != null &&
           technologies.isNotEmpty;
  }

  bool isStep2Valid() {
    return productTypes.isNotEmpty;
  }

  bool isComplete() {
    return isStep1Valid() && isStep2Valid();
  }

  // Copy method for immutable updates
  UserInputData copyWith({
    String? level,
    Set<String>? interests,
    String? mainGoal,
    Set<String>? technologies,
    double? projectDurationInMonths,
    Set<String>? productTypes,
    String? specialRequirements,
    String? problemToSolve,
  }) {
    return UserInputData(
      level: level ?? this.level,
      interests: interests ?? this.interests,
      mainGoal: mainGoal ?? this.mainGoal,
      technologies: technologies ?? this.technologies,
      projectDurationInMonths: projectDurationInMonths ?? this.projectDurationInMonths,
      productTypes: productTypes ?? this.productTypes,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      problemToSolve: problemToSolve ?? this.problemToSolve,
    );
  }

  // Convert to JSON for API calls
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'interests': interests.toList(),
      'mainGoal': mainGoal,
      'technologies': technologies.toList(),
      'projectDurationInMonths': projectDurationInMonths,
      'productTypes': productTypes.toList(),
      'specialRequirements': specialRequirements,
      'problemToSolve': problemToSolve,
    };
  }

  @override
  String toString() {
    return 'UserInputData(level: $level, interests: $interests, mainGoal: $mainGoal, technologies: $technologies, projectDurationInMonths: $projectDurationInMonths, productTypes: $productTypes, specialRequirements: $specialRequirements, problemToSolve: $problemToSolve)';
  }
} 