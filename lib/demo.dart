import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_ai_app/app/core/widgets/index.dart';
import 'app/routes/app_routes.dart';
import 'app/core/utils/app_logger.dart';

class DemoScreen extends StatelessWidget {
  final defaultOptions = <String>['Năm 1-2', 'Năm 3', 'Năm cuối'].obs;
  final customOptions = <String>[].obs;
  final selectedOption = ''.obs;
  final currentValue = 3.0.obs;
  final currentStep = 1.obs;
  final textController = TextEditingController();

  DemoScreen({super.key});

  void selectOption(String option) => selectedOption.value = option;
  void addOption(String option) {
    if (option.trim().isEmpty) return;
    if (defaultOptions.contains(option) || customOptions.contains(option))
      return;
    customOptions.add(option);
    selectedOption.value = option;
  }

  void removeOption(String option) {
    customOptions.remove(option);
    if (selectedOption.value == option) selectedOption.value = '';
  }

  void showAddOptionDialog(BuildContext context) {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Thêm lựa chọn'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập lựa chọn mới...'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              addOption(controller.text);
              Get.back();
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.d('DemoScreen build called');
    return Scaffold(
      appBar: AppBar(title: const Text('Demo Widgets')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StyledText('Chọn năm học', isMain: true),
            CustomSegmentedControl(
              defaultOptions: defaultOptions,
              customOptions: customOptions,
              selectedOption: selectedOption,
              onSelect: selectOption,
              onAdd: addOption,
              onRemove: removeOption,
              onShowAddDialog: () => showAddOptionDialog(context),
            ),
            const SizedBox(height: 16),
            StyledText('Chọn thời gian', isMain: true),
            CustomSlider(
              currentValue: currentValue,
              onChanged: (v) => currentValue.value = v,
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomStepIndicator(
                totalSteps: 2,
                currentStep: currentStep.value,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: textController,
              hintText: 'Nhập mô tả...',
            ),
            const SizedBox(height: 16),
            CustomProgressCard(progressValue: 0.6),
            const SizedBox(height: 16),
            StyledText('Tiêu đề chính', isMain: true),
            StyledText('Mô tả nhỏ', isMain: false),
            StyledText(
              'Text custom',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SkeletonProjectCard(),
            const SizedBox(height: 20),
            
            // Navigation buttons
            StyledText('Navigation Test', isMain: true),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.INFORMATION_INPUT),
                  child: const Text('Info Input'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.REFINEMENT),
                  child: const Text('Refinement'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.SUGGESTION_LIST),
                  child: const Text('Suggestions'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.PROJECT_DETAIL, arguments: {'demo': 'data'}),
                  child: const Text('Project Detail'),
                ),
              ],
            ),
            // Nút chuyển đổi ngôn ngữ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Get.updateLocale(const Locale('en', 'US')),
                  child: Text('switch_to_english'.tr),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Get.updateLocale(const Locale('vi', 'VN')),
                  child: Text('switch_to_vietnamese'.tr),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
