import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_view.dart';
import '../../core/widgets/index.dart';
import 'information_input_controller.dart';

class InformationInputView extends GetView<InformationInputController> {
  const InformationInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Information Input'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              StyledText('input_info_title'.tr, isMain: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.fetchData,
                child: Text('fetch_data'.tr),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.goToRefinement,
                child: Text('go_to_refinement'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 