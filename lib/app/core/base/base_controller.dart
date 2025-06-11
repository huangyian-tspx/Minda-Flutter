import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../values/app_enums.dart';

class BaseController extends GetxController {
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  void showLoading() => _isLoading.value = true;
  void hideLoading() => _isLoading.value = false;

  void handleAppBarAction(PopupMenuAction action) {
    switch (action) {
      case PopupMenuAction.changeTheme:
        // TODO: Implement theme change logic
        break;
      case PopupMenuAction.changeLanguage:
        // TODO: Implement language change logic
        break;
      case PopupMenuAction.historyNotion:
        Get.toNamed(Routes.NOTION_HISTORY);
        break;
      default:
        // Child controllers can override
        break;
    }
  }
}
