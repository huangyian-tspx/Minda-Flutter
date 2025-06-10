import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/values/app_enums.dart';
import '../../core/values/app_sizes.dart';
import '../../core/widgets/index.dart';
import '../../data/models/topic_suggestion_model.dart';
import 'project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: CustomAppBar(
        title: 'Chi tiết dự án',
        isWantShowBackButton: true,
        popupActions: [PopupMenuAction.settings],
        onPopupActionSelected: (action) {},
      ),
      body: Obx(() {
        final topic = controller.topic.value;
        if (topic == null) {
          return const Center(child: Text('Không có dữ liệu dự án'));
        }

        return SingleChildScrollView(
          controller: controller.scrollController,
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(topic),
                SizedBox(height: AppSizes.p16),

                // Overview Section
                _buildOverviewSection(topic),

                // Tech Stack Section
                _buildTechStackSection(topic),

                // Features Section
                _buildFeaturesSection(topic),

                // Knowledge Section
                _buildKnowledgeSection(topic),

                // Action Buttons Section
                _buildActionButtonsSection(),

                SizedBox(height: AppSizes.p24),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: const ScrollToTopFab<ProjectDetailController>(),
    );
  }

  /// Widget Header Section - Hiển thị title của dự án
  Widget _buildHeaderSection(ProjectTopic topic) {
    return Container(
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

  /// Widget Overview Section - Hiển thị vấn đề và hướng tiếp cận
  Widget _buildOverviewSection(ProjectTopic topic) {
    return SectionCard(
      title: 'Tổng quan dự án',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vấn đề cần giải quyết
          Text(
            'Vấn đề cần giải quyết',
            style: TextStyle(
              fontSize: AppSizes.f16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            topic.problemStatement,
            style: TextStyle(
              fontSize: AppSizes.f14,
              color: AppTheme.secondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSizes.p16),

          // Hướng tiếp cận
          Text(
            'Hướng tiếp cận của dự án',
            style: TextStyle(
              fontSize: AppSizes.f16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          Text(
            topic.proposedSolution,
            style: TextStyle(
              fontSize: AppSizes.f14,
              color: AppTheme.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget Tech Stack Section - Hiển thị công nghệ và nút gợi ý
  Widget _buildTechStackSection(ProjectTopic topic) {
    return SectionCard(
      title: 'Công nghệ sử dụng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSizes.p8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                ),
                child: Icon(Icons.code, size: 24, color: AppTheme.primary),
              ),
              SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gợi ý thư viện & công cụ phù hợp',
                      style: TextStyle(
                        fontSize: AppSizes.f16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    SizedBox(height: AppSizes.p4),
                    ElevatedButton.icon(
                      onPressed: controller.suggestLibraries,
                      icon: Icon(Icons.lightbulb_outline, size: 18),
                      label: Text('Gợi ý thư viện...'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.r8),
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
          Wrap(
            spacing: AppSizes.p8,
            runSpacing: AppSizes.p8,
            children: topic.coreTechStack
                .map(
                  (tech) => Chip(
                    label: Text(tech),
                    backgroundColor: AppTheme.chipInactive,
                    labelStyle: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Widget Features Section - Hiển thị tính năng core và advanced
  Widget _buildFeaturesSection(ProjectTopic topic) {
    return SectionCard(
      title: 'Kiến thức nền tảng cần có',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Core Features
          Text(
            'Kiến thức cơ bản',
            style: TextStyle(
              fontSize: AppSizes.f16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          if (topic.coreFeatures.isNotEmpty)
            AnimatedExpandableList(
              items: topic.coreFeatures,
              controller: controller.coreFeaturesController,
            ),

          SizedBox(height: AppSizes.p16),

          // Advanced Features
          Text(
            'Hiểu biết về API',
            style: TextStyle(
              fontSize: AppSizes.f16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
          SizedBox(height: AppSizes.p8),
          if (topic.advancedFeatures.isNotEmpty)
            AnimatedExpandableList(
              items: topic.advancedFeatures,
              controller: controller.advancedFeaturesController,
            ),
        ],
      ),
    );
  }

  /// Widget Knowledge Section - Hiển thị kiến thức cơ bản và cụ thể
  Widget _buildKnowledgeSection(ProjectTopic topic) {
    return SectionCard(
      title: 'Kiến thức nền tảng cần có',
      child: Column(
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
            Wrap(
              spacing: AppSizes.p8,
              runSpacing: AppSizes.p8,
              children: topic.foundationalKnowledge
                  .map(
                    (knowledge) => Card(
                      elevation: 1,
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
            Column(
              children: topic.specificKnowledge
                  .map(
                    (knowledge) =>
                        KnowledgeDifficultyCard(knowledgeItem: knowledge),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  /// Widget Action Buttons Section - Các nút hành động
  Widget _buildActionButtonsSection() {
    return SectionCard(
      title: 'Hành động',
      child: Column(
        children: [
          // Tạo Checklist
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.createChecklist,
              icon: Icon(Icons.rocket_launch),
              label: Text('🚀 TẠO CHECKLIST & BẮT ĐẦU DỰ ÁN'),
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

          // Chia sẻ cho Team
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.shareToTeam,
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
        ],
      ),
    );
  }
}
