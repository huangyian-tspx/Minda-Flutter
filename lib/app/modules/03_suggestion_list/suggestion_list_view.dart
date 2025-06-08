import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_ai_app/app/core/values/app_constants.dart';

import '../../core/base/base_view.dart';
import '../../core/values/app_enums.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/suggestion_project_card.dart';
import '../../core/widgets/scroll_to_top_fab.dart';
import '../../data/models/topic_suggestion_model.dart';
import 'suggestion_list_controller.dart';
import 'widgets/animated_filter_tab_bar.dart';

class SuggestionListView extends GetView<SuggestionListController> {
  const SuggestionListView({super.key});

  @override
  Widget build(BuildContext context) {
    final demoTopic = Topic(
      id: 'demo1',
      title: 'Ứng dụng di động Tìm Gia Sư bằng Flutter',
      description:
          'Ứng dụng giúp kết nối học viên và gia sư, tích hợp chat, thanh toán, và quản lý lịch học.',
      technologies: ['Flutter', 'Firebase', 'API', 'Maps API'],
      difficulty: 'An toàn, phù hợp qua môn',
    );
    return BaseView(
      controller: controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: AppConstants.stepTitles[2],
          isWantShowBackButton: true,
          popupActions: const [
            PopupMenuAction.restartFromBeginning,
            PopupMenuAction.settings,
            PopupMenuAction.changeTheme,
            PopupMenuAction.favoriteProjects,
          ],
          onPopupActionSelected: controller.handleAppBarAction,
        ),
        body: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // AnimatedFilterTabBar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: AnimatedFilterTabBar(),
                ),
                // Suggestions list
                Expanded(
                  child: Obx(() {
                    final listToShow = controller.filteredSuggestionList;
                    // if (controller.suggestionData.value == null) {
                    //   return const Center(
                    //     child: Text(
                    //       'No data available. Please load suggestions.',
                    //     ),
                    //   );
                    // }
                    // if (listToShow.isEmpty) {
                    //   return const Center(
                    //     child: Text(
                    //       'Không có đề tài nào phù hợp với bộ lọc này.',
                    //     ),
                    //   );
                    // }
                    return ListView.builder(
                      controller: controller.scrollController, // GẮN SCROLL CONTROLLER
                      itemCount: 3,
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 10),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SuggestionProjectCard(
                            topic: demoTopic,
                            matchScore: 0.95,
                            duration: 3,
                          ),
                        );
                      },
                    );
                  }),
                ),
                // Column(
                //   children: [
                //     SuggestionProjectCard(
                //       topic: demoTopic,
                //       matchScore: 0.95,
                //       duration: 3,
                //     ),
                //     SuggestionProjectCard(
                //       topic: demoTopic,
                //       matchScore: 0.95,
                //       duration: 3,
                //     ),
                //     SuggestionProjectCard(
                //       topic: demoTopic,
                //       matchScore: 0.95,
                //       duration: 3,
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        // THÊM FLOATING ACTION BUTTON
        floatingActionButton: const ScrollToTopFab<SuggestionListController>(),
      ),
    );
  }
}
