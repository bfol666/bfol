import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Clean flat surface — replaces the old GlassContainer.
/// No blur, no glass border. Just a warm tinted card with a soft shadow.
class SurfaceContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Color? color;
  final bool hasShadow;

  const SurfaceContainer({
    super.key,
    required this.child,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.all(18),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.color,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
