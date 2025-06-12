import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/project_history.dart';
import '../../data/services/database_service.dart';
import '../../routes/app_routes.dart';

class FavoritesController extends BaseController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // Observable data
  final favoriteProjects = <ProjectHistory>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("FavoritesController initialized");
    loadFavorites();
  }

  /// Load all favorite projects from database
  Future<void> loadFavorites() async {
    try {
      AppLogger.d("Loading favorite projects...");
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final favorites = await _databaseService.getFavoriteProjects();
      favoriteProjects.value = favorites;

      AppLogger.d("Loaded ${favorites.length} favorite projects");
    } catch (e) {
      AppLogger.e("Error loading favorites: $e");
      hasError.value = true;
      errorMessage.value = "Không thể tải danh sách yêu thích";

      Get.snackbar(
        'Lỗi',
        'Không thể tải danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove a project from favorites
  Future<void> removeFromFavorites(String projectId) async {
    try {
      AppLogger.d("Removing project from favorites: $projectId");

      await _databaseService.toggleFavorite(projectId);

      // Remove from local list
      favoriteProjects.removeWhere((project) => project.projectId == projectId);

      AppLogger.d("Successfully removed from favorites");
    } catch (e) {
      AppLogger.e("Error removing from favorites: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể xóa khỏi danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    try {
      AppLogger.d("Clearing all favorites...");

      // Show confirmation dialog
      final confirmed =
          await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text(
                'Bạn có chắc muốn xóa tất cả dự án khỏi danh sách yêu thích?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmed) {
        await _databaseService.clearAllFavorites();
        favoriteProjects.clear();
        AppLogger.d("All favorites cleared successfully");
      }
    } catch (e) {
      AppLogger.e("Error clearing favorites: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể xóa danh sách yêu thích',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Navigate to project detail
  void viewProjectDetail(ProjectHistory project) {
    AppLogger.d("Navigating to project detail: ${project.title}");

    try {
      // Convert back to ProjectTopic and pass with category AND projectId
      final projectTopic = project.projectTopic;

      Get.toNamed(
        Routes.PROJECT_DETAIL,
        arguments: {
          'topic': projectTopic,
          'category': project.category,
          'projectId':
              project.projectId, // IMPORTANT: Pass the original projectId
        },
      );
    } catch (e) {
      AppLogger.e("Error navigating to project detail: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể mở chi tiết dự án: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Refresh favorites list
  Future<void> refreshFavorites() async {
    AppLogger.d("Refreshing favorites list...");
    await loadFavorites();
  }

  /// Get formatted view date
  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Get category display text
  String getCategoryDisplayText(String category) {
    switch (category.toLowerCase()) {
      case 'safe':
        return 'An toàn';
      case 'challenging':
        return 'Thử thách';
      default:
        return category;
    }
  }

  /// Get category color
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'safe':
        return Get.theme.primaryColor;
      case 'challenging':
        return Get.theme.colorScheme.secondary;
      default:
        return Get.theme.primaryColor;
    }
  }

  // Getters for UI
  bool get hasFavorites => favoriteProjects.isNotEmpty;
  bool get isLoadingData => isLoading.value;
  bool get hasErrorState => hasError.value;
  String get errorText => errorMessage.value;
}
