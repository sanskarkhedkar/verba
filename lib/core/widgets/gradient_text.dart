import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.style,
    super.key,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          AppColors.primaryGradient.createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}
