import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/base/base_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_enums.dart';
import '../../core/widgets/index.dart';
import 'refinement_controller.dart';

/// Refinement View (Step 2) with beautiful animations and comprehensive data collection
/// Features project scale, product types, and detailed text inputs
class RefinementView extends GetView<RefinementController> {
  const RefinementView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: BaseView(
        controller: controller,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header with step indicator and title
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

                        // Project scale section with animation
                        _buildAnimatedSection(
                          delay: 200,
                          child: _buildProjectScaleSection(context),
                        ),

                        SizedBox(height: 32.h),

                        // Product type section with animation
                        _buildAnimatedSection(
                          delay: 400,
                          child: _buildProductTypeSection(),
                        ),

                        SizedBox(height: 32.h),

                        // Team size section with animation - NEW SECTION
                        _buildAnimatedSection(
                          delay: 500,
                          child: _buildTeamSizeSection(),
                        ),

                        SizedBox(height: 32.h),

                        // Special requirements section with animation
                        _buildAnimatedSection(
                          delay: 600,
                          child: _buildSpecialRequirementsSection(),
                        ),

                        SizedBox(height: 32.h),

                        // Problem to solve section with animation
                        _buildAnimatedSection(
                          delay: 800,
                          child: _buildProblemToSolveSection(),
                        ),

                        SizedBox(height: 48.h),

                        // Generate suggestions button with animation
                        _buildAnimatedSection(
                          delay: 1000,
                          child: _buildGenerateButton(),
                        ),

                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: const GlobalFloatingMenu(),
        ),
      ),
    );
  }

  /// App bar with back button
  // PreferredSizeWidget _buildAppBar(BuildContext context) {
  //   return AppBar(
  //     backgroundColor: AppTheme.background,
  //     elevation: 0,
  //     leading: IconButton(
  //       icon: Icon(Icons.arrow_back_ios, color: AppTheme.primary, size: 20.sp),
  //       onPressed: controller.goBack,
  //     ),
  //     systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
  //   );
  // }

  /// Header with step indicator and title
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
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
            currentStep: 1, // Step 2 (0-indexed)
          ),

          SizedBox(height: 24.h),
          CustomAppBar(
            isWantShowBackButton: true,
            title: AppConstants.refinementTitle,
            popupActions: const [
              PopupMenuAction.changeTheme,
              PopupMenuAction.changeLanguage,
            ],
            onPopupActionSelected: controller.handleAppBarAction,
          ),
          // Title
          // Text(
          //   AppConstants.refinementTitle,
          //   style: TextStyle(
          //     fontSize: 24.sp,
          //     fontWeight: FontWeight.bold,
          //     color: AppTheme.primary,
          //   ),
          // ),
          //
          // SizedBox(height: 8.h),
          //
          // // Subtitle
          // Text(
          //   AppConstants.refinementSubtitle,
          //   style: TextStyle(
          //     fontSize: 14.sp,
          //     color: AppTheme.secondary,
          //     height: 1.4,
          //   ),
          //   textAlign: TextAlign.center,
          // ),
        ],
      ),
    );
  }

  /// Project scale section with slider
  Widget _buildProjectScaleSection(BuildContext context) {
    return SectionCard(
      title: AppConstants.sectionProjectScale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionProjectScaleDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 24.h),

          // Custom slider with enhanced design
          Obx(
            () => Column(
              children: [
                // Duration display
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${controller.currentProjectDuration.toInt()}m',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.primary,
                    inactiveTrackColor: AppTheme.secondary.withOpacity(0.3),
                    thumbColor: AppTheme.primary,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.r),
                    overlayColor: AppTheme.primary.withOpacity(0.1),
                    trackHeight: 4.h,
                  ),
                  child: Slider(
                    value: controller.currentProjectDuration,
                    min: 1.0,
                    max: 12.0,
                    divisions: 11,
                    onChanged: controller.updateProjectDuration,
                  ),
                ),

                SizedBox(height: 8.h),

                // Duration labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: AppConstants.projectDurationLabels
                      .map(
                        (label) => Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.secondary,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Product type selection section
  Widget _buildProductTypeSection() {
    return SectionCard(
      title: AppConstants.sectionProductType,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionProductTypeDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Product type chips
          Obx(
            () => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                // Default product types
                ...AppConstants.productTypes.map((productType) {
                  final isSelected = controller.isProductTypeSelected(
                    productType,
                  );
                  return _buildSelectionChip(
                    label: productType,
                    isSelected: isSelected,
                    onTap: () => controller.toggleProductType(productType),
                  );
                }),

                // Custom product types with delete option
                ...controller.collectionService.customProductTypes.map((
                  productType,
                ) {
                  final isSelected = controller.isProductTypeSelected(
                    productType,
                  );
                  return _buildSelectionChip(
                    label: productType,
                    isSelected: isSelected,
                    onTap: () => controller.toggleProductType(productType),
                    isCustom: true,
                    onDelete: () =>
                        controller.removeCustomProductType(productType),
                  );
                }),

                // Add other button
                _buildAddOtherChip(onTap: controller.showAddProductTypeDialog),
              ],
            ),
          ),

          // Selection count feedback
          SizedBox(height: 16.h),
          Obx(
            () => Text(
              'Đã chọn: ${controller.selectedProductTypesCount} loại hình',
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

  /// Team size section
  Widget _buildTeamSizeSection() {
    return SectionCard(
      title: AppConstants.sectionTeamSize,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionTeamSizeDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 24.h),

          // Team size controls with increment/decrement buttons
          Obx(
            () => Column(
              children: [
                // Team size display with description
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppTheme.primary, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${controller.currentTeamSize} thành viên',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        controller.teamSizeDescription,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Increment/Decrement buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Decrement button
                    GestureDetector(
                      onTap: controller.canDecrementTeamSize
                          ? controller.decrementTeamSize
                          : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: controller.canDecrementTeamSize
                              ? AppTheme.primary
                              : AppTheme.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: controller.canDecrementTeamSize
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),

                    SizedBox(width: 24.w),

                    // Current team size display
                    Container(
                      width: 80.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: Center(
                        child: Text(
                          '${controller.currentTeamSize}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 24.w),

                    // Increment button
                    GestureDetector(
                      onTap: controller.canIncrementTeamSize
                          ? controller.incrementTeamSize
                          : null,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: controller.canIncrementTeamSize
                              ? AppTheme.primary
                              : AppTheme.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: controller.canIncrementTeamSize
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Team context hints
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppTheme.chipInactive,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gợi ý theo quy mô:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      if (controller.isSoloProject)
                        Text(
                          '• Tập trung vào tính năng cốt lõi\n• Quản lý thời gian hiệu quả\n• Sử dụng công cụ hỗ trợ tự động',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.secondary,
                            height: 1.3,
                          ),
                        )
                      else if (controller.isSmallTeam)
                        Text(
                          '• Phân chia vai trò rõ ràng\n• Sử dụng git để quản lý code\n• Tích hợp và test thường xuyên',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.secondary,
                            height: 1.3,
                          ),
                        )
                      else
                        Text(
                          '• Cần project manager\n• Sử dụng các công cụ quản lý dự án\n• Tập trung vào communication',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppTheme.secondary,
                            height: 1.3,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Special requirements section
  Widget _buildSpecialRequirementsSection() {
    return SectionCard(
      title: AppConstants.sectionSpecialRequirements,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionSpecialRequirementsDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Enhanced text field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.chipInactive),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.specialReqController,
              maxLines: 4,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppConstants.hintSpecialRequirements,
                hintStyle: TextStyle(
                  color: AppTheme.secondary.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Problem to solve section
  Widget _buildProblemToSolveSection() {
    return SectionCard(
      title: AppConstants.sectionProblemToSolve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppConstants.sectionProblemToSolveDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.secondary,
              height: 1.4,
            ),
          ),

          SizedBox(height: 16.h),

          // Enhanced text field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppTheme.chipInactive),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller.problemController,
              maxLines: 5,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppConstants.hintProblemToSolve,
                hintStyle: TextStyle(
                  color: AppTheme.secondary.withOpacity(0.6),
                  fontSize: 14.sp,
                ),
                contentPadding: EdgeInsets.all(16.w),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate suggestions button
  Widget _buildGenerateButton() {
    return Obx(
      () => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: controller.canProceed
              ? controller.submitAndGenerate
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            disabledBackgroundColor: AppTheme.secondary.withOpacity(0.3),
            foregroundColor: Colors.white,
            elevation: controller.canProceed ? 6 : 0,
            shadowColor: AppTheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.canProceed) ...[
                Icon(Icons.auto_awesome, size: 20.sp, color: Colors.white),
                SizedBox(width: 8.w),
              ],
              Text(
                AppConstants.buttonGenerateSuggestions,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
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
}
