import 'package:json_annotation/json_annotation.dart';

part 'project_dashboard_model.g.dart';

@JsonSerializable(explicitToJson: true)
class ProjectDashboardModel {
  final List<DashboardPhase> phases;
  final String overallProgress;
  final String teamTips;

  ProjectDashboardModel({
    required this.phases,
    required this.overallProgress,
    required this.teamTips,
  });

  factory ProjectDashboardModel.fromJson(Map<String, dynamic> json) => _$ProjectDashboardModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectDashboardModelToJson(this);
}

@JsonSerializable()
class DashboardPhase {
  final String name;
  final List<String> deliverables;
  final List<String> checklist;
  final String tips;
  final String deadline;

  DashboardPhase({
    required this.name,
    required this.deliverables,
    required this.checklist,
    required this.tips,
    required this.deadline,
  });

  factory DashboardPhase.fromJson(Map<String, dynamic> json) => _$DashboardPhaseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardPhaseToJson(this);
}
