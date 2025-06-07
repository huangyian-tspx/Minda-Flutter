// CustomChoiceChipGroup: Hiển thị nhóm FilterChip với logic "Thêm khác".
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomChoiceChipGroup extends StatelessWidget {
  final RxSet<String> selectedItems;
  final List<String> options;
  CustomChoiceChipGroup({Key? key, required this.selectedItems, required this.options}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // allOptions chứa các lựa chọn gốc + các lựa chọn thêm mới
    final RxList<String> allOptions = options.obs;
    final TextEditingController controller = TextEditingController();

    // Hiển thị dialog nhập "Thêm khác"
    void showAddOtherDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Thêm khác'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nhập nội dung...'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    allOptions.add(controller.text.trim());
                    selectedItems.add(controller.text.trim());
                    controller.clear();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      );
    }

    return Obx(() => Wrap(
          spacing: 8,
          children: [
            // Hiển thị các chip lựa chọn
            ...allOptions.map((option) => FilterChip(
                  label: Text(option),
                  selected: selectedItems.contains(option),
                  onSelected: (selected) {
                    if (selected) {
                      selectedItems.add(option);
                    } else {
                      selectedItems.remove(option);
                    }
                  },
                  // Nếu là chip thêm mới thì cho phép xóa
                  onDeleted: options.contains(option)
                      ? null
                      : () {
                          selectedItems.remove(option);
                          allOptions.remove(option);
                        },
                  deleteIcon: options.contains(option) ? null : const Icon(Icons.close, size: 18),
                )),
            // Chip "Thêm khác"
            FilterChip(
              label: const Text('Thêm khác'),
              avatar: const Icon(Icons.edit, size: 18),
              selected: false,
              onSelected: (_) => showAddOtherDialog(),
            ),
          ],
        ));
  }
}
