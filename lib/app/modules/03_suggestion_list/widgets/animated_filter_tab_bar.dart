import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mind_ai_app/app/core/theme/app_theme.dart';

import '../suggestion_list_controller.dart';

class AnimatedFilterTabBar extends GetView<SuggestionListController> {
  final List<String> tabs;
  final Duration animationDuration;
  final double activeFontSize;
  final double inactiveFontSize;

  const AnimatedFilterTabBar({
    Key? key,
    this.tabs = const ['An Toàn', 'Thử thách'],
    this.animationDuration = const Duration(milliseconds: 300),
    this.activeFontSize = 20,
    this.inactiveFontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabCount = tabs.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Obx(() {
        final selectedIndex =
            controller.selectedFilter.value == SuggestionFilter.safe ? 0 : 1;
        
        // Get counts for each category
        final safeCount = controller.aiResponseData.value?.safeProjects.length ?? 0;
        final challengingCount = controller.aiResponseData.value?.challengingProjects.length ?? 0;
        final counts = [safeCount, challengingCount];
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(tabCount, (i) {
            final isSelected = selectedIndex == i;
            final count = counts[i];
            final displayText = count > 0 ? '${tabs[i]} ($count)' : tabs[i];
            
            return GestureDetector(
              onTap: () => controller.onFilterChanged(
                i == 0 ? SuggestionFilter.safe : SuggestionFilter.challenging,
              ),
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(
                  right: i < tabCount - 1 ? 20 : 0,
                ), // Add spacing between tabs
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.15 : 1.0,
                  duration: animationDuration,
                  curve: Curves.easeInOut,
                  child: AnimatedDefaultTextStyle(
                    duration: animationDuration,
                    curve: Curves.easeInOut,
                    style: TextStyle(
                      fontSize: isSelected ? activeFontSize : inactiveFontSize,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? AppTheme.primary : AppTheme.secondary,
                    ),
                    child: Text(displayText),
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
