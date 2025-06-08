import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../core/base/base_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/values/app_constants.dart';
import 'ai_thinking_controller.dart';

/// AI Thinking Screen with beautiful Lottie animation
/// Shows dynamic text while API processing is happening in background
class AIThinkingView extends GetView<AIThinkingController> {
  const AIThinkingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content up a bit
                  const Spacer(flex: 2),
                  
                  // Main content
                  _buildMainContent(),
                  
                  // Bottom spacer
                  const Spacer(flex: 3),
                  
                  // Subtle hint text
                  _buildHintText(),
                  
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Main content with Lottie animation and dynamic text
  Widget _buildMainContent() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Opacity(
            opacity: value,
            child: Column(
              children: [
                // Lottie Animation with enhanced styling
                Container(
                  width: 280.w,
                  height: 280.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(140.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.1),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(140.r),
                    child: Lottie.asset(
                      'assets/lot/lot_thinking.json',
                      width: 280.w,
                      height: 280.h,
                      fit: BoxFit.cover,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                ),
                
                SizedBox(height: 48.h),
                
                // Dynamic thinking text with fade animation
                SizedBox(
                  height: 60.h, // Fixed height to prevent layout jumping
                  child: Center(
                    child: Obx(() => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: animation.drive(
                              Tween<Offset>(
                                begin: const Offset(0.0, 0.3),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeOut)),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        controller.thinkingText.value,
                        key: ValueKey<String>(controller.thinkingText.value),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                          height: 1.4,
                        ),
                      ),
                    )),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Animated dots indicator
                _buildDotsIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Animated dots to show progress
  Widget _buildDotsIndicator() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (value - delay).clamp(0.0, 1.0);
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.3 + (0.7 * animationValue)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  /// Subtle hint text at bottom
  Widget _buildHintText() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOut,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Text(
            AppConstants.aiProcessingHint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary.withOpacity(0.8),
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      },
    );
  }
} 