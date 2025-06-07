// lib/app/data/models/project_detail_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'project_detail_model.g.dart';

@JsonSerializable()
class ProjectDetailModel {
  final String id;
  final String name;
  final String description;
  // ... các trường khác

  ProjectDetailModel({
    required this.id,
    required this.name,
    required this.description,
    // ... các trường khác
  });

  factory ProjectDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectDetailModelToJson(this);
}
