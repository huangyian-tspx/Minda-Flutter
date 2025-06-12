import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../values/app_sizes.dart';

class FloatingMenu extends StatefulWidget {
  const FloatingMenu({Key? key}) : super(key: key);

  @override
  State<FloatingMenu> createState() => _FloatingMenuState();
}

class _FloatingMenuState extends State<FloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _onMenuItemTap(VoidCallback onTap) {
    _toggleMenu();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay
        if (_isOpen) GestureDetector(onTap: _toggleMenu, child: Container()),

        // Menu items
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen) ...[
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMenuItem(
                  icon: Icons.favorite,
                  label: 'Dự án yêu thích',
                  color: Colors.red,
                  onTap: () => _onMenuItemTap(() {
                    Get.toNamed(Routes.FAVORITES);
                  }),
                ),
              ),
              SizedBox(height: AppSizes.p8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMenuItem(
                  icon: Icons.history,
                  label: 'Lịch sử dự án',
                  color: Colors.blue,
                  onTap: () => _onMenuItemTap(() {
                    Get.toNamed(Routes.PROJECT_HISTORY);
                  }),
                ),
              ),
              SizedBox(height: AppSizes.p8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMenuItem(
                  icon: Icons.description,
                  label: 'Notion đã tạo',
                  color: Colors.purple,
                  onTap: () => _onMenuItemTap(() {
                    Get.toNamed(Routes.NOTION_HISTORY);
                  }),
                ),
              ),
              SizedBox(height: AppSizes.p8),
              ScaleTransition(
                scale: _scaleAnimation,
                child: _buildMenuItem(
                  icon: Icons.add_circle,
                  label: 'Tạo đề xuất mới',
                  color: Colors.green,
                  onTap: () => _onMenuItemTap(() {
                    Get.offAllNamed(Routes.INFORMATION_INPUT);
                  }),
                ),
              ),
              SizedBox(height: AppSizes.p12),
            ],

            // Main FAB
            FloatingActionButton(
              onPressed: _toggleMenu,
              backgroundColor: Colors.transparent,
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isOpen ? Icons.close : Icons.menu,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(AppSizes.r8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.r8),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.p12,
                vertical: AppSizes.p8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppSizes.p12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(icon, color: color, size: 24),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
