import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../di.dart';
import '../../data/services/local_storage_service.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/app_logger.dart';

class OnboardingController extends BaseController {
  final _localStorage = sl<LocalStorageService>();
  final pageController = PageController();
  final currentPage = 0.obs;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding_01.png',
      'title': 'Unlock the Power\nOf Future AI',
      'subtitle': 'Chat with the smartest AI Future\nExperience power of AI with us'
    },
    {
      'image': 'assets/images/onboarding_02.png',
      'title': 'Chat With Your\nFavourite Ai',
      'subtitle': 'Chat with the smartest AI Future\nExperience power of AI with us'
    },
    {
      'image': 'assets/images/onboarding_03.png',
      'title': 'Boost Your Mind\nPower with Ai',
      'subtitle': 'Chat with the smartest AI Future\nExperience power of AI with us'
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