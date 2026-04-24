import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MascotWidget extends StatefulWidget {
  const MascotWidget(
      {super.key, this.size = 120, this.state = MascotState.idle});

  final double size;
  final MascotState state;

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

enum MascotState { idle, listening, thinking, success, warning, error }

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.state) {
      MascotState.success => AppColors.success,
      MascotState.warning => AppColors.warning,
      MascotState.error => AppColors.error,
      MascotState.listening => AppColors.info,
      MascotState.thinking => AppColors.textAccent,
      MascotState.idle => AppColors.primaryEnd,
    };

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final dy = widget.state == MascotState.idle
            ? (_controller.value - 0.5) * 10
            : 0.0;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Container(
        height: widget.size,
        width: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 32),
          ],
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.35), AppColors.bgElevated],
          ),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          switch (widget.state) {
            MascotState.listening => Icons.hearing_rounded,
            MascotState.thinking => Icons.more_horiz_rounded,
            MascotState.success => Icons.check_rounded,
            MascotState.warning => Icons.tips_and_updates_rounded,
            MascotState.error => Icons.refresh_rounded,
            MascotState.idle => Icons.auto_awesome_rounded,
          },
          size: widget.size * 0.36,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
