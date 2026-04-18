import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Verba's owl mascot built with pure Flutter canvas.
class MascotWidget extends StatefulWidget {
  final double size;
  final bool animate;

  const MascotWidget({super.key, this.size = 120, this.animate = true});

  @override
  State<MascotWidget> createState() => _MascotWidgetState();
}

class _MascotWidgetState extends State<MascotWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _float;
  late Animation<double> _blink;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _blink = Tween<double>(begin: 1.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.9, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) return _buildMascot(0, 1.0);
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => _buildMascot(_float.value, _blink.value),
    );
  }

  Widget _buildMascot(double offset, double blinkScale) {
    return Transform.translate(
      offset: Offset(0, offset),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _OwlPainter(blinkScale: blinkScale),
        ),
      ),
    );
  }
}

class _OwlPainter extends CustomPainter {
  final double blinkScale;
  _OwlPainter({required this.blinkScale});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Body
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7C5CFC), Color(0xFF5B3FD6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, h * 0.2, w, h * 0.8));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.65), width: w * 0.7, height: h * 0.65),
      bodyPaint,
    );

    // Head
    final headPaint = Paint()..color = const Color(0xFF9B7FFF);
    canvas.drawCircle(Offset(cx, h * 0.3), w * 0.35, headPaint);

    // Ears (tufts)
    final earPaint = Paint()..color = const Color(0xFF7C5CFC);
    final leftEar = Path()
      ..moveTo(cx - w * 0.18, h * 0.08)
      ..lineTo(cx - w * 0.28, h * 0.0)
      ..lineTo(cx - w * 0.08, h * 0.12)
      ..close();
    canvas.drawPath(leftEar, earPaint);
    final rightEar = Path()
      ..moveTo(cx + w * 0.18, h * 0.08)
      ..lineTo(cx + w * 0.28, h * 0.0)
      ..lineTo(cx + w * 0.08, h * 0.12)
      ..close();
    canvas.drawPath(rightEar, earPaint);

    // Eye whites
    canvas.drawCircle(Offset(cx - w * 0.13, h * 0.27), w * 0.12, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.13, h * 0.27), w * 0.12, Paint()..color = Colors.white);

    // Pupils (with blink)
    final pupilH = w * 0.085 * blinkScale;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.13, h * 0.27), width: w * 0.085, height: pupilH),
      Paint()..color = const Color(0xFF1A0A3A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.13, h * 0.27), width: w * 0.085, height: pupilH),
      Paint()..color = const Color(0xFF1A0A3A),
    );

    // Eye shine
    canvas.drawCircle(Offset(cx - w * 0.10, h * 0.245), w * 0.025, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(cx + w * 0.16, h * 0.245), w * 0.025, Paint()..color = Colors.white);

    // Beak
    final beakPaint = Paint()..color = const Color(0xFFFFB830);
    final beak = Path()
      ..moveTo(cx, h * 0.33)
      ..lineTo(cx - w * 0.06, h * 0.40)
      ..lineTo(cx + w * 0.06, h * 0.40)
      ..close();
    canvas.drawPath(beak, beakPaint);

    // Belly
    final bellyPaint = Paint()
      ..color = const Color(0xFFBDA9FF).withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.68), width: w * 0.42, height: h * 0.3),
      bellyPaint,
    );

    // Wings
    final wingPaint = Paint()..color = const Color(0xFF6B4FD8);
    final leftWing = Path()
      ..moveTo(cx - w * 0.35, h * 0.55)
      ..quadraticBezierTo(cx - w * 0.55, h * 0.7, cx - w * 0.3, h * 0.82)
      ..quadraticBezierTo(cx - w * 0.2, h * 0.65, cx - w * 0.18, h * 0.55)
      ..close();
    canvas.drawPath(leftWing, wingPaint);
    final rightWing = Path()
      ..moveTo(cx + w * 0.35, h * 0.55)
      ..quadraticBezierTo(cx + w * 0.55, h * 0.7, cx + w * 0.3, h * 0.82)
      ..quadraticBezierTo(cx + w * 0.2, h * 0.65, cx + w * 0.18, h * 0.55)
      ..close();
    canvas.drawPath(rightWing, wingPaint);

    // Feet
    final footPaint = Paint()
      ..color = const Color(0xFFFFB830)
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - w * 0.1, h * 0.93), Offset(cx - w * 0.18, h * 1.0), footPaint);
    canvas.drawLine(Offset(cx - w * 0.1, h * 0.93), Offset(cx - w * 0.06, h * 1.0), footPaint);
    canvas.drawLine(Offset(cx + w * 0.1, h * 0.93), Offset(cx + w * 0.06, h * 1.0), footPaint);
    canvas.drawLine(Offset(cx + w * 0.1, h * 0.93), Offset(cx + w * 0.18, h * 1.0), footPaint);
  }

  @override
  bool shouldRepaint(_OwlPainter old) => old.blinkScale != blinkScale;
}
