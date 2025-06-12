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
  int teamSize; // NEW: Team size field (number of team members)

  UserInputData({
    this.level,
    this.interests = const {},
    this.mainGoal,
    this.technologies = const {},
    this.projectDurationInMonths = 3.0, // Default value
    this.productTypes = const {},
    this.specialRequirements,
    this.problemToSolve,
    this.teamSize = 1, // Default to 1 person (solo project)
  });

  // Helper methods for validation
  bool isStep1Valid() {
    return level != null &&
        interests.isNotEmpty &&
        mainGoal != null &&
        technologies.isNotEmpty;
  }

  bool isStep2Valid() {
    return productTypes.isNotEmpty &&
        teamSize >= 1 &&
        teamSize <= 10; // Validate team size range
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
    int? teamSize,
  }) {
    return UserInputData(
      level: level ?? this.level,
      interests: interests ?? this.interests,
      mainGoal: mainGoal ?? this.mainGoal,
      technologies: technologies ?? this.technologies,
      projectDurationInMonths:
          projectDurationInMonths ?? this.projectDurationInMonths,
      productTypes: productTypes ?? this.productTypes,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      problemToSolve: problemToSolve ?? this.problemToSolve,
      teamSize: teamSize ?? this.teamSize,
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
      'teamSize': teamSize,
    };
  }

  // Helper getters for team size context
  String get teamSizeDescription {
    switch (teamSize) {
      case 1:
        return 'Dự án cá nhân (Solo)';
      case 2:
        return 'Nhóm nhỏ (2 người)';
      case 3:
      case 4:
        return 'Nhóm vừa ($teamSize người)';
      case 5:
      case 6:
      case 7:
        return 'Nhóm lớn ($teamSize người)';
      default:
        return 'Nhóm rất lớn ($teamSize người)';
    }
  }

  bool get isSoloProject => teamSize == 1;

  bool get isSmallTeam => teamSize >= 2 && teamSize <= 4;

  bool get isLargeTeam => teamSize >= 5;

  @override
  String toString() {
    return 'UserInputData(level: $level, interests: $interests, mainGoal: $mainGoal, technologies: $technologies, projectDurationInMonths: $projectDurationInMonths, productTypes: $productTypes, specialRequirements: $specialRequirements, problemToSolve: $problemToSolve, teamSize: $teamSize)';
  }
}
