import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_view.dart';
import '../../core/widgets/index.dart';
import '../../core/widgets/animated_expandable_list.dart';
import '../../core/widgets/scroll_to_top_fab.dart';
import 'expandable_list_controller.dart';
import 'project_detail_controller.dart';
import '../../core/widgets/suggestion_project_card.dart';
import '../../data/models/topic_suggestion_model.dart';
import '../../modules/03_suggestion_list/suggestion_list_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller for expandable list demo
    final expandableListController = Get.put(ExpandableListController(), permanent: true);
    // Inject SuggestionListController for SuggestionProjectCard demo
    final suggestionListController = Get.put(SuggestionListController());

    // Sample topic for demo
    final demoTopic = Topic(
      id: 'demo1',
      title: 'Ứng dụng di động Tìm Gia Sư bằng Flutter',
      description: 'Ứng dụng giúp kết nối học viên và gia sư, tích hợp chat, thanh toán, và quản lý lịch học.',
      technologies: ['Flutter', 'Firebase', 'API', 'Maps API'],
      difficulty: 'An toàn, phù hợp qua môn',
    );

    return BaseView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Project Detail'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: controller.scrollController, // GẮN SCROLL CONTROLLER
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
                const SizedBox(height: 32),
                // --- SuggestionProjectCard Demo Section ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Demo SuggestionProjectCard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SuggestionProjectCard(
                          topic: demoTopic,
                          matchScore: 0.95,
                          duration: 3,
                        ),
                        // Decorative gap/section between tech and duration
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1.2,
                                  endIndent: 8,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.blueGrey[100]!, width: 1),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.info_outline, size: 18, color: Colors.blueGrey),
                                    SizedBox(width: 6),
                                    Text('Thông tin dự án', style: TextStyle(fontSize: 13, color: Colors.blueGrey)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey[300],
                                  thickness: 1.2,
                                  indent: 8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Section: Các Tính Năng Cần Xây Dựng
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Các Tính Năng Cần Xây Dựng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // AnimatedExpandableList demo
                AnimatedExpandableList(
                  items: controller.featureItems,
                  controller: expandableListController,
                ),
              ],
            ),
          ),
        ),
        // THÊM FLOATING ACTION BUTTON
        floatingActionButton: const ScrollToTopFab<ProjectDetailController>(),
      ),
    );
  }
} 