class ProjectTopic {
  final String name;
  final List<Feature> features;
  final List<Technology> techStack;
  final List<ImplementationStep> implementationSteps;

  ProjectTopic({
    required this.name,
    required this.features,
    required this.techStack,
    required this.implementationSteps,
  });
}

class Feature {
  final String title;
  final String description;

  Feature({required this.title, required this.description});
}

class Technology {
  final String name;
  final String description;

  Technology({required this.name, required this.description});
}

class ImplementationStep {
  final String title;
  final String? codeExample;

  ImplementationStep({required this.title, this.codeExample});
}
