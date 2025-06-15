// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_suggestion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopicSuggestionModel _$TopicSuggestionModelFromJson(
  Map<String, dynamic> json,
) => TopicSuggestionModel(
  topics: (json['topics'] as List<dynamic>)
      .map((e) => Topic.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] as String,
  success: json['success'] as bool,
);

Map<String, dynamic> _$TopicSuggestionModelToJson(
  TopicSuggestionModel instance,
) => <String, dynamic>{
  'topics': instance.topics,
  'message': instance.message,
  'success': instance.success,
};

Technology _$TechnologyFromJson(Map<String, dynamic> json) => Technology(
  name: json['name'] as String,
  description: json['description'] as String,
);

Map<String, dynamic> _$TechnologyToJson(Technology instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  technologies: (json['technologies'] as List<dynamic>)
      .map((e) => Technology.fromJson(e as Map<String, dynamic>))
      .toList(),
  difficulty: json['difficulty'] as String,
  matchScore: (json['matchScore'] as num).toInt(),
  duration: (json['duration'] as num).toInt(),
  feasibilityAssessment: json['feasibilityAssessment'] as String,
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'technologies': instance.technologies,
  'difficulty': instance.difficulty,
  'matchScore': instance.matchScore,
  'duration': instance.duration,
  'feasibilityAssessment': instance.feasibilityAssessment,
};

ReferenceLink _$ReferenceLinkFromJson(Map<String, dynamic> json) =>
    ReferenceLink(title: json['title'] as String, url: json['url'] as String);

Map<String, dynamic> _$ReferenceLinkToJson(ReferenceLink instance) =>
    <String, dynamic>{'title': instance.title, 'url': instance.url};
