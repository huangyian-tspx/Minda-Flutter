import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/base_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_logger.dart';
import '../../data/models/api_response.dart';
import '../../data/models/project_history.dart';
import '../../data/models/topic_suggestion_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/notion_api_service.dart';
import '../../data/services/notion_history_service.dart';
import '../../data/services/openrouter_api_service.dart';
import 'dialogs.dart';
import 'expandable_list_controller.dart';

/// Controller for Project Detail screen
///
/// Handles loading detailed project information via API call
/// Support typewriter animations và error states
class ProjectDetailController extends BaseController {
  // Project data observables
  final projectTopic = Rxn<ProjectTopic>();
  final isLoadingDetail = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Favorite status - THÊM MỚI
  final isFavorite = false.obs;
  String? _currentProjectId; // Lưu projectId hiện tại

  // Basic topic info (từ arguments)
  Topic? _basicTopic;
  String? _category; // 'safe' or 'challenging'

  // Animation states cho UI
  final showProblemStatement = false.obs;
  final showProposedSolution = false.obs;
  final showCoreFeatures = false.obs;
  final showAdvancedFeatures = false.obs;
  final showKnowledge = false.obs;
  final showImplementation = false.obs;
  final showCodeExamples = false.obs;

  // Controllers for expandable lists
  late final ExpandableListController coreFeaturesController;
  late final ExpandableListController advancedFeaturesController;

  @override
  void onInit() {
    super.onInit();
    AppLogger.d("ProjectDetailController initialized");

    // Initialize expandable list controllers
    coreFeaturesController = ExpandableListController();
    advancedFeaturesController = ExpandableListController();

    // Get arguments and check data type
    final arguments = Get.arguments;
    if (arguments != null) {
      // Check if arguments is a Map with topic and category
      if (arguments is Map<String, dynamic>) {
        final topicData = arguments['topic'];
        _category = arguments['category'] as String?;

        // NEW: Check if we received complete ProjectTopic from history/favorites
        if (topicData is ProjectTopic) {
          AppLogger.d(
            "Received COMPLETE ProjectTopic from history/favorites: ${topicData.title}",
          );
          projectTopic.value = topicData;

          // Extract projectId from arguments if available
          if (arguments.containsKey('projectId')) {
            _currentProjectId = arguments['projectId'] as String?;
            AppLogger.d("Using existing projectId: $_currentProjectId");
          } else {
            // Fallback: try to find in database by title
            _findProjectIdByTitle(topicData.title);
          }

          // Check favorite status and start animation
          _checkFavoriteStatus();
          _startAnimationSequence();
        } else if (topicData is Topic) {
          // Original flow: basic topic from suggestion list
          _basicTopic = topicData;
          AppLogger.d(
            "Received basic topic from suggestion: ${_basicTopic!.title}",
          );
          // Load detailed information via API
          _loadProjectDetail();
        }
      } else if (arguments is Topic) {
        // Direct Topic argument
        _basicTopic = arguments;
        _category = 'safe'; // Default category
        AppLogger.d("Received direct topic: ${_basicTopic!.title}");
        _loadProjectDetail();
      }
    } else {
      AppLogger.e("No arguments received in ProjectDetailController");
      _handleError("Không nhận được thông tin dự án");
    }
  }

  /// Find projectId by title in database (fallback method)
  Future<void> _findProjectIdByTitle(String title) async {
    try {
      final dbService = Get.find<DatabaseService>();
      final allProjects = await dbService.getProjectHistory();

      final matchingProject = allProjects.firstWhereOrNull(
        (p) => p.title.toLowerCase().trim() == title.toLowerCase().trim(),
      );

      if (matchingProject != null) {
        _currentProjectId = matchingProject.projectId;
        AppLogger.d("Found projectId by title: $_currentProjectId");
      } else {
        AppLogger.d("No matching project found for title: $title");
      }
    } catch (e) {
      AppLogger.e("Error finding projectId by title: $e");
    }
  }

  /// Load detailed project information từ API
  ///
  /// Call OpenRouter API để lấy thông tin chi tiết cho dự án
  Future<void> _loadProjectDetail() async {
    if (_basicTopic == null) {
      AppLogger.e("Cannot load project detail: basic topic is null");
      return;
    }

    try {
      AppLogger.d("Loading project detail for: ${_basicTopic!.id}");
      isLoadingDetail.value = true;
      hasError.value = false;

      // Call OpenRouter API service
      final response = await OpenRouterAPIService.instance.getProjectDetail(
        _basicTopic!.id,
        _basicTopic!,
      );

      if (response is Success<ProjectTopic>) {
        AppLogger.d(
          "Successfully loaded project detail: ${response.data.title}",
        );
        projectTopic.value = response.data;

        // Save to history với TOÀN BỘ thông tin chi tiết
        await _saveToHistory(response.data);

        // Check favorite status sau khi save
        await _checkFavoriteStatus();

        // Start showing sections với animation sequence
        _startAnimationSequence();
      } else if (response is Failure<ProjectTopic>) {
        AppLogger.e("Failed to load project detail: ${response.error.message}");
        _handleError(response.error.message);
      }
    } catch (e) {
      AppLogger.e("Unexpected error loading project detail: $e");
      _handleError("Lỗi không xác định khi tải thông tin dự án");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// Save project to history database với TOÀN BỘ thông tin
  Future<void> _saveToHistory(
    ProjectTopic topic, {
    bool isFavorite = false,
  }) async {
    try {
      final dbService = Get.find<DatabaseService>();

      // Create consistent projectId using title and basic topic id
      final projectId =
          '${topic.title}_${_basicTopic?.id ?? DateTime.now().millisecondsSinceEpoch}';
      _currentProjectId = projectId; // Lưu lại để dùng cho favorite

      // Lưu TOÀN BỘ thông tin chi tiết của ProjectTopic
      var history = ProjectHistory(
        projectId: projectId,
        title: topic.title,
        description: topic.description,
        category: _category ?? 'safe',
        viewedAt: DateTime.now(),
        projectData: jsonEncode({
          // Lưu toàn bộ thông tin chi tiết
          'id': topic.id,
          'title': topic.title,
          'description': topic.description,
          'problemStatement': topic.problemStatement,
          'proposedSolution': topic.proposedSolution,
          'coreTechStack': topic.coreTechStack
              .map((t) => {'name': t.name, 'description': t.description})
              .toList(),
          'coreFeatures': topic.coreFeatures
              .map((f) => {'title': f.title, 'content': f.content})
              .toList(),
          'advancedFeatures': topic.advancedFeatures
              .map((f) => {'title': f.title, 'content': f.content})
              .toList(),
          'foundationalKnowledge': topic.foundationalKnowledge,
          'specificKnowledge': topic.specificKnowledge
              .map((k) => {'title': k.title, 'difficulty': k.difficulty.name})
              .toList(),
          'implementationSteps': topic.implementationSteps,
          'codeExamples': topic.codeExamples
              .map(
                (e) => {
                  'title': e.title,
                  'code': e.code,
                  'language': e.language,
                  'explanation': e.explanation,
                },
              )
              .toList(),
          'category': _category ?? 'safe',
          'timestamp': DateTime.now().toIso8601String(),
        }),
        isFavorite: isFavorite,
      );

      await dbService.saveProjectHistory(history);
      AppLogger.d("Saved COMPLETE project data to history: ${topic.title}");
    } catch (e) {
      AppLogger.e("Error saving project to history: $e");
      // Don't show error to user, this is non-critical
    }
  }

  /// Check favorite status từ database
  Future<void> _checkFavoriteStatus() async {
    if (_currentProjectId == null) return;

    try {
      final dbService = Get.find<DatabaseService>();
      final project = await dbService.getProjectById(_currentProjectId!);

      if (project != null) {
        isFavorite.value = project.isFavorite;
        AppLogger.d("Favorite status loaded: ${isFavorite.value}");
      }
    } catch (e) {
      AppLogger.e("Error checking favorite status: $e");
    }
  }

  /// Handle error states
  void _handleError(String message) {
    hasError.value = true;
    errorMessage.value = message;

    // Fallback to basic topic data
    if (_basicTopic != null) {
      projectTopic.value = ProjectTopic.fromTopic(_basicTopic!);
      AppLogger.d("Using fallback topic data for: ${_basicTopic!.title}");
    }
  }

  /// Start animation sequence cho các sections
  ///
  /// Hiển thị từng section theo thứ tự với delay để tạo hiệu ứng mượt mà
  void _startAnimationSequence() {
    AppLogger.d("Starting simplified animation sequence");

    // Show all sections immediately with small delays
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        showProblemStatement.value = true;
        showProposedSolution.value = true;
        showCoreFeatures.value = true;
        showAdvancedFeatures.value = true;
        showKnowledge.value = true;
        showImplementation.value = true;
        showCodeExamples.value = true;
      }
    });
  }

  /// Retry loading project detail
  ///
  /// Được gọi khi user tap retry button
  Future<void> retryLoadDetail() async {
    AppLogger.d("Retrying to load project detail");
    await _loadProjectDetail();
  }

  /// Reset animation states
  void resetAnimations() {
    showProblemStatement.value = false;
    showProposedSolution.value = false;
    showCoreFeatures.value = false;
    showAdvancedFeatures.value = false;
    showKnowledge.value = false;
    showImplementation.value = false;
    showCodeExamples.value = false;
  }

  /// Navigation methods
  void goBack() {
    Get.back();
  }

  /// Share project information
  void shareProject() {
    if (projectTopic.value != null) {
      AppLogger.d("Sharing project: ${projectTopic.value!.title}");
      // TODO: Implement share functionality
      Get.snackbar(
        'Chia sẻ',
        'Tính năng chia sẻ sẽ được bổ sung sau',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save project to favorites
  void toggleFavorite() async {
    if (projectTopic.value != null) {
      AppLogger.d("Toggle favorite for project: ${projectTopic.value!.title}");

      try {
        final dbService = Get.find<DatabaseService>();

        // Sử dụng projectId đã lưu trước đó
        if (_currentProjectId != null) {
          final newFavoriteStatus = await dbService.toggleFavorite(
            _currentProjectId!,
          );
          isFavorite.value = newFavoriteStatus; // Update UI state
          AppLogger.d("Project favorite status updated: $newFavoriteStatus");

          // Show feedback
          Get.snackbar(
            newFavoriteStatus ? 'Đã thêm yêu thích' : 'Đã xóa khỏi yêu thích',
            projectTopic.value!.title,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: newFavoriteStatus ? Get.theme.primaryColor : null,
            colorText: newFavoriteStatus
                ? Get.theme.colorScheme.onPrimary
                : null,
            duration: const Duration(seconds: 2),
          );
        } else {
          // Fallback: tìm theo title
          final existingProject = await dbService.getProjectHistory();
          final matchingProject = existingProject.firstWhereOrNull(
            (p) => p.title == projectTopic.value!.title,
          );

          if (matchingProject != null) {
            _currentProjectId = matchingProject.projectId;
            final newFavoriteStatus = await dbService.toggleFavorite(
              matchingProject.projectId,
            );
            isFavorite.value = newFavoriteStatus;
            AppLogger.d("Project favorite status: $newFavoriteStatus");
          } else {
            // If not in history, save it first with isFavorite = true
            await _saveToHistory(projectTopic.value!, isFavorite: true);
            isFavorite.value = true;
            Get.snackbar(
              'Đã thêm yêu thích',
              'Dự án đã được lưu vào yêu thích',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Get.theme.primaryColor,
              colorText: Get.theme.colorScheme.onPrimary,
            );
          }
        }
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
  }

  // Getters for UI
  bool get hasProjectData => projectTopic.value != null;
  bool get isLoadingBase => isLoadingDetail.value;
  String get projectTitle =>
      projectTopic.value?.title ?? _basicTopic?.title ?? 'Dự án';
  String get projectId => projectTopic.value?.id ?? _basicTopic?.id ?? '';

  @override
  void onClose() {
    AppLogger.d("ProjectDetailController disposed");
    coreFeaturesController.dispose();
    advancedFeaturesController.dispose();
    super.onClose();
  }

  // --- Helper method để mở URL ---
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Có thể show snackbar hoặc log lỗi
      print('Không thể mở link: $url');
    }
  }

  // --- Logic cho các nút Action ---
  void createChecklist() {
    // TODO: Implement logic tạo checklist
    Get.snackbar(
      'Tính năng sắp ra mắt',
      'Chức năng tạo checklist sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void shareToTeam() {
    // TODO: Sử dụng package share_plus để chia sẻ nội dung
    Get.snackbar(
      'Tính năng sắp ra mắt',
      'Chức năng chia sẻ cho team sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Tạo Notion docs cho project hiện tại với check history
  Future<void> createNotionDocs() async {
    if (projectTopic.value == null) {
      Get.snackbar(
        'Lỗi',
        'Không có dữ liệu dự án để tạo tài liệu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      AppLogger.d(
        "Checking Notion history for project: ${projectTopic.value!.title}",
      );

      // Step 1: Check if document already exists in history
      final history = await NotionHistoryService.instance.getHistory();
      final existingDoc = history
          .where(
            (item) =>
                item.title.toLowerCase().trim() ==
                projectTopic.value!.title.toLowerCase().trim(),
          )
          .toList();

      if (existingDoc.isNotEmpty) {
        // Document already exists, show options dialog
        final existingUrl = existingDoc.first.url;
        AppLogger.d("Found existing document in history: $existingUrl");

        Get.dialog(
          ExistingNotionDialog(
            title: projectTopic.value!.title,
            existingUrl: existingUrl,
            onOpenExisting: () {
              Get.back(); // Close dialog
              openUrl(existingUrl);
            },
            onViewHistory: () {
              Get.back(); // Close dialog
              Get.toNamed('/notion-history');
            },
            onCreateNew: () {
              Get.back(); // Close dialog
              _performNotionDocumentCreation(); // Create new document
            },
          ),
        );
        return;
      }

      // No existing document found, create new one
      AppLogger.d("No existing document found, creating new one");
      await _performNotionDocumentCreation();
    } catch (e) {
      AppLogger.e("Error checking Notion history: $e");
      // If error checking history, proceed with creation
      await _performNotionDocumentCreation();
    }
  }

  /// Thực hiện tạo Notion document mới
  Future<void> _performNotionDocumentCreation() async {
    try {
      AppLogger.d(
        "Starting Notion document creation for: ${projectTopic.value!.title}",
      );

      // Show loading dialog
      Get.dialog(
        LoadingDialog(message: "Đang tạo nội dung tài liệu với AI..."),
        barrierDismissible: false,
      );

      // Convert ProjectTopic to Map với đầy đủ thông tin
      final project = {
        'name': projectTopic.value!.title,
        'description': projectTopic.value!.description,
        'features': projectTopic.value!.coreFeatures
            .map((f) => f.title)
            .toList(),
        'techStack': projectTopic.value!.coreTechStack
            .map((t) => t.name)
            .toList(),
        'codeExamples': projectTopic.value!.codeExamples
            .map(
              (e) => {
                'title': e.title,
                'code': e.code,
                'language': e.language,
                'explanation': e.explanation,
              },
            )
            .toList(),
      };

      // Step 1: Generate documentation từ OpenRouter
      final result = await OpenRouterAPIService.instance
          .generateProjectDocumentation(project);

      if (result is Failure<Map<String, dynamic>>) {
        Get.back(); // Close loading
        AppLogger.e(
          "Failed to generate documentation: ${result.error.message}",
        );
        Get.dialog(
          ErrorDialog(title: 'Lỗi tạo tài liệu', message: result.error.message),
        );
        return;
      }

      // Get content from successful result
      final content = (result as Success<Map<String, dynamic>>).data;
      AppLogger.d("Successfully generated documentation content");

      // Step 2: Create Notion page
      final notionResult = await NotionAPIService.instance
          .createProjectDocument(
            title: projectTopic.value!.title,
            content: content,
          );

      Get.back(); // Close loading

      if (notionResult is Success<String>) {
        final pageUrl = notionResult.data;
        AppLogger.d("Successfully created Notion document: $pageUrl");

        Get.dialog(
          SuccessDialog(
            title: 'Tạo tài liệu thành công',
            message: 'Tài liệu đã được tạo trong Notion',
            buttonText: 'Mở Notion',
            onPressed: () {
              Get.back();
              openUrl(pageUrl);
            },
            onCopyPressed: () {
              _copyAndSaveNotionUrl(pageUrl);
            },
          ),
        );
      } else if (notionResult is Failure<String>) {
        AppLogger.e(
          "Failed to create Notion document: ${notionResult.error.message}",
        );
        Get.dialog(
          ErrorDialog(
            title: 'Lỗi tạo trang Notion',
            message: notionResult.error.message,
          ),
        );
      }
    } catch (e) {
      Get.back(); // Close loading if still open
      AppLogger.e("Unexpected error creating Notion document: $e");
      Get.dialog(ErrorDialog(title: 'Lỗi', message: 'Có lỗi xảy ra: $e'));
    }
  }

  /// Copy Notion URL và lưu vào lịch sử
  Future<void> _copyAndSaveNotionUrl(String url) async {
    try {
      AppLogger.d("Copying and saving Notion URL: $url");

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: url));
      AppLogger.d("Successfully copied URL to clipboard");

      // Save to history via NotionHistoryService
      if (projectTopic.value != null) {
        final success = await NotionHistoryService.instance.saveToHistory(
          title: projectTopic.value!.title,
          url: url,
          description: projectTopic.value!.description,
        );

        if (success) {
          AppLogger.d("Successfully saved to Notion history");
        } else {
          AppLogger.e("Failed to save to Notion history");
        }
      }

      Get.back(); // Close success dialog
      Get.snackbar(
        'Đã sao chép',
        'Link đã được sao chép và lưu vào lịch sử',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.primary.withOpacity(0.1),
        colorText: AppTheme.primary,
        duration: Duration(seconds: 3),
        mainButton: TextButton(
          onPressed: () {
            // Navigate to history screen
            Get.toNamed('/notion-history');
          },
          child: Text('Xem lịch sử', style: TextStyle(color: AppTheme.primary)),
        ),
      );
    } catch (e) {
      AppLogger.e("Error copying/saving URL: $e");
      Get.back(); // Close success dialog if still open
      Get.snackbar(
        'Lỗi',
        'Có lỗi khi sao chép link: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void suggestLibraries() {
    // TODO: Hiển thị Get.bottomSheet với danh sách thư viện gợi ý
    Get.snackbar(
      'Tính năng sắp ra mắt',
      'Chức năng gợi ý thư viện sẽ sớm được cập nhật!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
