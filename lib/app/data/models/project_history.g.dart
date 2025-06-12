// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectHistory _$ProjectHistoryFromJson(Map<String, dynamic> json) =>
    ProjectHistory(
      id: (json['id'] as num?)?.toInt(),
      projectId: json['projectId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      viewedAt: DateTime.parse(json['viewedAt'] as String),
      projectData: json['projectData'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$ProjectHistoryToJson(ProjectHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'viewedAt': instance.viewedAt.toIso8601String(),
      'projectData': instance.projectData,
      'isFavorite': instance.isFavorite,
    };
