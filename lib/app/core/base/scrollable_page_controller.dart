import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './base_controller.dart';

// --- Customisation Point ---
// BA có thể yêu cầu thay đổi khoảng cách cuộn để nút xuất hiện
const double _showButtonOffset = 400.0;

class ScrollablePageController extends BaseController {
  late final ScrollController scrollController;
  final showScrollToTopButton = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset >= _showButtonOffset && !showScrollToTopButton.value) {
      showScrollToTopButton.value = true;
    } else if (scrollController.offset < _showButtonOffset && showScrollToTopButton.value) {
      showScrollToTopButton.value = false;
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500), // Tốc độ cuộn
      curve: Curves.easeInOut, // Hiệu ứng cuộn
    );
  }

  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
} 