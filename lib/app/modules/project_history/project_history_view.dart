import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../core/base/base_view.dart';
import '../../core/theme/app_theme.dart';
import '../../core/values/app_enums.dart';
import '../../core/values/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/global_floating_menu.dart';
import '../../data/models/project_history.dart';
import 'project_history_controller.dart';

class ProjectHistoryView extends GetView<ProjectHistoryController> {
  const ProjectHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<ProjectHistoryController>(
      controller: ProjectHistoryController(),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              CustomAppBar(
                title: 'Lịch sử dự án',
                isWantShowBackButton: true,
                popupActions: const [
                  PopupMenuAction.changeTheme,
                  PopupMenuAction.changeLanguage,
                ],
                onPopupActionSelected: controller.handleAppBarAction,
              ),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingData) {
                    return _buildLoadingState();
                  }

                  if (controller.hasErrorState) {
                    return _buildErrorState();
                  }

                  if (!controller.hasHistory) {
                    return _buildEmptyState();
                  }

                  return _buildHistoryContent();
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: const GlobalFloatingMenu(),
      ),
    );
  }

  // Dashboard section with clickable cards
  Widget _buildDashboard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Filter indicator
          Obx(
            () => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                controller.getFilterDisplayText(controller.currentFilter.value),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Dashboard cards with tap handlers
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.5,
            children: [
              _buildDashboardCard(
                'Tổng dự án',
                controller.totalProjects.toString(),
                Icons.folder_outlined,
                AppTheme.primary,
                ProjectFilterType.all,
              ),
              _buildDashboardCard(
                'Yêu thích',
                controller.favoriteProjects.toString(),
                Icons.favorite,
                Colors.red,
                ProjectFilterType.favorites,
              ),
              _buildDashboardCard(
                'An toàn',
                controller.safeProjects.toString(),
                Icons.shield,
                Colors.green,
                ProjectFilterType.safe,
              ),
              _buildDashboardCard(
                'Thử thách',
                controller.challengingProjects.toString(),
                Icons.trending_up,
                Colors.orange,
                ProjectFilterType.challenging,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String count,
    IconData icon,
    Color color,
    ProjectFilterType filterType,
  ) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.onDashboardCardTap(filterType),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: controller.currentFilter.value == filterType
                ? color.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: controller.currentFilter.value == filterType
                  ? color
                  : AppTheme.chipInactive,
              width: controller.currentFilter.value == filterType ? 2 : 1,
            ),
            boxShadow: controller.currentFilter.value == filterType
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22.sp,
                color: controller.currentFilter.value == filterType
                    ? color
                    : AppTheme.secondary,
              ),
              SizedBox(height: 4.h),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: controller.currentFilter.value == filterType
                      ? color
                      : AppTheme.primary,
                ),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12.sp, color: AppTheme.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Animated project list
  Widget _buildProjectsList() {
    return Obx(() {
      if (controller.isFiltering.value) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.filteredProjects.isEmpty) {
        return _buildEmptyState();
      }

      return AnimatedBuilder(
        animation: controller.animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: controller.fadeAnimation,
            child: SlideTransition(
              position: controller.slideAnimation,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(16.w),
                itemCount: controller.filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = controller.filteredProjects[index];
                  return _buildProjectCard(project);
                },
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lot/empty.json', // Add empty state animation
            width: 120.w,
            height: 120.h,
          ),
          SizedBox(height: 16.h),
          Text(
            'Không có dự án nào',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(
            () => Text(
              _getEmptyStateMessage(),
              style: TextStyle(fontSize: 14.sp, color: AppTheme.secondary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (controller.currentFilter.value) {
      case ProjectFilterType.favorites:
        return 'Bạn chưa có dự án yêu thích nào.\nHãy thêm dự án vào yêu thích từ chi tiết dự án.';
      case ProjectFilterType.safe:
        return 'Bạn chưa có dự án an toàn nào.\nHãy tạo dự án mới để bắt đầu.';
      case ProjectFilterType.challenging:
        return 'Bạn chưa có dự án thử thách nào.\nHãy thử tạo dự án khó hơn.';
      default:
        return 'Bạn chưa có dự án nào.\nHãy tạo dự án đầu tiên của bạn.';
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lot/lot_thinking.json',
            width: 120.w,
            height: 120.h,
          ),
          SizedBox(height: AppSizes.p16),
          Text(
            'Đang tải lịch sử dự án...',
            style: TextStyle(fontSize: AppSizes.f16, color: AppTheme.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80.w,
              color: Get.theme.colorScheme.error,
            ),
            SizedBox(height: AppSizes.p16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(
                fontSize: AppSizes.f18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              controller.errorText,
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.p24),
            ElevatedButton.icon(
              onPressed: controller.refreshHistory,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    return Column(
      children: [
        // Statistics Dashboard
        _buildDashboard(),

        // History List
        Expanded(
          child: Obx(() {
            if (controller.isFiltering.value) {
              return Center(child: CircularProgressIndicator());
            }

            if (controller.filteredProjects.isEmpty) {
              return _buildEmptyState();
            }

            return AnimatedBuilder(
              animation: controller.animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: controller.fadeAnimation,
                  child: SlideTransition(
                    position: controller.slideAnimation,
                    child: ListView.builder(
                      padding: EdgeInsets.all(AppSizes.p16),
                      itemCount: controller.filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = controller.filteredProjects[index];
                        return _buildProjectCard(project);
                      },
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatisticsDashboard() {
    return Container(
      padding: EdgeInsets.all(AppSizes.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thống kê',
            style: TextStyle(
              fontSize: AppSizes.f18,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSizes.p12),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.folder_rounded,
                    label: 'Tổng dự án',
                    value: controller.totalProjects.toString(),
                    color: AppTheme.primary,
                  ),
                ),
                SizedBox(width: AppSizes.p8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.favorite_rounded,
                    label: 'Yêu thích',
                    value: controller.favoriteProjects.toString(),
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: AppSizes.p8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.shield_rounded,
                    label: 'An toàn',
                    value: controller.safeProjects.toString(),
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: AppSizes.p8),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.flash_on_rounded,
                    label: 'Thử thách',
                    value: controller.challengingProjects.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.p12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.r8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: AppSizes.p4),
          Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.f16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: AppSizes.f12, color: AppTheme.secondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ProjectHistory project) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.p12),
      child: Card(
        elevation: 4,
        color: AppTheme.chipInactive,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        child: InkWell(
          onTap: () => controller.viewProjectDetail(project),
          borderRadius: BorderRadius.circular(AppSizes.r12),
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.p8,
                        vertical: AppSizes.p4,
                      ),
                      decoration: BoxDecoration(
                        color: controller
                            .getCategoryColor(project.category)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      child: Text(
                        controller.getCategoryDisplayText(project.category),
                        style: TextStyle(
                          fontSize: AppSizes.f12,
                          fontWeight: FontWeight.w500,
                          color: controller.getCategoryColor(project.category),
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Favorite button
                    IconButton(
                      onPressed: () =>
                          controller.toggleFavorite(project.projectId),
                      icon: Icon(
                        project.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: project.isFavorite
                            ? Colors.red
                            : AppTheme.secondary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    // Delete button
                    IconButton(
                      onPressed: () =>
                          controller.deleteProject(project.projectId),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AppTheme.secondary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.p8),

                // Title
                Text(
                  project.title,
                  style: TextStyle(
                    fontSize: AppSizes.f16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppSizes.p8),

                // Description
                Text(
                  project.description,
                  style: TextStyle(
                    fontSize: AppSizes.f14,
                    color: AppTheme.secondary,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: AppSizes.p12),

                // Footer
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: AppTheme.secondary,
                    ),
                    SizedBox(width: AppSizes.p4),
                    Text(
                      controller.getFormattedDate(project.viewedAt),
                      style: TextStyle(
                        fontSize: AppSizes.f12,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
