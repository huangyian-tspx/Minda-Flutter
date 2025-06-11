import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/notion_history_model.dart';
import '../../data/services/notion_history_service.dart';

/// Controller cho màn hình lịch sử Notion documents
class NotionHistoryController extends BaseController {
  // Observable data
  final historyItems = <NotionHistoryItem>[].obs;
  final isLoadingHistory = false.obs;
  final isEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("NotionHistoryController initialized");
    loadHistory();
  }

  /// Load lịch sử từ service
  Future<void> loadHistory() async {
    try {
      AppLogger.d("Loading Notion history");
      isLoadingHistory.value = true;

      final history = await NotionHistoryService.instance.getHistory();
      historyItems.value = history;
      isEmpty.value = history.isEmpty;

      AppLogger.d("Loaded ${history.length} history items");
    } catch (e) {
      AppLogger.e("Error loading history: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể tải lịch sử: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Refresh lịch sử
  Future<void> refreshHistory() async {
    AppLogger.d("Refreshing Notion history");
    await loadHistory();
  }

  /// Mở Notion URL
  Future<void> openNotionUrl(String url) async {
    try {
      AppLogger.d("Opening Notion URL: $url");

      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.d("Successfully opened Notion URL");
      } else {
        AppLogger.e("Cannot launch URL: $url");
        Get.snackbar(
          'Lỗi',
          'Không thể mở link Notion',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      AppLogger.e("Error opening Notion URL: $e");
      Get.snackbar(
        'Lỗi',
        'Có lỗi khi mở link: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Copy URL to clipboard
  Future<void> copyUrl(String url) async {
    try {
      AppLogger.d("Copying URL to clipboard: $url");

      await Clipboard.setData(ClipboardData(text: url));
      Get.snackbar(
        'Đã sao chép',
        'Link đã được sao chép vào clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      AppLogger.d("Successfully copied URL to clipboard");
    } catch (e) {
      AppLogger.e("Error copying URL: $e");
      Get.snackbar(
        'Lỗi',
        'Có lỗi khi sao chép link',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Xóa một item khỏi lịch sử
  Future<void> deleteItem(NotionHistoryItem item) async {
    try {
      AppLogger.d("Deleting history item: ${item.id}");

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa "${item.title}" khỏi lịch sử?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Xóa'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await NotionHistoryService.instance.removeFromHistory(
          item.id,
        );

        if (success) {
          // Remove from local list
          historyItems.removeWhere((historyItem) => historyItem.id == item.id);
          isEmpty.value = historyItems.isEmpty;

          AppLogger.d("Successfully deleted history item");
          Get.snackbar(
            'Đã xóa',
            'Đã xóa "${item.title}" khỏi lịch sử',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          );
        } else {
          AppLogger.e("Failed to delete history item");
          Get.snackbar(
            'Lỗi',
            'Không thể xóa item khỏi lịch sử',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      AppLogger.e("Error deleting history item: $e");
      Get.snackbar(
        'Lỗi',
        'Có lỗi khi xóa item: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Xóa toàn bộ lịch sử
  Future<void> clearAllHistory() async {
    try {
      AppLogger.d("Clearing all history");

      if (historyItems.isEmpty) {
        Get.snackbar(
          'Thông báo',
          'Lịch sử đã trống',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Xác nhận xóa tất cả'),
          content: Text(
            'Bạn có chắc muốn xóa toàn bộ lịch sử Notion? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('Xóa tất cả'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await NotionHistoryService.instance.clearHistory();

        if (success) {
          historyItems.clear();
          isEmpty.value = true;

          AppLogger.d("Successfully cleared all history");
          Get.snackbar(
            'Đã xóa',
            'Đã xóa toàn bộ lịch sử Notion',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 2),
          );
        } else {
          AppLogger.e("Failed to clear history");
          Get.snackbar(
            'Lỗi',
            'Không thể xóa lịch sử',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      AppLogger.e("Error clearing history: $e");
      Get.snackbar(
        'Lỗi',
        'Có lỗi khi xóa lịch sử: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate back
  void goBack() {
    Get.back();
  }

  /// Get history count
  int get historyCount => historyItems.length;

  /// Check if has any items
  bool get hasItems => historyItems.isNotEmpty;

  @override
  void onClose() {
    AppLogger.d("NotionHistoryController disposed");
    super.onClose();
  }
}
