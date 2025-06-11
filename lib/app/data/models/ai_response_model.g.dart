// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AIProjectResponse _$AIProjectResponseFromJson(Map<String, dynamic> json) =>
    AIProjectResponse(
      safeProjects: (json['safeProjects'] as List<dynamic>)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
      challengingProjects: (json['challengingProjects'] as List<dynamic>)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AIProjectResponseToJson(AIProjectResponse instance) =>
    <String, dynamic>{
      'safeProjects': instance.safeProjects,
      'challengingProjects': instance.challengingProjects,
    };

OpenRouterResponse _$OpenRouterResponseFromJson(Map<String, dynamic> json) =>
    OpenRouterResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => OpenRouterChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: OpenRouterUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenRouterResponseToJson(OpenRouterResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices,
      'usage': instance.usage,
    };

OpenRouterChoice _$OpenRouterChoiceFromJson(Map<String, dynamic> json) =>
    OpenRouterChoice(
      index: (json['index'] as num).toInt(),
      message: OpenRouterMessage.fromJson(
        json['message'] as Map<String, dynamic>,
      ),
      finishReason: json['finish_reason'] as String,
    );

Map<String, dynamic> _$OpenRouterChoiceToJson(OpenRouterChoice instance) =>
    <String, dynamic>{
      'index': instance.index,
      'message': instance.message,
      'finish_reason': instance.finishReason,
    };

OpenRouterMessage _$OpenRouterMessageFromJson(Map<String, dynamic> json) =>
    OpenRouterMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$OpenRouterMessageToJson(OpenRouterMessage instance) =>
    <String, dynamic>{'role': instance.role, 'content': instance.content};

OpenRouterUsage _$OpenRouterUsageFromJson(Map<String, dynamic> json) =>
    OpenRouterUsage(
      promptTokens: (json['prompt_tokens'] as num).toInt(),
      completionTokens: (json['completion_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
    );

Map<String, dynamic> _$OpenRouterUsageToJson(OpenRouterUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'completion_tokens': instance.completionTokens,
      'total_tokens': instance.totalTokens,
    };
