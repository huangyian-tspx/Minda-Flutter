import 'package:json_annotation/json_annotation.dart';

import '../../core/widgets/code_viewer.dart';
import '../../modules/04_project_detail/expandable_item_data.dart';
import 'knowledge_item.dart';

part 'topic_suggestion_model.g.dart';

@JsonSerializable()
class TopicSuggestionModel {
  final List<Topic> topics;
  final String message;
  final bool success;

  TopicSuggestionModel({
    required this.topics,
    required this.message,
    required this.success,
  });

  factory TopicSuggestionModel.fromJson(Map<String, dynamic> json) =>
      _$TopicSuggestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TopicSuggestionModelToJson(this);
}

@JsonSerializable()
class Technology {
  final String name;
  final String description;

  Technology({required this.name, required this.description});

  factory Technology.fromJson(Map<String, dynamic> json) =>
      _$TechnologyFromJson(json);
  Map<String, dynamic> toJson() => _$TechnologyToJson(this);
}

@JsonSerializable()
class Topic {
  final String id;
  final String title;
  final String description;
  final List<Technology> technologies;
  final String difficulty;
  final int matchScore; // 0-100
  final int duration; // months
  final String feasibilityAssessment;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.difficulty,
    required this.matchScore,
    required this.duration,
    required this.feasibilityAssessment,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
  Map<String, dynamic> toJson() => _$TopicToJson(this);

  // Helper getter để lấy list tên technologies (backward compatibility)
  List<String> get technologyNames => technologies.map((t) => t.name).toList();
}

@JsonSerializable()
class ReferenceLink {
  final String title;
  final String url;
  ReferenceLink({required this.title, required this.url});
  factory ReferenceLink.fromJson(Map<String, dynamic> json) => ReferenceLink(
        title: json['title']?.toString() ?? '',
        url: json['url']?.toString() ?? '',
      );
  Map<String, dynamic> toJson() => {'title': title, 'url': url};
}

/// Extended version of Topic for detailed project view
class ProjectTopic extends Topic {
  final String problemStatement;
  final String proposedSolution;
  final List<Technology> coreTechStack;
  final List<ExpandableItemData> coreFeatures;
  final List<ExpandableItemData> advancedFeatures;
  final List<String> foundationalKnowledge;
  final List<KnowledgeItem> specificKnowledge;
  final List<String> implementationSteps;
  final List<CodeExample> codeExamples;
  final List<String> potentialChallenges;
  final List<String> resourcesAndTutorials;
  final List<ReferenceLink> referenceLinks;
  final List<ReferenceLink> githubLinks;

  ProjectTopic({
    required super.id,
    required super.title,
    required super.description,
    required super.technologies,
    required super.difficulty,
    required this.problemStatement,
    required this.proposedSolution,
    required this.coreTechStack,
    required this.coreFeatures,
    required this.advancedFeatures,
    required this.foundationalKnowledge,
    required this.specificKnowledge,
    required super.matchScore,
    required super.duration,
    required super.feasibilityAssessment,
    this.implementationSteps = const [],
    this.codeExamples = const [],
    this.potentialChallenges = const [],
    this.resourcesAndTutorials = const [],
    this.referenceLinks = const [],
    this.githubLinks = const [],
  });

  /// Create ProjectTopic from AI JSON response
  ///
  /// Parse detailed project information từ OpenRouter AI response
  ///
  /// [json] JSON response từ AI
  /// [basicTopic] Basic topic info để retain original data
  factory ProjectTopic.fromJson(Map<String, dynamic> json, Topic basicTopic) {
    // Parse core features
    final coreFeaturesList =
        (json['coreFeatures'] as List<dynamic>?)
            ?.map(
              (item) => ExpandableItemData(
                title: item['title']?.toString() ?? '',
                content: item['content']?.toString() ?? '',
              ),
            )
            .toList() ??
        [];

    // Parse advanced features
    final advancedFeaturesList =
        (json['advancedFeatures'] as List<dynamic>?)
            ?.map(
              (item) => ExpandableItemData(
                title: item['title']?.toString() ?? '',
                content: item['content']?.toString() ?? '',
              ),
            )
            .toList() ??
        [];

    // Parse foundational knowledge
    final foundationalKnowledgeList =
        (json['foundationalKnowledge'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    // Parse specific knowledge
    final specificKnowledgeList =
        (json['specificKnowledge'] as List<dynamic>?)?.map((item) {
          final difficultyStr =
              item['difficulty']?.toString().toLowerCase() ?? 'easy';
          KnowledgeDifficulty difficulty;
          switch (difficultyStr) {
            case 'medium':
              difficulty = KnowledgeDifficulty.medium;
              break;
            case 'hard':
              difficulty = KnowledgeDifficulty.hard;
              break;
            default:
              difficulty = KnowledgeDifficulty.easy;
          }

          return KnowledgeItem(
            title: item['title']?.toString() ?? '',
            difficulty: difficulty,
          );
        }).toList() ??
        [];

    // Parse implementation steps
    final implementationStepsList =
        (json['implementationSteps'] as List<dynamic>?)
            ?.map((item) => item.toString())
            .toList() ??
        [];

    // Parse code examples
    final codeExamplesList =
        (json['codeExamples'] as List<dynamic>?)
            ?.map((item) => CodeExample.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse referenceLinks
    final referenceLinksList = (json['referenceLinks'] as List?)?.map((item) {
      if (item is Map<String, dynamic>) {
        return ReferenceLink.fromJson(item);
      } else if (item is Map) {
        return ReferenceLink.fromJson(Map<String, dynamic>.from(item));
      }
      return null;
    }).whereType<ReferenceLink>().toList() ?? [];

    // Parse githubLinks
    final githubLinksList = (json['githubLinks'] as List?)?.map((item) {
      if (item is Map<String, dynamic>) {
        return ReferenceLink.fromJson(item);
      } else if (item is Map) {
        return ReferenceLink.fromJson(Map<String, dynamic>.from(item));
      }
      return null;
    }).whereType<ReferenceLink>().toList() ?? [];

    return ProjectTopic(
      id: basicTopic.id,
      title: basicTopic.title,
      description: basicTopic.description,
      technologies: basicTopic.technologies,
      difficulty: basicTopic.difficulty,
      matchScore: basicTopic.matchScore,
      duration: basicTopic.duration,
      feasibilityAssessment: basicTopic.feasibilityAssessment,
      problemStatement:
          json['problemStatement']?.toString() ??
          "Vấn đề cần giải quyết cho dự án ${basicTopic.title}",
      proposedSolution:
          json['proposedSolution']?.toString() ??
          "Hướng tiếp cận của dự án: ${basicTopic.description}",
      coreTechStack: basicTopic.technologies,
      coreFeatures: coreFeaturesList,
      advancedFeatures: advancedFeaturesList,
      foundationalKnowledge: foundationalKnowledgeList,
      specificKnowledge: specificKnowledgeList,
      implementationSteps: implementationStepsList,
      codeExamples: codeExamplesList,
      // Default empty arrays for removed fields
      potentialChallenges: const [],
      resourcesAndTutorials: const [],
      referenceLinks: referenceLinksList,
      githubLinks: githubLinksList,
    );
  }

  /// Convert a regular Topic to ProjectTopic with sample data
  factory ProjectTopic.fromTopic(Topic topic) {
    return ProjectTopic(
      id: topic.id,
      title: topic.title,
      description: topic.description,
      technologies: topic.technologies,
      difficulty: topic.difficulty,
      problemStatement: "Vấn đề cần giải quyết cho dự án ${topic.title}",
      proposedSolution: "Hướng tiếp cận của dự án: ${topic.description}",
      coreTechStack: topic.technologies,
      matchScore: topic.matchScore,
      duration: topic.duration,
      feasibilityAssessment: topic.feasibilityAssessment,
      coreFeatures: [
        ExpandableItemData(
          title: 'Lập trình Dart cơ bản',
          content: 'Hiểu biết về Dart',
        ),
        ExpandableItemData(title: 'Git cơ bản', content: 'Câu lệnh git cơ bản'),
      ],
      advancedFeatures: [
        ExpandableItemData(
          title: 'Firestore Security Rules',
          content: 'Thiết lập quy tắc bảo mật cho cơ sở dữ liệu',
        ),
        ExpandableItemData(
          title: 'Google Maps SDK',
          content: 'Tích hợp bản đồ và định vị',
        ),
      ],
      foundationalKnowledge: [
        'Lập trình Dart cơ bản',
        'Hiểu biết về API',
        'Git cơ bản',
        'Firebase',
      ],
      specificKnowledge: [
        KnowledgeItem(
          title: 'Firestore Security Rules',
          difficulty: KnowledgeDifficulty.easy,
        ),
        KnowledgeItem(
          title: 'Google Maps SDK',
          difficulty: KnowledgeDifficulty.medium,
        ),
        KnowledgeItem(
          title: 'State Management nâng cao',
          difficulty: KnowledgeDifficulty.hard,
        ),
      ],
      codeExamples: [
        CodeExample(
          title: 'Basic Widget Setup',
          description: 'Khởi tạo widget cơ bản cho dự án',
          code:
              '''class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${topic.title}',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}''',
          language: 'dart',
          explanation:
              'Code này tạo ra widget chính của ứng dụng Flutter với MaterialApp làm root widget.',
        ),
      ],
    );
  }
}
