import 'package:json_annotation/json_annotation.dart';

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