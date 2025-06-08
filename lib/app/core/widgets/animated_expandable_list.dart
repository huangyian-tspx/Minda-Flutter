import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/04_project_detail/expandable_item_data.dart';
import '../../modules/04_project_detail/expandable_list_controller.dart';
import '../theme/app_theme.dart';
import '../values/app_sizes.dart';

class AnimatedExpandableList extends StatelessWidget {
  final List<ExpandableItemData> items;
  final ExpandableListController controller;

  const AnimatedExpandableList({
    Key? key,
    required this.items,
    required this.controller,
  }) : super(key: key);

  void _showDetailBottomSheet(BuildContext context, String title, String content) {
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: AppTheme.chipInactive),
      itemBuilder: (context, index) {
        return _ExpandableItem(
          item: items[index],
          index: index,
          controller: controller,
          onShowDetail: (title, content) => _showDetailBottomSheet(context, title, content),
        );
      },
    );
  }
}

class _ExpandableItem extends StatelessWidget {
  final ExpandableItemData item;
  final int index;
  final ExpandableListController controller;
  final void Function(String, String) onShowDetail;

  const _ExpandableItem({
    Key? key,
    required this.item,
    required this.index,
    required this.controller,
    required this.onShowDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedIndex.value == index;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: () => controller.toggleItem(index),
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSizes.p12, horizontal: AppSizes.p8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onShowDetail('Chi tiết', item.title),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: AppSizes.f16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(Icons.keyboard_arrow_down, color: AppTheme.primary, size: 28),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.only(
                      left: AppSizes.p8,
                      right: AppSizes.p8,
                      bottom: AppSizes.p12,
                    ),
                    child: GestureDetector(
                      onTap: () => onShowDetail('Nội dung', item.content),
                      child: Text(
                        item.content,
                        style: TextStyle(
                          fontSize: AppSizes.f14,
                          color: AppTheme.secondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
} 