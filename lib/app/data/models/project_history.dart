import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'package:mind_ai_app/app/data/models/topic_suggestion_model.dart';
import '../../core/utils/app_logger.dart';
import '../../core/widgets/code_viewer.dart';
import '../../modules/04_project_detail/expandable_item_data.dart';
import '../models/knowledge_item.dart';

part 'project_history.g.dart';

@JsonSerializable()
class ProjectHistory {
  final int? id;
  final String projectId;
  final String title;
  final String description;
  final String category; // 'safe' or 'challenging'
  final DateTime viewedAt;
  final String projectData; // JSON string of ProjectTopic
  final bool isFavorite;

  ProjectHistory({
    this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.category,
    required this.viewedAt,
    required this.projectData,
    this.isFavorite = false,
  });

  factory ProjectHistory.fromJson(Map<String, dynamic> json) =>
      _$ProjectHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectHistoryToJson(this);

  // Convert to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'category': category,
      'viewedAt': viewedAt.toIso8601String(),
      'projectData': projectData,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  // Create from SQLite Map
  factory ProjectHistory.fromMap(Map<String, dynamic> map) {
    return ProjectHistory(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      viewedAt: DateTime.parse(map['viewedAt']),
      projectData: map['projectData'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  // Create from ProjectTopic
  factory ProjectHistory.fromProjectTopic(ProjectTopic topic, String category) {
    return ProjectHistory(
      projectId: '${topic.title}_${DateTime.now().millisecondsSinceEpoch}',
      title: topic.title,
      description: topic.description,
      category: category,
      viewedAt: DateTime.now(),
      projectData: jsonEncode(topic.toJson()),
    );
  }

  // Get ProjectTopic from stored data - SỬA LẠI ĐỂ PARSE ĐÚNG FORMAT
  ProjectTopic get projectTopic {
    try {
      AppLogger.d("Parsing project data for: $title");
      if (projectData.isEmpty) {
        AppLogger.e("Project data is empty for: $title");
        return _createFallbackProjectTopic();
      }
      final Map<String, dynamic> json = jsonDecode(projectData);
      // Parse coreTechStack
      final coreTechStackList = <Technology>[];
      final techStackData = json['coreTechStack'];
      if (techStackData is List) {
        for (final item in techStackData) {
          if (item is Map<String, dynamic>) {
            coreTechStackList.add(
              Technology(
                name: item['name']?.toString() ?? '',
                description: item['description']?.toString() ?? '',
              ),
            );
          }
        }
      }
      // Parse coreFeatures
      final coreFeaturesList = <ExpandableItemData>[];
      final coreFeaturesData = json['coreFeatures'];
      if (coreFeaturesData is List) {
        for (final item in coreFeaturesData) {
          if (item is Map<String, dynamic>) {
            coreFeaturesList.add(
              ExpandableItemData(
                title: item['title']?.toString() ?? '',
                content: item['content']?.toString() ?? '',
              ),
            );
          }
        }
      }
      // Parse advancedFeatures
      final advancedFeaturesList = <ExpandableItemData>[];
      final advancedFeaturesData = json['advancedFeatures'];
      if (advancedFeaturesData is List) {
        for (final item in advancedFeaturesData) {
          if (item is Map<String, dynamic>) {
            advancedFeaturesList.add(
              ExpandableItemData(
                title: item['title']?.toString() ?? '',
                content: item['content']?.toString() ?? '',
              ),
            );
          }
        }
      }
      // Parse foundationalKnowledge
      final foundationalKnowledgeList = <String>[];
      final foundationalData = json['foundationalKnowledge'];
      if (foundationalData is List) {
        for (final item in foundationalData) {
          foundationalKnowledgeList.add(item?.toString() ?? '');
        }
      }
      // Parse specificKnowledge
      final specificKnowledgeList = <KnowledgeItem>[];
      final specificData = json['specificKnowledge'];
      if (specificData is List) {
        for (final item in specificData) {
          if (item is Map<String, dynamic>) {
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
            specificKnowledgeList.add(
              KnowledgeItem(
                title: item['title']?.toString() ?? '',
                difficulty: difficulty,
              ),
            );
          }
        }
      }
      // Parse implementationSteps
      final implementationStepsList = <String>[];
      final implementationData = json['implementationSteps'];
      if (implementationData is List) {
        for (final item in implementationData) {
          implementationStepsList.add(item?.toString() ?? '');
        }
      }
      // Parse codeExamples
      final codeExamplesList = <CodeExample>[];
      final codeExamplesData = json['codeExamples'];
      if (codeExamplesData is List) {
        for (final item in codeExamplesData) {
          if (item is Map<String, dynamic>) {
            codeExamplesList.add(
              CodeExample(
                title: item['title']?.toString() ?? '',
                description:
                    item['description']?.toString() ??
                    item['explanation']?.toString() ??
                    '',
                code: item['code']?.toString() ?? '',
                language: item['language']?.toString() ?? 'dart',
                explanation: item['explanation']?.toString() ?? '',
              ),
            );
          }
        }
      }
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
      // Create basic Topic first
      final basicTopic = Topic(
        id: json['id']?.toString() ?? projectId,
        title: json['title']?.toString() ?? title,
        description: json['description']?.toString() ?? description,
        technologies: coreTechStackList,
        difficulty: category,
        matchScore: 100,
        duration: 3,
        feasibilityAssessment: 'Đã được lưu từ lịch sử',
      );
      // Create ProjectTopic
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
            "Vấn đề cần giải quyết cho dự án $title",
        proposedSolution:
            json['proposedSolution']?.toString() ??
            "Hướng tiếp cận của dự án: $description",
        coreTechStack: coreTechStackList,
        coreFeatures: coreFeaturesList,
        advancedFeatures: advancedFeaturesList,
        foundationalKnowledge: foundationalKnowledgeList,
        specificKnowledge: specificKnowledgeList,
        implementationSteps: implementationStepsList,
        codeExamples: codeExamplesList,
        referenceLinks: referenceLinksList,
        githubLinks: githubLinksList,
        potentialChallenges: const [],
        resourcesAndTutorials: const [],
      );
    } catch (e) {
      AppLogger.e("Error parsing project data for $title: $e");
      AppLogger.e("Project data content: $projectData");
      return _createFallbackProjectTopic();
    }
  }

  /// Create fallback ProjectTopic when parsing fails
  ProjectTopic _createFallbackProjectTopic() {
    final basicTopic = Topic(
      id: projectId,
      title: title,
      description: description,
      technologies: [],
      difficulty: category,
      matchScore: 100,
      duration: 3,
      feasibilityAssessment: 'Fallback data - có lỗi khi parse data gốc',
    );

    return ProjectTopic.fromTopic(basicTopic);
  }

  ProjectHistory copyWith({
    int? id,
    String? projectId,
    String? title,
    String? description,
    String? category,
    DateTime? viewedAt,
    String? projectData,
    bool? isFavorite,
  }) {
    return ProjectHistory(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      viewedAt: viewedAt ?? this.viewedAt,
      projectData: projectData ?? this.projectData,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
