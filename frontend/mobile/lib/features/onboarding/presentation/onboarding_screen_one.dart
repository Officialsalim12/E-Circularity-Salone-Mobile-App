import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import 'onboarding_screen_two.dart';
import 'widgets/onboarding_content_layout.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({super.key});

  static const String illustrationAsset =
      'assets/images/onboarding_1_illustration.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OnboardingContentLayout(
        illustrationAsset: illustrationAsset,
        heading: 'A Cleaner\nSierra Leone',
        description:
            'Join the movement for a cleaner, healthier and greener '
            'environment in your community.',
        activeIndex: 0,
        onNext: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const OnboardingScreenTwo(),
            ),
          );
        },
      ),
    );
  }
}
