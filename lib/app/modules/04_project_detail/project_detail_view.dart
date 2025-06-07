import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_view.dart';
import '../../core/widgets/index.dart';
import 'project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Project Detail'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StyledText('project_detail_title'.tr, isMain: true),
              const SizedBox(height: 20),
              if (controller.projectData != null)
                StyledText('Project: \\${controller.projectData}', isMain: false),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.loadProjectDetails,
                child: Text('load_project_details'.tr),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goBackToSuggestionList,
                child: Text('back_to_suggestion_list'.tr),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goToHomePage,
                child: Text('go_to_home_page'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 