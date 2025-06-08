import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_ai_app/app/core/widgets/index.dart';

import '../../data/models/topic_suggestion_model.dart';
import '../../modules/03_suggestion_list/suggestion_list_controller.dart';
import '../theme/app_theme.dart';
import '../values/app_sizes.dart';

class SuggestionProjectCard extends StatelessWidget {
  final Topic topic;
  final double? matchScore; // 0.0 - 1.0, optional for demo
  final int? duration; // months, optional for demo

  const SuggestionProjectCard({
    Key? key,
    required this.topic,
    this.matchScore,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SuggestionListController>();
    return InkWell(
      borderRadius: BorderRadius.circular(AppSizes.r12),
      onTap: () => controller.onTopicCardTapped(topic),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        elevation: 3,
        margin: EdgeInsets.zero,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: Title + Bookmark
              GestureDetector(
                onTap: () =>
                    _showDetailBottomSheet(context, 'Tên dự án', topic.title),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        topic.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ) ??
                            const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Bookmark icon
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.isFavorite(topic.id)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: controller.isFavorite(topic.id)
                              ? AppTheme.primary
                              : AppTheme.secondary,
                        ),
                        onPressed: () => controller.toggleFavorite(topic.id),
                        splashRadius: 22,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.p8),
              // Tech tags
              Wrap(
                spacing: AppSizes.p8,
                runSpacing: AppSizes.p4,
                children: topic.technologies
                    .map(
                      (tech) => GestureDetector(
                        onTap: () =>
                            _showDetailBottomSheet(context, 'Công nghệ', tech),
                        child: Chip(
                          label: Text(
                            tech,
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                            ),
                          ),
                          backgroundColor: AppTheme.chipInactive,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSizes.p16),

              // Middle row: Progress card
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Thiết kế 1 text là [icon] Độ phù hợp với bạn [icon mũi tên chỉ sang progres]
                  Flexible(
                    child: Row(
                      children: [
                        Icon(
                          Icons.design_services_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppSizes.p8),
                        StyledText('Độ phù hợp với bạn', isMain: false),
                        SizedBox(width: AppSizes.p8),
                        Icon(
                          Icons.arrow_circle_right_rounded,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 0,
                    child: GestureDetector(
                      onTap: () => _showDetailBottomSheet(
                        context,
                        'Độ phù hợp',
                        '${((matchScore ?? 0.85) * 100).toStringAsFixed(0)}% phù hợp với bạn dựa trên AI',
                      ),
                      child: CustomProgressCard(
                        progressValue: (matchScore ?? 0.85).clamp(0.0, 1.0),
                        size: 56,
                        strokeWidth: 7,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                        gradientColors: [AppTheme.primary, AppTheme.secondary],
                      ),
                    ),
                  ),
                ],
              ),
              // --- Useful info section in the gap ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blueGrey[100]!, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blueGrey,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tóm tắt: ${topic.description}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: Colors.blueGrey,
                          size: 18,
                        ),
                        onPressed: () => _showDetailBottomSheet(
                          context,
                          'Tóm tắt dự án',
                          topic.description,
                        ),
                        tooltip: 'Xem chi tiết',
                      ),
                    ],
                  ),
                ),
              ),
              // --- End useful info section ---
              // Bottom row: Duration + Difficulty
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _showDetailBottomSheet(
                        context,
                        'Thời gian thực hiện',
                        '${duration ?? 3} months',
                      ),
                      child: Chip(
                        avatar: const Icon(
                          Icons.timer_outlined,
                          size: 18,
                          color: AppTheme.primary,
                        ),
                        label: Text(
                          '${duration ?? 3} months',
                          style: Theme.of(context).chipTheme.labelStyle,
                        ),
                        backgroundColor: AppTheme.chipInactive,
                        shape: Theme.of(context).chipTheme.shape,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    SizedBox(width: AppSizes.p8),
                    // Difficulty chip with ellipsis and info button
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = 200.0;
                        final isLong = topic.difficulty.length > 18;
                        return GestureDetector(
                          onTap: () => _showDetailBottomSheet(
                            context,
                            'Độ khó',
                            topic.difficulty,
                          ),
                          child: Container(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    topic.difficulty,
                                    style: Theme.of(
                                      context,
                                    ).chipTheme.labelStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isLong)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppTheme.primary,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _showDetailBottomSheet(
                                      context,
                                      'Độ khó',
                                      topic.difficulty,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(
    BuildContext context,
    String title,
    String content,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(content, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
