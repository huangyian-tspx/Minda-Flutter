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
import 'favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<FavoritesController>(
      controller: Get.put(FavoritesController()),
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar
              CustomAppBar(
                title: 'Dự án yêu thích',
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

                  if (!controller.hasFavorites) {
                    return _buildEmptyState();
                  }

                  return _buildFavoritesList();
                }),
              ),
            ],
          ),
        ),
        floatingActionButton: const GlobalFloatingMenu(),
      ),
    );
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
            'Đang tải danh sách yêu thích...',
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
              onPressed: controller.refreshFavorites,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lot/empty.json', width: 200.w, height: 200.h),
            SizedBox(height: AppSizes.p24),
            Text(
              'Chưa có dự án yêu thích',
              style: TextStyle(
                fontSize: AppSizes.f18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              'Hãy khám phá và thêm những dự án bạn yêu thích vào danh sách để dễ dàng truy cập lại sau này!',
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.p32),
            ElevatedButton.icon(
              onPressed: () => Get.offAllNamed('/information-input'),
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Khám phá dự án'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p24,
                  vertical: AppSizes.p12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return Column(
      children: [
        // Header with actions
        _buildListHeader(),

        // Favorites list
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refreshFavorites,
            child: ListView.builder(
              padding: EdgeInsets.all(AppSizes.p16),
              itemCount: controller.favoriteProjects.length,
              itemBuilder: (context, index) {
                final project = controller.favoriteProjects[index];
                return _buildProjectCard(project);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p12,
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => Text(
                '${controller.favoriteProjects.length} dự án yêu thích',
                style: TextStyle(
                  fontSize: AppSizes.f16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          if (controller.hasFavorites)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: AppTheme.secondary),
              onSelected: (value) {
                if (value == 'clear_all') {
                  controller.clearAllFavorites();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all_rounded),
                      SizedBox(width: 8),
                      Text('Xóa tất cả'),
                    ],
                  ),
                ),
              ],
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
                          controller.removeFromFavorites(project.projectId),
                      icon: Icon(
                        Icons.favorite_rounded,
                        color: Colors.red,
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
