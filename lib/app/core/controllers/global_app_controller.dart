import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/services/network_connectivity_service.dart';
import '../../di.dart';
import '../utils/app_logger.dart';

class GlobalAppController extends GetxController {
  final _connectivityService = sl<NetworkConnectivityService>();
  bool _isDialogShown = false;

  @override
  void onInit() {
    super.onInit();
    ever(_connectivityService.isConnected, _handleConnectivityChange);
  }

  void _handleConnectivityChange(bool isConnected) {
    if (!isConnected && !_isDialogShown) {
      _isDialogShown = true;
      AppLogger.e("Network connection lost. Showing dialog.");
      Get.dialog(_buildRetryDialog(), barrierDismissible: false).then((_) {
        _isDialogShown = false;
      });
    } else if (isConnected && _isDialogShown) {
      AppLogger.i("Network connection restored. Closing dialog.");
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  Widget _buildRetryDialog() {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        backgroundColor: const Color(0xFFF8FBFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 32,
          horizontal: 24,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 64, color: Color(0xFFB0C4DE)),
            const SizedBox(height: 16),
            const Text(
              'Ooops!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B3A67),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'It seems there is something\nwrong with your internet connection.\nPlease connect to the internet & start again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7A99)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23262F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  AppLogger.i("User tapped 'Retry' button.");
                  final isNowConnected = await _connectivityService
                      .retryConnectionCheck();
                  if (!isNowConnected) {
                    Get.rawSnackbar(
                      message: "Still no connection...",
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
                child: const Text(
                  "Try Again",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
