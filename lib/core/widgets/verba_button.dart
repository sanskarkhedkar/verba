import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class VerbaButton extends StatefulWidget {
  const VerbaButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.secondary = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  State<VerbaButton> createState() => _VerbaButtonState();
}

class _VerbaButtonState extends State<VerbaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed?.call();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1 : 0.45,
          duration: const Duration(milliseconds: 160),
          child: Container(
            height: 52,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.secondary ? AppColors.bgElevated : null,
              gradient: widget.secondary ? null : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: widget.secondary
                  ? Border.all(color: AppColors.glassBorder)
                  : null,
              boxShadow: widget.secondary
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primaryStart.withValues(alpha: 0.28),
                        blurRadius: 24,
                      ),
                    ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: AppColors.textPrimary),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
