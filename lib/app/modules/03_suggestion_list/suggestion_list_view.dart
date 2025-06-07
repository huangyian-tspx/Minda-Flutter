import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_view.dart';
import '../../core/widgets/index.dart';
import 'suggestion_list_controller.dart';

class SuggestionListView extends GetView<SuggestionListController> {
  const SuggestionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: Text('suggestion_list_title'.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StyledText('suggestion_list_title'.tr, isMain: true),
              const SizedBox(height: 20),
              
              // Buttons row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.loadSuggestions,
                      child: Text('load_suggestions'.tr),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.searchTopics('AI'),
                      child: const Text('Search AI'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Suggestions list
              Expanded(
                child: Obx(() {
                  final data = controller.suggestionData.value;
                  if (data == null) {
                    return const Center(
                      child: Text('No data available. Please load suggestions.'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: data.topics.length,
                    itemBuilder: (context, index) {
                      final topic = data.topics[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(topic.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(topic.description),
                              const SizedBox(height: 4),
                              Text('Difficulty: ${topic.difficulty}'),
                              Wrap(
                                children: topic.technologies
                                    .map((tech) => Chip(
                                          label: Text(tech),
                                          backgroundColor: Colors.blue.shade100,
                                        ))
                                    .toList(),
                              ),
                            ],
                          ),
                          onTap: () => controller.goToProjectDetail(topic),
                        ),
                      );
                    },
                  );
                }),
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goBackToRefinement,
                child: Text('back_to_refinement'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 