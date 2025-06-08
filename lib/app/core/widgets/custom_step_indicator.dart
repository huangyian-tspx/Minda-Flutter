import 'package:flutter/material.dart';
import 'package:mind_ai_app/app/core/theme/app_theme.dart';

class CustomStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  const CustomStepIndicator({
    Key? key,
    required this.totalSteps,
    required this.currentStep,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}
