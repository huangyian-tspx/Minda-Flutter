import 'package:get/get.dart';

import '../modules/01_information_input/information_input_binding.dart';
import '../modules/01_information_input/information_input_view.dart';
import '../modules/02_refinement/refinement_binding.dart';
import '../modules/02_refinement/refinement_view.dart';
import '../modules/03_suggestion_list/suggestion_list_binding.dart';
import '../modules/03_suggestion_list/suggestion_list_view.dart';
import '../modules/04_project_detail/project_detail_binding.dart';
import '../modules/04_project_detail/project_detail_view.dart';
import '../modules/ai_thinking/ai_thinking_binding.dart';
import '../modules/ai_thinking/ai_thinking_view.dart';
import '../modules/demo_scroll_to_top.dart';
import '../modules/notion_history/notion_history_controller.dart';
import '../modules/notion_history/notion_history_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.INFORMATION_INPUT,
      page: () => const InformationInputView(),
      binding: InformationInputBinding(),
    ),
    GetPage(
      name: Routes.REFINEMENT,
      page: () => const RefinementView(),
      binding: RefinementBinding(),
    ),
    GetPage(
      name: Routes.AI_THINKING,
      page: () => const AIThinkingView(),
      binding: AIThinkingBinding(),
    ),
    GetPage(
      name: Routes.SUGGESTION_LIST,
      page: () => const SuggestionListView(),
      binding: SuggestionListBinding(),
    ),
    GetPage(
      name: Routes.PROJECT_DETAIL,
      page: () => const ProjectDetailView(),
      binding: ProjectDetailBinding(),
    ),
    GetPage(
      name: Routes.DEMO,
      page: () => const CodeViewerDemoView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CodeViewerDemoController());
      }),
    ),
    GetPage(
      name: Routes.NOTION_HISTORY,
      page: () => NotionHistoryView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotionHistoryController());
      }),
    ),
  ];
}
