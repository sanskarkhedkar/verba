import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/lesson_provider.dart';

/// Animated microphone button with 5 visual states per PRD 4.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  final MicState state;
  final VoidCallback? onTap;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  bool get _isPulsing => widget.state == MicState.listening;

  Color get _color => switch (widget.state) {
        MicState.listening => AppColors.primaryStart,
        MicState.processing => AppColors.primaryEnd,
        MicState.success => AppColors.success,
        MicState.warning => AppColors.warning,
        MicState.error => AppColors.error,
        MicState.idle => AppColors.bgElevated,
      };

  IconData get _icon => switch (widget.state) {
        MicState.listening => Icons.stop_rounded,
        MicState.processing => Icons.more_horiz_rounded,
        MicState.success => Icons.check_rounded,
        MicState.warning => Icons.tips_and_updates_rounded,
        MicState.error => Icons.refresh_rounded,
        MicState.idle => Icons.mic_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, child) {
            final scale = _isPulsing ? _pulseAnim.value : 1.0;
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: _color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: 0.45),
                  blurRadius: widget.state == MicState.listening ? 40 : 20,
                  spreadRadius: widget.state == MicState.listening ? 4 : 0,
                ),
              ],
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1.5,
              ),
            ),
            child: widget.state == MicState.processing
                ? const Padding(
                    padding: EdgeInsets.all(26),
                    child: CircularProgressIndicator(
                        strokeWidth: 3, color: Colors.white),
                  )
                : Icon(_icon, size: 36, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
