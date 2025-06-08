import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.height = 48,
    this.borderRadius = 32,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            const Color(0xFF1DE9B6), // Màu xanh ngọc gradient
            const Color(0xFF1DE9B6),
            AppTheme.primary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        height: height,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Material(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed,
            child: Container(
              height: height,
              alignment: Alignment.center,
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              child: DefaultTextStyle(
                style: theme.textTheme.titleMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 