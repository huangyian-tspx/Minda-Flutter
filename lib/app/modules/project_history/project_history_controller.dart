import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/project_history.dart';
import '../../data/services/database_service.dart';
import '../../routes/app_routes.dart';

/// Filter types for dashboard filtering
enum ProjectFilterType { all, favorites, safe, challenging }

class ProjectHistoryController extends BaseController
    with GetSingleTickerProviderStateMixin {
  late final DatabaseService _databaseService;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Observable data
  final historyProjects = <ProjectHistory>[].obs;
  final filteredProjects =
      <ProjectHistory>[].obs; // NEW: Filtered projects list
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final statistics = <String, int>{}.obs;

  // NEW: Filter state
  final currentFilter = ProjectFilterType.all.obs;
  final isFiltering = false.obs;

  @override
  void onInit() {
    super.onInit();
    _databaseService = Get.find<DatabaseService>();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start with initial animation
    animationController.forward();

    AppLogger.d("ProjectHistoryController initialized");
    loadHistory();
    loadStatistics();
  }

  /// Load all project history from database
  Future<void> loadHistory() async {
    try {
      AppLogger.d("Loading project history...");
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final history = await _databaseService.getProjectHistory();
      historyProjects.value = history;

      // Initialize filtered projects with all projects
      filteredProjects.value = history;

      // Apply current filter
      _applyCurrentFilter();

      AppLogger.d("Loaded ${history.length} history projects");
    } catch (e) {
      AppLogger.e("Error loading history: $e");
      hasError.value = true;
      errorMessage.value = "Không thể tải lịch sử dự án";

      Get.snackbar(
        'Lỗi',
        'Không thể tải lịch sử dự án',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load statistics for dashboard
  Future<void> loadStatistics() async {
    try {
      AppLogger.d("Loading statistics...");
      final stats = await _databaseService.getStatistics();
      statistics.value = stats;
      AppLogger.d("Statistics loaded: $stats");
    } catch (e) {
      AppLogger.e("Error loading statistics: $e");
    }
  }

  /// Delete a project from history
  Future<void> deleteProject(String projectId) async {
    try {
      AppLogger.d("Deleting project from history: $projectId");

      // Show confirmation dialog
      final confirmed =
          await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: const Text(
                'Bạn có chắc muốn xóa dự án này khỏi lịch sử?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Get.theme.colorScheme.error,
                  ),
                  child: const Text('Xóa'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmed) {
        await _databaseService.deleteProject(projectId);

        // Remove from local list
        historyProjects.removeWhere(
          (project) => project.projectId == projectId,
        );

        // Reload statistics
        await loadStatistics();

        AppLogger.d("Successfully deleted from history");
      }
    } catch (e) {
      AppLogger.e("Error deleting from history: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể xóa dự án khỏi lịch sử',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      AppLogger.d("Clearing all history...");

      // Show confirmation dialog
      final confirmed =
          await Get.dialog<bool>(
            AlertDialog(
              title: const Text('Xác nhận'),
              content: const Text(
                'Bạn có chắc muốn xóa tất cả lịch sử dự án? Hành động này không thể hoàn tác.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: true),
                  style: TextButton.styleFrom(
                    foregroundColor: Get.theme.colorScheme.error,
                  ),
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
          ) ??
          false;

      if (confirmed) {
        await _databaseService.clearAllHistory();
        historyProjects.clear();
        statistics.clear();
        AppLogger.d("All history cleared successfully");
      }
    } catch (e) {
      AppLogger.e("Error clearing history: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể xóa lịch sử',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String projectId) async {
    try {
      AppLogger.d("Toggling favorite for project: $projectId");

      await _databaseService.toggleFavorite(projectId);

      // Update local list
      final index = historyProjects.indexWhere((p) => p.projectId == projectId);
      if (index != -1) {
        final updatedProject = historyProjects[index].copyWith(
          isFavorite: !historyProjects[index].isFavorite,
        );
        historyProjects[index] = updatedProject;
      }

      // Reload statistics
      await loadStatistics();

      AppLogger.d("Successfully toggled favorite");
    } catch (e) {
      AppLogger.e("Error toggling favorite: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể cập nhật trạng thái yêu thích',
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

  /// Refresh history list
  Future<void> refreshHistory() async {
    AppLogger.d("Refreshing history list...");
    await loadHistory();
    await loadStatistics();
  }

  /// Filter history by category
  List<ProjectHistory> getFilteredHistory(String? category) {
    if (category == null || category.isEmpty) {
      return historyProjects.toList();
    }
    return historyProjects.where((p) => p.category == category).toList();
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
  bool get hasHistory => historyProjects.isNotEmpty;
  bool get isLoadingData => isLoading.value;
  bool get hasErrorState => hasError.value;
  String get errorText => errorMessage.value;
  int get totalProjects => statistics['total'] ?? 0;
  int get favoriteProjects => statistics['favorites'] ?? 0;
  int get safeProjects => statistics['safe'] ?? 0;
  int get challengingProjects => statistics['challenging'] ?? 0;

  // ========== NEW: FILTER FUNCTIONALITY ==========

  /// Apply filter with smooth animation
  Future<void> applyFilter(ProjectFilterType filterType) async {
    if (currentFilter.value == filterType) {
      AppLogger.d("Filter already applied: $filterType");
      return;
    }

    AppLogger.d("Applying filter: $filterType");
    isFiltering.value = true;

    // Start fade out animation
    await animationController.reverse();

    // Update filter and apply
    currentFilter.value = filterType;
    _applyCurrentFilter();

    // Start fade in animation
    await animationController.forward();

    isFiltering.value = false;
    AppLogger.d("Filter applied successfully: $filterType");
  }

  /// Apply current filter to projects list
  void _applyCurrentFilter() {
    List<ProjectHistory> filtered;

    switch (currentFilter.value) {
      case ProjectFilterType.all:
        filtered = historyProjects.toList();
        break;
      case ProjectFilterType.favorites:
        filtered = historyProjects.where((p) => p.isFavorite).toList();
        break;
      case ProjectFilterType.safe:
        filtered = historyProjects
            .where((p) => p.category.toLowerCase() == 'safe')
            .toList();
        break;
      case ProjectFilterType.challenging:
        filtered = historyProjects
            .where((p) => p.category.toLowerCase() == 'challenging')
            .toList();
        break;
    }

    filteredProjects.value = filtered;
    AppLogger.d(
      "Filtered projects: ${filtered.length} items for filter ${currentFilter.value}",
    );
  }

  /// Handle dashboard card tap with animation
  Future<void> onDashboardCardTap(ProjectFilterType filterType) async {
    AppLogger.d("Dashboard card tapped: $filterType");

    // Add haptic feedback
    HapticFeedback.selectionClick();

    // Start loading state
    isFiltering.value = true;

    try {
      // Start fade out animation
      await animationController.reverse();

      // Update filter and apply
      currentFilter.value = filterType;
      _applyCurrentFilter();

      // Start fade in animation
      await animationController.forward();
    } catch (e) {
      AppLogger.e("Error applying filter: $e");
      Get.snackbar(
        'Lỗi',
        'Không thể áp dụng bộ lọc',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isFiltering.value = false;
    }
  }

  /// Get filter display text
  String getFilterDisplayText(ProjectFilterType filterType) {
    switch (filterType) {
      case ProjectFilterType.all:
        return 'Tất cả dự án';
      case ProjectFilterType.favorites:
        return 'Dự án yêu thích';
      case ProjectFilterType.safe:
        return 'Dự án an toàn';
      case ProjectFilterType.challenging:
        return 'Dự án thử thách';
    }
  }

  /// Check if filter has projects
  bool hasProjectsForFilter(ProjectFilterType filterType) {
    switch (filterType) {
      case ProjectFilterType.all:
        return totalProjects > 0;
      case ProjectFilterType.favorites:
        return favoriteProjects > 0;
      case ProjectFilterType.safe:
        return safeProjects > 0;
      case ProjectFilterType.challenging:
        return challengingProjects > 0;
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
