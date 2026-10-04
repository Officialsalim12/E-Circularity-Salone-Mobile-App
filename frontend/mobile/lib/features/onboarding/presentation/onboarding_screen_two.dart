import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import 'onboarding_screen_three.dart';
import 'widgets/onboarding_content_layout.dart';

class OnboardingScreenTwo extends StatelessWidget {
  const OnboardingScreenTwo({super.key});

  static const String illustrationAsset =
      'assets/images/onboarding_2_illustration.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OnboardingContentLayout(
        illustrationAsset: illustrationAsset,
        heading: 'Track & Stay\nInformed',
        description:
            'Use our app to check collection schedules, report issues '
            'and get the latest updates.',
        activeIndex: 1,
        onNext: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const OnboardingScreenThree(),
            ),
          );
        },
      ),
    );
  }
}
