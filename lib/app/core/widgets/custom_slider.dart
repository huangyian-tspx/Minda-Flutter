import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSlider extends StatelessWidget {
  final RxDouble currentValue;
  final double min;
  final double max;
  final void Function(double) onChanged;
  final List<String> marks;

  const CustomSlider({
    Key? key,
    required this.currentValue,
    required this.onChanged,
    this.marks = const ['Nhanh', '3 tháng', '6+ tháng'],
    this.min = 1,
    this.max = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Slider(
              value: currentValue.value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              label: "${currentValue.value.toInt()}m",
              onChanged: onChanged,
              activeColor: colorScheme.primary,
              inactiveColor: Colors.grey[300],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: marks
                  .map((e) => Text(
                        e,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.secondary),
                      ))
                  .toList(),
            ),
          ],
        ));
  }
} 