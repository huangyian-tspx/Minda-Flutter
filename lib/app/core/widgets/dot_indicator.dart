import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class DotIndicator extends StatelessWidget {
  final int pageCount;
  final RxInt currentPage;
  final Color? activeColor;
  final Color? inactiveColor;

  const DotIndicator({
    Key? key,
    required this.pageCount,
    required this.currentPage,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final isActive = index == currentPage.value;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 6.w),
            width: isActive ? 18.w : 8.w,
            height: isActive ? 18.w : 8.w,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.transparent
                  : (inactiveColor ?? AppTheme.primary.withOpacity(0.7)),
              border: isActive
                  ? Border.all(
                      color: activeColor ?? AppTheme.primary,
                      width: 2.2.w,
                    )
                  : null,
              shape: BoxShape.circle,
            ),
            child: isActive
                ? Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: (activeColor ?? AppTheme.primary).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          );
        }),
      ),
    );
  }
}
