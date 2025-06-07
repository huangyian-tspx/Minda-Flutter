import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_view.dart';
import '../../core/widgets/index.dart';
import 'refinement_controller.dart';

class RefinementView extends GetView<RefinementController> {
  const RefinementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Refinement'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StyledText('refinement_title'.tr, isMain: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goToSuggestionList,
                child: Text('go_to_suggestion_list'.tr),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goBackToInput,
                child: Text('back_to_input'.tr),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.startOver,
                child: Text('start_over'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 