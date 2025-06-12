import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../../core/values/app_enums.dart';
import '../../core/values/app_sizes.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/global_floating_menu.dart';
import '../../data/models/notion_history_model.dart';
import 'notion_history_controller.dart';

class NotionHistoryView extends GetView<NotionHistoryController> {
  const NotionHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
      floatingActionButton: const GlobalFloatingMenu(),
    );
  }

  /// Build app bar với actions
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppTheme.primary),
        onPressed: controller.goBack,
      ),
      title: Text(
        'Lịch sử Notion',
        style: TextStyle(
          color: AppTheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.f18,
        ),
      ),
      actions: [
        // Refresh button
        IconButton(
          icon: Icon(Icons.refresh, color: AppTheme.primary),
          onPressed: controller.refreshHistory,
          tooltip: 'Làm mới',
        ),
        // Clear all button
        Obx(
          () => controller.hasItems
              ? IconButton(
                  icon: Icon(Icons.delete_sweep, color: Colors.red),
                  onPressed: controller.clearAllHistory,
                  tooltip: 'Xóa tất cả',
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Build main body
  Widget _buildBody() {
    if (controller.isLoadingHistory.value) {
      return _buildLoadingState();
    }

    if (controller.isEmpty.value) {
      return _buildEmptyState();
    }

    return _buildHistoryList();
  }

  /// Loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
          ),
          SizedBox(height: AppSizes.p16),
          Text(
            'Đang tải lịch sử...',
            style: TextStyle(fontSize: AppSizes.f16, color: AppTheme.secondary),
          ),
        ],
      ),
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.primary.withOpacity(0.3),
            ),
            SizedBox(height: AppSizes.p16),
            Text(
              'Chưa có lịch sử',
              style: TextStyle(
                fontSize: AppSizes.f18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Text(
              'Tạo tài liệu Notion đầu tiên của bạn để xem lịch sử tại đây',
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.p24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: Icon(Icons.add_box),
              label: Text('Tạo tài liệu mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.p24,
                  vertical: AppSizes.p12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// History list
  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: controller.refreshHistory,
      color: AppTheme.primary,
      child: Column(
        children: [
          // Header với count
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizes.p16),
            color: AppTheme.primary.withOpacity(0.05),
            child: Text(
              '${controller.historyCount} tài liệu đã tạo',
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // List items
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(AppSizes.p16),
              itemCount: controller.historyItems.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: AppSizes.p12),
              itemBuilder: (context, index) {
                final item = controller.historyItems[index];
                return _buildHistoryItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual history item
  Widget _buildHistoryItem(NotionHistoryItem item) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: InkWell(
        onTap: () => controller.openNotionUrl(item.url),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với title và actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notion icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                    child: Icon(
                      Icons.description,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSizes.p12),

                  // Title và description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: AppSizes.f16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.description != null) ...[
                          SizedBox(height: AppSizes.p4),
                          Text(
                            item.description!,
                            style: TextStyle(
                              fontSize: AppSizes.f14,
                              color: AppTheme.secondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Actions menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppTheme.secondary),
                    onSelected: (value) => _handleMenuAction(value, item),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'open',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_new, size: 18),
                            SizedBox(width: 8),
                            Text('Mở'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'copy',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Sao chép'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: AppSizes.p12),

              // Footer với date và url preview
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppTheme.secondary),
                  SizedBox(width: AppSizes.p4),
                  Text(
                    item.formattedDate,
                    style: TextStyle(
                      fontSize: AppSizes.f12,
                      color: AppTheme.secondary,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'notion.so',
                    style: TextStyle(
                      fontSize: AppSizes.f12,
                      color: AppTheme.primary.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action, NotionHistoryItem item) {
    switch (action) {
      case 'open':
        controller.openNotionUrl(item.url);
        break;
      case 'copy':
        controller.copyUrl(item.url);
        break;
      case 'delete':
        controller.deleteItem(item);
        break;
    }
  }
}
