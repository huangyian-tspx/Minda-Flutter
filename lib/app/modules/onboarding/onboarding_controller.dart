import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/local_storage_service.dart';
import '../../di.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends BaseController {
  final _localStorage = sl<LocalStorageService>();
  final pageController = PageController();
  final currentPage = 0.obs;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding_01.png',
      'title': 'AI x Graduation\nStart With a Brilliant Idea',
      'subtitle':
          'Khơi nguồn sáng tạo từ AI\nCùng bạn định hình đề tài độc nhất',
    },
    {
      'image': 'assets/images/onboarding_02.png',
      'title': 'Tailored Topics\nFor Every Tech Passion',
      'subtitle':
          'Chọn công nghệ bạn yêu thích\nAI sẽ gợi ý đề tài phù hợp & thực tế',
    },
    {
      'image': 'assets/images/onboarding_03.png',
      'title': 'From Idea to Demo\nAI Has Your Back',
      'subtitle':
          'Tối ưu thời gian, tăng tốc hoàn thành\nVới trợ lý AI đồng hành cùng bạn',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      currentPage.value = pageController.page?.round() ?? 0;
    });
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  void completeOnboarding() async {
    AppLogger.d("Completing onboarding");
    await _localStorage.saveData<bool>('has_seen_onboarding', true);
    Get.offAllNamed(Routes.INFORMATION_INPUT);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
