import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSegmentedControl extends StatelessWidget {
  final RxList<String> defaultOptions;
  final RxList<String> customOptions;
  final RxString selectedOption;
  final void Function(String) onSelect;
  final void Function(String) onAdd;
  final void Function(String) onRemove;
  final VoidCallback onShowAddDialog;

  const CustomSegmentedControl({
    Key? key,
    required this.defaultOptions,
    required this.customOptions,
    required this.selectedOption,
    required this.onSelect,
    required this.onAdd,
    required this.onRemove,
    required this.onShowAddDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chipTheme = Theme.of(context).chipTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() => Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            ...defaultOptions.map((option) => FilterChip(
                  label: Text(option),
                  selected: selectedOption.value == option,
                  onSelected: (_) => onSelect(option),
                  backgroundColor: Colors.grey[200],
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selectedOption.value == option
                        ? colorScheme.onPrimary
                        : colorScheme.secondary,
                  ),
                  shape: chipTheme.shape,
                  side: BorderSide.none,
                )),
            ...customOptions.map((option) => FilterChip(
                  label: Text(option),
                  selected: selectedOption.value == option,
                  onSelected: (_) => onSelect(option),
                  backgroundColor: Colors.grey[200],
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: selectedOption.value == option
                        ? colorScheme.onPrimary
                        : colorScheme.secondary,
                  ),
                  shape: chipTheme.shape,
                  side: BorderSide.none,
                  onDeleted: () => onRemove(option),
                  deleteIcon: const Icon(Icons.close, size: 18),
                )),
            FilterChip(
              label: const Text('Thêm khác'),
              avatar: const Icon(Icons.edit, size: 18),
              selected: false,
              onSelected: (_) => onShowAddDialog(),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(color: colorScheme.secondary),
              shape: chipTheme.shape,
              side: BorderSide.none,
            ),
          ],
        ));
  }
} 