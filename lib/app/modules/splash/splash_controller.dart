import 'package:get/get.dart';

import '../../core/base/base_controller.dart';
import '../../core/utils/app_logger.dart';
import '../../data/services/local_storage_service.dart';
import '../../di.dart';
import '../../routes/app_routes.dart';

class SplashController extends BaseController {
  final _localStorage = sl<LocalStorageService>();

  @override
  void onReady() {
    super.onReady();
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() async {
    // Đợi animation của Splash kết thúc
    await Future.delayed(const Duration(seconds: 3));

    final hasSeenOnboarding =
        _localStorage.readData<bool>('has_seen_onboarding') ?? false;

    AppLogger.d("Has seen onboarding: $hasSeenOnboarding");
    Get.offAllNamed(Routes.ONBOARDING);
    // if (hasSeenOnboarding) {
    //   AppLogger.d("Navigating to Information Input");
    //   Get.offAllNamed(Routes.INFORMATION_INPUT);
    // } else {
    //   AppLogger.d("Navigating to Onboarding");
    //   Get.offAllNamed(Routes.ONBOARDING);
    // }
  }
}
