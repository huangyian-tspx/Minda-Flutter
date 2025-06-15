import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_theme.dart';
import '../../core/values/app_sizes.dart';
import '../../core/widgets/code_viewer.dart';
import '../../core/widgets/index.dart';
import '../../data/models/topic_suggestion_model.dart';
import 'project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() => _buildBody()),
      floatingActionButton: const GlobalFloatingMenu(),
    );
  }

  /// Custom app bar với loading indicator
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppTheme.primary),
        onPressed: controller.goBack,
      ),
      title: Obx(
        () => Text(
          controller.projectTitle,
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      actions: [
        // Loading indicator trong app bar
        Obx(
          () => controller.isLoadingBase
              ? Container(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: Icon(Icons.share, color: AppTheme.primary),
                    //   onPressed: controller.shareProject,
                    // ),
                    // Favorite button với trạng thái realtime
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isFavorite.value
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: controller.isFavorite.value
                              ? Colors.red
                              : AppTheme.primary,
                        ),
                        onPressed: controller.toggleFavorite,
                        tooltip: controller.isFavorite.value
                            ? 'Xóa khỏi yêu thích'
                            : 'Thêm vào yêu thích',
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  /// Main body với loading, error, và content states
  Widget _buildBody() {
    // Loading state
    if (controller.isLoadingBase && !controller.hasProjectData) {
      return _buildLoadingState();
    }

    // Error state
    if (controller.hasError.value && !controller.hasProjectData) {
      return _buildErrorState();
    }

    // Content state
    final topic = controller.projectTopic.value;
    if (topic == null) {
      return _buildNoDataState();
    }

    return _buildContent(topic);
  }

  /// Loading state với animations
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/lot/lot_thinking.json',
            width: 120.w,
            height: 120.h,
            fit: BoxFit.cover,
          ),
          SizedBox(height: AppSizes.p16),
          TypewriterText(
            text:
                'Đang tải thông tin chi tiết dự án. Vui lòng không chuyển màn hình hoặc đóng ứng dụng ...',
            speed: Duration(milliseconds: 80),
            style: TextStyle(
              fontSize: AppSizes.f16,
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Error state với retry button
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.primary.withOpacity(0.6),
            ),
            SizedBox(height: AppSizes.p16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: AppSizes.f18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: AppSizes.p8),
            Obx(
              () => Text(
                controller.errorMessage.value,
                style: TextStyle(
                  fontSize: AppSizes.f14,
                  color: AppTheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSizes.p24),
            ElevatedButton.icon(
              onPressed: controller.retryLoadDetail,
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
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

  /// No data state
  Widget _buildNoDataState() {
    return Center(
      child: Text(
        'Không có dữ liệu dự án',
        style: TextStyle(fontSize: AppSizes.f16, color: AppTheme.secondary),
      ),
    );
  }

  /// Main content với animations
  Widget _buildContent(ProjectTopic topic) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - luôn hiển thị
            _buildHeaderSection(topic),
            SizedBox(height: AppSizes.p16),

            // Problem Statement Section - với typewriter animation
            Obx(
              () => controller.showProblemStatement.value
                  ? _buildProblemStatementSection(topic)
                  : SizedBox.shrink(),
            ),

            // Proposed Solution Section
            Obx(
              () => controller.showProposedSolution.value
                  ? _buildProposedSolutionSection(topic)
                  : SizedBox.shrink(),
            ),

            // Tech Stack Section
            _buildTechStackSection(topic),

            // Core Features Section
            Obx(
              () => controller.showCoreFeatures.value
                  ? _buildCoreFeaturesSection(topic)
                  : SizedBox.shrink(),
            ),

            // Advanced Features Section
            Obx(
              () => controller.showAdvancedFeatures.value
                  ? _buildAdvancedFeaturesSection(topic)
                  : SizedBox.shrink(),
            ),

            // Knowledge Section
            Obx(
              () => controller.showKnowledge.value
                  ? _buildKnowledgeSection(topic)
                  : SizedBox.shrink(),
            ),

            // Implementation Steps Section
            Obx(
              () => controller.showImplementation.value
                  ? _buildImplementationSection(topic)
                  : SizedBox.shrink(),
            ),

            // Code Examples Section
            Obx(
              () => controller.showCodeExamples.value
                  ? _buildCodeExamplesSection(topic)
                  : SizedBox.shrink(),
            ),

            // Reference Links Section
            _buildReferenceLinksSection(topic),

            // Github Links Section
            _buildGithubLinksSection(topic),

            // Action Buttons Section
            _buildActionButtonsSection(),

            SizedBox(height: AppSizes.p24),
          ],
        ),
      ),
    );
  }

  /// Header Section với click animation
  Widget _buildHeaderSection(ProjectTopic topic) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.p20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.r12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title,
            style: TextStyle(
              fontSize: AppSizes.f18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            topic.description,
            style: TextStyle(
              fontSize: AppSizes.f14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Problem Statement Section với typewriter effect
  Widget _buildProblemStatementSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 100),
          child: SectionCard(
            title: 'Vấn đề cần giải quyết',
            child: TypewriterText(
              text: topic.problemStatement,
              speed: Duration(milliseconds: 30),
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Proposed Solution Section với typewriter effect
  Widget _buildProposedSolutionSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 200),
          child: SectionCard(
            title: 'Hướng tiếp cận của dự án',
            child: TypewriterText(
              text: topic.proposedSolution,
              speed: Duration(milliseconds: 30),
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Tech Stack Section
  Widget _buildTechStackSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 300),
          child: SectionCard(
            title: 'Công nghệ sử dụng',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSizes.p8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      child: Lottie.asset(
                        'assets/lot/tech_lot.json',
                        width: 150.w,
                        height: 150.h,
                        fit: BoxFit.cover,
                        repeat: true,
                        animate: true,
                      ),
                    ),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thư viện & Công cụ',
                            style: TextStyle(
                              fontSize: AppSizes.f16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                          SizedBox(height: AppSizes.p4),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Implement suggest libraries
                              Get.snackbar(
                                'Gợi ý thư viện',
                                'Tính năng sẽ được bổ sung sau',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            icon: Icon(CupertinoIcons.sparkles, size: 18),
                            label: Text('Try'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.amber,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.r8,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.p16,
                                vertical: AppSizes.p8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.p16),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 50.h),
                  child: Wrap(
                    spacing: AppSizes.p8,
                    runSpacing: AppSizes.p8,
                    children: topic.coreTechStack
                        .map(
                          (tech) => Chip(
                            label: Text(tech.name),
                            backgroundColor: AppTheme.chipInactive,
                            labelStyle: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Core Features Section với animation
  Widget _buildCoreFeaturesSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 400),
          child: SectionCard(
            title: 'Chức năng cơ bản - bắt buộc',
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 100.h),
              child: topic.coreFeatures.isNotEmpty
                  ? AnimatedExpandableList(
                      items: topic.coreFeatures,
                      controller: controller.coreFeaturesController,
                    )
                  : Center(
                      child: Text(
                        'Đang tải thông tin tính năng...',
                        style: TextStyle(
                          fontSize: AppSizes.f14,
                          color: AppTheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Advanced Features Section với animation
  Widget _buildAdvancedFeaturesSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 500),
          child: SectionCard(
            title: 'Tính năng nâng cao - Đạt điểm cao',
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 100.h),
              child: topic.advancedFeatures.isNotEmpty
                  ? AnimatedExpandableList(
                      items: topic.advancedFeatures,
                      controller: controller.advancedFeaturesController,
                    )
                  : Center(
                      child: Text(
                        'Đang tải thông tin tính năng nâng cao...',
                        style: TextStyle(
                          fontSize: AppSizes.f14,
                          color: AppTheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Knowledge Section với animation
  Widget _buildKnowledgeSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 600),
          child: SectionCard(
            title: 'Kiến thức nền tảng cần có',
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 250.h),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kiến thức cơ bản
                      Text(
                        'Kiến thức cơ bản',
                        style: TextStyle(
                          fontSize: AppSizes.f16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: AppSizes.p12),
                      if (topic.foundationalKnowledge.isNotEmpty)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 40.h),
                          child: Wrap(
                            spacing: AppSizes.p8,
                            runSpacing: AppSizes.p8,
                            children: topic.foundationalKnowledge
                                .map(
                                  (knowledge) => Card(
                                    elevation: 1,
                                    color: AppTheme.chipInactive,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: AppSizes.p12,
                                        vertical: AppSizes.p8,
                                      ),
                                      child: Text(
                                        knowledge,
                                        style: TextStyle(
                                          fontSize: AppSizes.f14,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      SizedBox(height: AppSizes.p16),

                      // Kiến thức cụ thể
                      Text(
                        'Kiến thức cụ thể',
                        style: TextStyle(
                          fontSize: AppSizes.f16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                      SizedBox(height: AppSizes.p12),
                      if (topic.specificKnowledge.isNotEmpty)
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 80.h),
                          child: Column(
                            children: topic.specificKnowledge
                                .map(
                                  (knowledge) => Container(
                                    margin: EdgeInsets.only(
                                      bottom: AppSizes.p8,
                                    ),
                                    child: KnowledgeDifficultyCard(
                                      knowledgeItem: knowledge,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Implementation Steps Section mới
  Widget _buildImplementationSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 700),
          child: SectionCard(
            title: 'Các bước thực hiện',
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 150.h),
              child: topic.implementationSteps.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topic.implementationSteps
                          .asMap()
                          .entries
                          .map(
                            (entry) => Container(
                              margin: EdgeInsets.only(bottom: AppSizes.p12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    margin: EdgeInsets.only(top: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.p12),
                                  Expanded(
                                    child: TypewriterText(
                                      text: entry.value,
                                      speed: Duration(milliseconds: 20),
                                      style: TextStyle(
                                        fontSize: AppSizes.f14,
                                        color: AppTheme.secondary,
                                        height: 1.4,
                                      ),
                                      autoStart: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    )
                  : Center(
                      child: Text(
                        'Đang tải các bước thực hiện...',
                        style: TextStyle(
                          fontSize: AppSizes.f14,
                          color: AppTheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Code Examples Section với CodeViewer widget
  Widget _buildCodeExamplesSection(ProjectTopic topic) {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 800),
          child: SectionCard(
            title: 'Code mẫu & Hướng dẫn',
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: 120.h),
              child: topic.codeExamples.isNotEmpty
                  ? CodeExamplesSection(examples: topic.codeExamples)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.code,
                            size: 48,
                            color: AppTheme.secondary.withOpacity(0.5),
                          ),
                          SizedBox(height: AppSizes.p12),
                          Text(
                            'Đang tải code mẫu...',
                            style: TextStyle(
                              fontSize: AppSizes.f14,
                              color: AppTheme.secondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  /// Reference Links Section
  Widget _buildReferenceLinksSection(ProjectTopic topic) {
    if (topic.referenceLinks.isEmpty) return SizedBox.shrink();
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 900),
          child: SectionCard(
            title: 'Tài liệu tham khảo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topic.referenceLinks
                  .map(
                    (link) => _LinkTile(
                      title: link.title,
                      url: link.url,
                      icon: Icons.menu_book_rounded,
                      color: AppTheme.primary,
                      onTap: () => controller.openUrl(link.url),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Github Links Section
  Widget _buildGithubLinksSection(ProjectTopic topic) {
    if (topic.githubLinks.isEmpty) return SizedBox.shrink();
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        TypewriterAnimatedContainer(
          text: '',
          slideDelay: Duration(milliseconds: 950),
          child: SectionCard(
            title: 'Source code & Github',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topic.githubLinks
                  .map(
                    (link) => _LinkTile(
                      title: link.title,
                      url: link.url,
                      icon: Icons.code_rounded,
                      color: Colors.black87,
                      onTap: () => controller.openUrl(link.url),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Action Buttons Section
  Widget _buildActionButtonsSection() {
    return Column(
      children: [
        SizedBox(height: AppSizes.p16),
        SectionCard(
          title: 'Hành động',
          child: Column(
            children: [
              // Bắt đầu Dự án này (Start Project) button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.showProjectSetupDialog,
                  icon: Icon(Icons.rocket_launch),
                  label: Text('🚀 BẮT ĐẦU DỰ ÁN NÀY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFB6C1), // Light pink
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p12),

              // Tạo Checklist
              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton.icon(
              //     onPressed: () {
              //       // TODO: Implement create checklist
              //       Get.snackbar(
              //         'Tạo Checklist',
              //         'Tính năng sẽ được bổ sung sau',
              //         snackPosition: SnackPosition.BOTTOM,
              //       );
              //     },
              //     icon: Icon(Icons.rocket_launch),
              //     label: Text('🚀 TẠO CHECKLIST & BẮT ĐẦU DỰ ÁN'),
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Color(0xFFFFB6C1), // Light pink
              //       foregroundColor: Colors.black87,
              //       padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(AppSizes.r12),
              //       ),
              //       elevation: 2,
              //     ),
              //   ),
              // ),
              // SizedBox(height: AppSizes.p12),

              // Chia sẻ cho Team
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement share to team
                    Get.snackbar(
                      'Chia sẻ Team',
                      'Tính năng sẽ được bổ sung sau',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  icon: Icon(Icons.share),
                  label: Text('CHIA SHARE CHO TEAM MEMBER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC8D8FF), // Light blue
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p12),

              // Tạo Docs Notion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.createNotionDocs,
                  icon: Icon(Icons.description),
                  label: Text('TẠO DOCS DỰ ÁN VỚI NOTION'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFB8E6B8), // Light green
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(vertical: AppSizes.p16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p16),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom LinkTile widget for beautiful, modern clickable links
class _LinkTile extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _LinkTile({
    required this.title,
    required this.url,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: color.withOpacity(0.07),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15.r,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                color: color.withOpacity(0.7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
