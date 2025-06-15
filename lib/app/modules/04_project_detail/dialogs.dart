import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/values/app_sizes.dart';
import '../../core/widgets/custom_chip.dart';

/// Loading dialog với message
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Loading animation
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 20),
              
              // Message
              Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 12),
              
              // Sub message
              Text(
                'Vui lòng không tắt ứng dụng',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Success dialog với message và action buttons
class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;
  final VoidCallback? onCopyPressed;

  const SuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
    this.onCopyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Copy button (if onCopyPressed is provided)
                if (onCopyPressed != null)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onCopyPressed,
                      icon: Icon(Icons.copy, size: 18),
                      label: Text('Copy Link'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.secondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                
                if (onCopyPressed != null) SizedBox(width: 12),
                
                // Main action button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPressed,
                    icon: Icon(Icons.open_in_new, size: 18),
                    label: Text(buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Error dialog với message
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  const ErrorDialog({
    Key? key,
    required this.title,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 20),
            
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            
            // Close button
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('Đóng'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog hiển thị khi đã có Notion document cho project này
class ExistingNotionDialog extends StatelessWidget {
  final String title;
  final String existingUrl;
  final VoidCallback onOpenExisting;
  final VoidCallback onViewHistory;
  final VoidCallback onCreateNew;

  const ExistingNotionDialog({
    Key? key,
    required this.title,
    required this.existingUrl,
    required this.onOpenExisting,
    required this.onViewHistory,
    required this.onCreateNew,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r16),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.p24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.r16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon and title
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.info_outline,
                size: 30.sp,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: AppSizes.p16),
            
            Text(
              'Document đã tồn tại',
              style: TextStyle(
                fontSize: AppSizes.f18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.p12),
            
            Text(
              'Bạn đã tạo document Notion cho dự án này rồi. Bạn muốn làm gì?',
              style: TextStyle(
                fontSize: AppSizes.f14,
                color: AppTheme.secondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSizes.p24),
            
            // Action buttons
            Column(
              children: [
                // Open existing button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onOpenExisting,
                    icon: Icon(Icons.open_in_new, size: 18.sp),
                    label: Text('Mở document hiện có'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.p12),
                
                // View history button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onViewHistory,
                    icon: Icon(Icons.history, size: 18.sp),
                    label: Text('Xem lịch sử Notion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.p12),
                
                // Create new button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCreateNew,
                    icon: Icon(Icons.add_circle_outline, size: 18.sp),
                    label: Text('Tạo document mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSizes.p14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                
                SizedBox(height: AppSizes.p12),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: AppTheme.secondary,
                        fontSize: AppSizes.f14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectPhase {
  String name;
  List<String> deliverables;
  ProjectPhase({required this.name, required this.deliverables});
}

class ProjectSetupDialog extends StatefulWidget {
  final List<ProjectPhase> initialPhases;
  const ProjectSetupDialog({Key? key, required this.initialPhases}) : super(key: key);

  @override
  State<ProjectSetupDialog> createState() => _ProjectSetupDialogState();
}

class _ProjectSetupDialogState extends State<ProjectSetupDialog> {
  late List<TextEditingController> _phaseControllers;
  late List<RxSet<String>> _selectedDeliverables;
  late List<RxList<String>> _allDeliverables;

  @override
  void initState() {
    super.initState();
    _phaseControllers = widget.initialPhases
        .map((p) => TextEditingController(text: p.name))
        .toList();
    _selectedDeliverables = widget.initialPhases
        .map((p) => p.deliverables.toSet().obs)
        .toList();
    _allDeliverables = widget.initialPhases
        .map((p) => p.deliverables.toList().obs)
        .toList();
  }

  @override
  void dispose() {
    for (final c in _phaseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onConfirm() {
    final phases = List.generate(_phaseControllers.length, (i) =>
      ProjectPhase(
        name: _phaseControllers[i].text.trim(),
        deliverables: _selectedDeliverables[i].toList(),
      ),
    );
    Navigator.of(context).pop(phases);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tùy chỉnh các giai đoạn & deliverables',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 16),
              ...List.generate(widget.initialPhases.length, (i) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phaseControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Tên giai đoạn',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  CustomChoiceChipGroup(
                    selectedItems: _selectedDeliverables[i],
                    options: _allDeliverables[i],
                  ),
                  SizedBox(height: 20),
                ],
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Hủy'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _onConfirm,
                    child: Text('Tạo Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}