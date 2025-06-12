import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/dot_indicator.dart';
import '../../routes/app_routes.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button and Demo access
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.h, right: 24.w, left: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Demo access button (for testing)
                      TextButton.icon(
                        onPressed: () => Get.toNamed(Routes.DEMO),
                        icon: Icon(
                          Icons.code,
                          color: AppTheme.primary,
                          size: 16.sp,
                        ),
                        label: Text(
                          'Demo',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Skip button
                      TextButton(
                    onPressed: controller.skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      ),
                    ],
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.onboardingPages.length,
                  itemBuilder: (context, index) {
                    final page = controller.onboardingPages[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(height: 20.h),

                            // Image placeholder với style đẹp
                            Container(
                              width: 300.w,
                              height: 400.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24.r),
                                color: AppTheme.primary.withOpacity(0.1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24.r),
                                child: Image.asset(
                                  page['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                        child: Icon(
                                          Icons.android,
                                          size: 120.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.5),
                                        ),
                                      ),
                                ),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // Title
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                                height: 1,
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Subtitle
                            Text(
                              page['subtitle']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppTheme.secondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom navigation
              Padding(
                padding: EdgeInsets.only(bottom: 26.h, top: 8.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DotIndicator(
                      pageCount: controller.onboardingPages.length,
                      currentPage: controller.currentPage,
                    ),
                    SizedBox(height: 22.h),
                    Obx(() {
                      final isFirst = controller.currentPage.value == 0;
                      final isLast =
                          controller.currentPage.value ==
                          controller.onboardingPages.length - 1;
                      return Center(
                        child: Container(
                          width: 140.w,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.12),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back arrow
                              IconButton(
                                onPressed: isFirst
                                    ? null
                                    : controller.previousPage,
                                icon: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: isFirst
                                      ? AppTheme.secondary.withOpacity(0.3)
                                      : AppTheme.primary,
                                ),
                                splashRadius: 24.r,
                              ),
                              // Next arrow
                              IconButton(
                                onPressed: () {
                                  if (isLast) {
                                    controller.completeOnboarding();
                                  } else {
                                    controller.nextPage();
                                  }
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppTheme.primary,
                                ),
                                splashRadius: 24.r,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
