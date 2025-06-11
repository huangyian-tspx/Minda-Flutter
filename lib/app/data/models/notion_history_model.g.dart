// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notion_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotionHistoryItem _$NotionHistoryItemFromJson(Map<String, dynamic> json) =>
    NotionHistoryItem(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$NotionHistoryItemToJson(NotionHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'createdAt': instance.createdAt.toIso8601String(),
      'description': instance.description,
    };
