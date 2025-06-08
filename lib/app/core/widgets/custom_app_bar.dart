import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';
import '../values/app_enums.dart';
import '../values/app_sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<PopupMenuAction> popupActions;
  final Function(PopupMenuAction) onPopupActionSelected;
  final bool isWantShowBackButton;

  const CustomAppBar({
    Key? key,
    this.title,
    required this.popupActions,
    required this.onPopupActionSelected,
    this.isWantShowBackButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              if ((isWantShowBackButton))
                Padding(
                  padding: EdgeInsets.only(right: AppSizes.p8),
                  child: Material(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                      onTap: () => Get.back(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              // Title
              if (title != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      title!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Heart icon (optional, can be controlled by popupActions)
                  if (popupActions.contains(PopupMenuAction.favoriteProjects))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onPopupActionSelected(
                            PopupMenuAction.favoriteProjects,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Settings icon with popup menu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: PopupMenuButton<PopupMenuAction>(
                        onSelected: onPopupActionSelected,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.black,
                          size: 22,
                        ),
                        color: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (BuildContext context) {
                          return popupActions
                              .map((action) {
                                if (action == PopupMenuAction.favoriteProjects)
                                  return null;
                                return PopupMenuItem<PopupMenuAction>(
                                  value: action,
                                  child: _AnimatedMenuItem(
                                    icon: _getMenuIcon(action),
                                    text: _getMenuTitle(action),
                                  ),
                                );
                              })
                              .whereType<PopupMenuItem<PopupMenuAction>>()
                              .toList();
                        },
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

  String _getMenuTitle(PopupMenuAction action) {
    switch (action) {
      case PopupMenuAction.restartFromBeginning:
        return 'Option 1';
      case PopupMenuAction.settings:
        return 'Option 2';
      case PopupMenuAction.favoriteProjects:
        return 'Option 3';
      case PopupMenuAction.changeLanguage:
        return 'Option 4';
      case PopupMenuAction.changeTheme:
        return 'Option 5';
    }
  }

  Widget _getMenuIcon(PopupMenuAction action) {
    switch (action) {
      case PopupMenuAction.restartFromBeginning:
        return const Icon(Icons.threed_rotation, color: Colors.grey, size: 24);
      case PopupMenuAction.settings:
        return const Icon(Icons.diamond_outlined, color: Colors.grey, size: 24);
      case PopupMenuAction.favoriteProjects:
        return const Icon(Icons.favorite, color: Colors.grey, size: 24);
      case PopupMenuAction.changeLanguage:
        return const Icon(Icons.language, color: Colors.grey, size: 24);
      case PopupMenuAction.changeTheme:
        return const Icon(
          Icons.dark_mode_outlined,
          color: Colors.grey,
          size: 24,
        );
    }
  }
}

class _AnimatedMenuItem extends StatelessWidget {
  final Widget icon;
  final String text;
  const _AnimatedMenuItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: icon,
        ),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ],
    );
  }
}
