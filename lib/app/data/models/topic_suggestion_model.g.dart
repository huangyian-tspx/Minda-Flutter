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

Topic _$TopicFromJson(Map<String, dynamic> json) => Topic(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  technologies: (json['technologies'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  difficulty: json['difficulty'] as String,
);

Map<String, dynamic> _$TopicToJson(Topic instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'technologies': instance.technologies,
  'difficulty': instance.difficulty,
};
