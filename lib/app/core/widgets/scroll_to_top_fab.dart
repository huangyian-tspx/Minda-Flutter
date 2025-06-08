import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_ai_app/app/core/theme/app_theme.dart';

import '../base/scrollable_page_controller.dart';

class ScrollToTopFab<T extends ScrollablePageController> extends GetView<T> {
  const ScrollToTopFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: controller.showScrollToTopButton.value ? 1.0 : 0.0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: controller.showScrollToTopButton.value
              ? Offset.zero
              : const Offset(0, 2), // Hiệu ứng trượt từ dưới lên
          child: FloatingActionButton(
            onPressed: controller.showScrollToTopButton.value
                ? controller.scrollToTop
                : null, // Disable onPressed when hidden for better UX
            backgroundColor: AppTheme.primary,
            shape: CircleBorder(
              side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
            ),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
