import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({
    required this.onPressed,
    this.label = 'Next',
    this.height = 48,
    this.fontSize = 16,
    super.key,
  });

  final VoidCallback onPressed;
  final String label;
  final double height;
  final double fontSize;

  static const double defaultHeight = 48;
  static const double radius = 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}
