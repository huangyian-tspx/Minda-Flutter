import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';
import '../values/app_sizes.dart';

enum FloatingMenuAction { favorites, history, notionHistory, createProject }

class GlobalFloatingMenu extends StatefulWidget {
  const GlobalFloatingMenu({Key? key}) : super(key: key);

  @override
  State<GlobalFloatingMenu> createState() => _GlobalFloatingMenuState();
}

class _GlobalFloatingMenuState extends State<GlobalFloatingMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    Future.delayed(const Duration(milliseconds: 100), onTap);
  }

  void _handleMenuAction(FloatingMenuAction action) {
    AppLogger.d("Floating menu action selected: $action");
    _toggleMenu(); // Close menu first

    switch (action) {
      case FloatingMenuAction.favorites:
        Get.toNamed(Routes.FAVORITES);
        break;
      case FloatingMenuAction.history:
        Get.toNamed(Routes.PROJECT_HISTORY);
        break;
      case FloatingMenuAction.notionHistory:
        Get.toNamed(Routes.NOTION_HISTORY);
        break;
      case FloatingMenuAction.createProject:
        Get.offAllNamed(Routes.INFORMATION_INPUT);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Background overlay with blur effect
        if (_isOpen) GestureDetector(onTap: _toggleMenu, child: Container()),
        if (_isOpen)
          FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                // decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                child: BackdropFilter(
                  filter:
                      // ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                      ColorFilter.mode(
                        Colors.black.withOpacity(0.1),
                        BlendMode.multiply,
                      ),
                  child: Container(),
                ),
              ),
            ),
          ),

        // Menu items
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen) ...[
              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.5, 0.5),
                    end: Offset.zero,
                  ).animate(_scaleAnimation),
                  child: _buildMenuItem(
                    icon: Icons.favorite,
                    label: 'Dự án yêu thích',
                    color: Colors.red.shade400,
                    onTap: () => _onMenuItemTap(() {
                      _handleMenuAction(FloatingMenuAction.favorites);
                    }),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p12),

              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.4, 0.4),
                    end: Offset.zero,
                  ).animate(_scaleAnimation),
                  child: _buildMenuItem(
                    icon: Icons.history,
                    label: 'Lịch sử dự án',
                    color: Colors.blue.shade400,
                    onTap: () => _onMenuItemTap(() {
                      _handleMenuAction(FloatingMenuAction.history);
                    }),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p12),

              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.3, 0.3),
                    end: Offset.zero,
                  ).animate(_scaleAnimation),
                  child: _buildMenuItem(
                    icon: Icons.description,
                    label: 'Notion đã tạo',
                    color: Colors.purple.shade400,
                    onTap: () => _onMenuItemTap(() {
                      _handleMenuAction(FloatingMenuAction.notionHistory);
                    }),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p12),

              ScaleTransition(
                scale: _scaleAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.2, 0.2),
                    end: Offset.zero,
                  ).animate(_scaleAnimation),
                  child: _buildMenuItem(
                    icon: Icons.add_circle,
                    label: 'Tạo đề xuất mới',
                    color: Colors.green.shade400,
                    onTap: () => _onMenuItemTap(() {
                      _handleMenuAction(FloatingMenuAction.createProject);
                    }),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.p16),
            ],

            // Main FAB with improved design
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: _toggleMenu,
                backgroundColor: AppTheme.primary,
                elevation: 0,
                child: AnimatedRotation(
                  turns: _isOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isOpen ? Icons.close : Icons.menu,
                    color: Colors.white,
                    size: 28.sp,
                  ),
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
        // Label container with improved design
        Container(
          margin: EdgeInsets.only(right: AppSizes.p12),
          padding: EdgeInsets.symmetric(
            horizontal: AppSizes.p16,
            vertical: AppSizes.p12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.r12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),

        // Icon button with improved design
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.8), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.all(4.w),
                child: Icon(icon, color: Colors.white, size: 24.sp),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
