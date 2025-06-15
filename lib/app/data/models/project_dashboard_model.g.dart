// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectDashboardModel _$ProjectDashboardModelFromJson(
  Map<String, dynamic> json,
) => ProjectDashboardModel(
  phases: (json['phases'] as List<dynamic>)
      .map((e) => DashboardPhase.fromJson(e as Map<String, dynamic>))
      .toList(),
  overallProgress: json['overallProgress'] as String,
  teamTips: json['teamTips'] as String,
);

Map<String, dynamic> _$ProjectDashboardModelToJson(
  ProjectDashboardModel instance,
) => <String, dynamic>{
  'phases': instance.phases.map((e) => e.toJson()).toList(),
  'overallProgress': instance.overallProgress,
  'teamTips': instance.teamTips,
};

DashboardPhase _$DashboardPhaseFromJson(Map<String, dynamic> json) =>
    DashboardPhase(
      name: json['name'] as String,
      deliverables: (json['deliverables'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      checklist: (json['checklist'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      tips: json['tips'] as String,
      deadline: json['deadline'] as String,
    );

Map<String, dynamic> _$DashboardPhaseToJson(DashboardPhase instance) =>
    <String, dynamic>{
      'name': instance.name,
      'deliverables': instance.deliverables,
      'checklist': instance.checklist,
      'tips': instance.tips,
      'deadline': instance.deadline,
    };
