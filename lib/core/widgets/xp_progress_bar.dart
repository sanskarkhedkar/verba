import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class XpProgressBar extends StatelessWidget {
  const XpProgressBar({required this.value, super.key, this.height = 10});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: AppColors.bgElevated,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          child: Container(
            decoration:
                const BoxDecoration(gradient: AppColors.primaryGradient),
          ),
        ),
      ),
    );
  }
}
