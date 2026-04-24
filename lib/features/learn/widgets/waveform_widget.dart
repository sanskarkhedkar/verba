import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class WaveformWidget extends StatefulWidget {
  const WaveformWidget({required this.active, super.key});

  final bool active;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(80, 54),
          painter: _WaveformPainter(
            t: _controller.value,
            active: widget.active,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({required this.t, required this.active});

  final double t;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    const bars = 5;
    const barWidth = 6.0;
    const gap = 6.0;
    final totalWidth = bars * barWidth + (bars - 1) * gap;
    final startX = (size.width - totalWidth) / 2;
    for (var i = 0; i < bars; i++) {
      final distance = (i - 2).abs();
      final wave = active ? (math.sin((t * math.pi * 2) + i) + 1) / 2 : 0.15;
      final multiplier = [0.5, 0.75, 1.0][2 - distance];
      final height = 8 + wave * multiplier * 42;
      final left = startX + i * (barWidth + gap);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, (size.height - height) / 2, barWidth, height),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        rect,
        paint..color = paint.color.withValues(alpha: active ? 1 : 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.active != active;
  }
}
