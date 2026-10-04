import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    required this.pageCount,
    required this.activeIndex,
    super.key,
  });

  final int pageCount;
  final int activeIndex;

  static const double dotSize = 10;
  static const double spacing = 10;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == activeIndex;
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : spacing),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.progressInactive,
            ),
          ),
        );
      }),
    );
  }
}
