import 'package:json_annotation/json_annotation.dart';
import 'topic_suggestion_model.dart';

part 'ai_response_model.g.dart';

/// Wrapper cho response từ OpenRouter API
@JsonSerializable()
class AIProjectResponse {
  @JsonKey(name: 'safeProjects')
  final List<Topic> safeProjects;
  
  @JsonKey(name: 'challengingProjects') 
  final List<Topic> challengingProjects;

  AIProjectResponse({
    required this.safeProjects,
    required this.challengingProjects,
  });

  factory AIProjectResponse.fromJson(Map<String, dynamic> json) =>
      _$AIProjectResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AIProjectResponseToJson(this);

  /// Convert to TopicSuggestionModel với tất cả topics
  TopicSuggestionModel toTopicSuggestionModel() {
    final allTopics = [...safeProjects, ...challengingProjects];
    return TopicSuggestionModel(
      topics: allTopics,
      message: "Đã tạo ${allTopics.length} đề xuất dự án thành công",
      success: true,
    );
  }

  /// Get only safe projects as TopicSuggestionModel
  TopicSuggestionModel getSafeProjectsOnly() {
    return TopicSuggestionModel(
      topics: safeProjects,
      message: "Đề xuất ${safeProjects.length} dự án an toàn",
      success: true,
    );
  }

  /// Get only challenging projects as TopicSuggestionModel
  TopicSuggestionModel getChallengingProjectsOnly() {
    return TopicSuggestionModel(
      topics: challengingProjects,
      message: "Đề xuất ${challengingProjects.length} dự án thử thách", 
      success: true,
    );
  }
}

/// Response từ OpenRouter API
@JsonSerializable()
class OpenRouterResponse {
  final String id;
  final String object;
  final int created;
  final String model;
  final List<OpenRouterChoice> choices;
  final OpenRouterUsage usage;

  OpenRouterResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory OpenRouterResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterResponseToJson(this);

  /// Lấy nội dung AI trả về
  String get content => choices.isNotEmpty ? choices.first.message.content : '';
}

@JsonSerializable()
class OpenRouterChoice {
  final int index;
  final OpenRouterMessage message;
  @JsonKey(name: 'finish_reason')
  final String finishReason;

  OpenRouterChoice({
    required this.index,
    required this.message,
    required this.finishReason,
  });

  factory OpenRouterChoice.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterChoiceFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterChoiceToJson(this);
}

@JsonSerializable()
class OpenRouterMessage {
  final String role;
  final String content;

  OpenRouterMessage({
    required this.role,
    required this.content,
  });

  factory OpenRouterMessage.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterMessageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterMessageToJson(this);
}

@JsonSerializable()
class OpenRouterUsage {
  @JsonKey(name: 'prompt_tokens')
  final int promptTokens;
  @JsonKey(name: 'completion_tokens')
  final int completionTokens;
  @JsonKey(name: 'total_tokens')
  final int totalTokens;

  OpenRouterUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory OpenRouterUsage.fromJson(Map<String, dynamic> json) =>
      _$OpenRouterUsageFromJson(json);

  Map<String, dynamic> toJson() => _$OpenRouterUsageToJson(this);
} 