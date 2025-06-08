import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_enums.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/index.dart';
import 'information_input_controller.dart';

/// Information Input View (Step 1) with beautiful animations and clean UI
/// Features fade-in and slide-up animations for each section
class InformationInputView extends GetView<InformationInputController> {
  const InformationInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      controller: controller,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header with step indicator
              _buildHeader(),

              // Main content with scroll
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),

                      // Level selection section with animation
                      _buildAnimatedSection(
                        delay: 200,
                        child: _buildLevelSection(),
                      ),

                      SizedBox(height: 32.h),

                      // Interests selection section with animation
                      _buildAnimatedSection(
                        delay: 400,
                        child: _buildInterestsSection(),
                      ),

                      SizedBox(height: 32.h),

                      // Main goal selection section with animation
                      _buildAnimatedSection(
                        delay: 600,
                        child: _buildMainGoalSection(),
                      ),

                      SizedBox(height: 32.h),

                      // Technologies selection section with animation
                      _buildAnimatedSection(
                        delay: 800,
                        child: _buildTechnologiesSection(),
                      ),

                      SizedBox(height: 48.h),

                      // Continue button with animation
                      _buildAnimatedSection(
                        delay: 1000,
                        child: _buildContinueButton(),
                      ),

                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with step indicator and title
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppTheme.background,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicator
          CustomStepIndicator(
            totalSteps: 2,
            currentStep: 0, // Step 1 (0-indexed)
          ),

          SizedBox(height: 24.h),

          // Title
          CustomAppBar(
            isWantShowBackButton: false,
            title: AppConstants.stepTitles[0],
            popupActions: const [
              PopupMenuAction.changeTheme,
              PopupMenuAction.changeLanguage,
            ],
            onPopupActionSelected: controller.handleAppBarAction,
          ),
        ],
      ),
    );
  }

  /// Level selection section
  Widget _buildLevelSection() {
    return SectionCard(
      title: AppConstants.sectionCurrentLevel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionLevelDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Level chips
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: AppConstants.userLevels.map((level) {
                final isSelected = controller.isLevelSelected(level);
                return _buildSelectionChip(
                  label: level,
                  isSelected: isSelected,
                  onTap: () => controller.selectLevel(level),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Interests selection section
  Widget _buildInterestsSection() {
    return SectionCard(
      title: AppConstants.sectionInterests,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionInterestsDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Interest chips
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: AppConstants.interests.map((interest) {
                final isSelected = controller.isInterestSelected(interest);
                return _buildSelectionChip(
                  label: interest,
                  isSelected: isSelected,
                  onTap: () => controller.toggleInterest(interest),
                );
              }).toList(),
            ),
          ),

          // Selection count feedback
          SizedBox(height: 16.h),
          Obx(
            () => Text(
              'Đã chọn: ${controller.selectedInterestsCount} lĩnh vực',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.secondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Main goal selection section (segmented control style)
  Widget _buildMainGoalSection() {
    return SectionCard(
      title: AppConstants.sectionMainGoal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionMainGoalDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Main goal options
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                // Default main goals
                ...AppConstants.mainGoals.map((goal) {
                  final isSelected = controller.isMainGoalSelected(goal);
                  return _buildSelectionChip(
                    label: goal,
                    isSelected: isSelected,
                    onTap: () => controller.selectMainGoal(goal),
                  );
                }),

                // Custom main goals with delete option
                ...controller.collectionService.customMainGoals.map((goal) {
                  final isSelected = controller.isMainGoalSelected(goal);
                  return _buildSelectionChip(
                    label: goal,
                    isSelected: isSelected,
                    onTap: () => controller.selectMainGoal(goal),
                    isCustom: true,
                    onDelete: () => controller.removeCustomMainGoal(goal),
                  );
                }),

                // Add other button
                _buildAddOtherChip(onTap: controller.showAddMainGoalDialog),
              ],
            ),
          ),

          // Selection feedback
          SizedBox(height: 16.h),
          Obx(
            () => Text(
              controller.hasSelectedMainGoal
                  ? 'Đã chọn mục tiêu'
                  : 'Chưa chọn mục tiêu',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.secondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Technologies selection section (chip style)
  Widget _buildTechnologiesSection() {
    return SectionCard(
      title: AppConstants.sectionTechnologies,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionTechnologiesDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Technology chips
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                // Default technologies
                ...AppConstants.technologies.map((tech) {
                  final isSelected = controller.isTechnologySelected(tech);
                  return _buildSelectionChip(
                    label: tech,
                    isSelected: isSelected,
                    onTap: () => controller.toggleTechnology(tech),
                  );
                }),

                // Custom technologies with delete option
                ...controller.collectionService.customTechnologies.map((tech) {
                  final isSelected = controller.isTechnologySelected(tech);
                  return _buildSelectionChip(
                    label: tech,
                    isSelected: isSelected,
                    onTap: () => controller.toggleTechnology(tech),
                    isCustom: true,
                    onDelete: () => controller.removeCustomTechnology(tech),
                  );
                }),

                // Add other button
                _buildAddOtherChip(onTap: controller.showAddTechnologyDialog),
              ],
            ),
          ),

          // Selection count feedback
          SizedBox(height: 16.h),
          Obx(
            () => Text(
              'Đã chọn: ${controller.selectedTechnologiesCount} công nghệ',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.secondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom selection chip with theme styling
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool isCustom = false,
    VoidCallback? onDelete,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.chipInactive,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: AppTheme.primary, width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isCustom && onDelete != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      size: 16.sp,
                      color: isSelected
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.secondary.withOpacity(0.7),
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppTheme.primary,
                ),
              ),
      ),
    );
  }

  /// Continue button with validation state
  Widget _buildContinueButton() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: controller.canProceed
              ? controller.navigateToRefinement
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            disabledBackgroundColor: AppTheme.secondary.withOpacity(0.3),
            foregroundColor: Colors.white,
            elevation: controller.canProceed ? 3 : 0,
            shadowColor: AppTheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Text(
            AppConstants.buttonContinueAndRefine,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// Wrapper for fade-in + slide-up animation
  Widget _buildAnimatedSection({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  /// Add other button
  Widget _buildAddOtherChip({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.chipInactive,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 16.sp, color: AppTheme.primary),
            SizedBox(width: 6.w),
            Text(
              'Thêm khác',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
