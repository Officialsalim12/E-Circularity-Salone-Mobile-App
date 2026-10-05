import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({
    required this.onPressed,
    this.fontSize = 16,
    super.key,
  });

  final VoidCallback onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      child: Text(
        'Skip',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
