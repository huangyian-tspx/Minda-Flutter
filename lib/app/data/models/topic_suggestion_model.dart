import 'package:json_annotation/json_annotation.dart';

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
class Topic {
  final String id;
  final String title;
  final String description;
  final List<String> technologies;
  final String difficulty;

  Topic({
    required this.id,
    required this.title,
    required this.description,
    required this.technologies,
    required this.difficulty,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);

  Map<String, dynamic> toJson() => _$TopicToJson(this);
}

/// Extended version of Topic for detailed project view
class ProjectTopic extends Topic {
  final String problemStatement;
  final String proposedSolution;
  final List<String> coreTechStack;
  final List<ExpandableItemData> coreFeatures;
  final List<ExpandableItemData> advancedFeatures;
  final List<String> foundationalKnowledge;
  final List<KnowledgeItem> specificKnowledge;

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
  });

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
    );
  }
}
