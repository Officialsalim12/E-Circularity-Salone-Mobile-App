import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../authentication/presentation/sign_in_screen.dart';
import 'widgets/onboarding_content_layout.dart';

class OnboardingScreenThree extends StatelessWidget {
  const OnboardingScreenThree({super.key});

  static const String illustrationAsset =
      'assets/images/onboarding_3_illustration.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: OnboardingContentLayout(
        illustrationAsset: illustrationAsset,
        heading: 'Small Actions\nMake a Big Impact',
        description:
            'Reduce waste, support recycling and help build a '
            'sustainable future for Sierra Leone.',
        activeIndex: 2,
        primaryButtonLabel: 'Get Started',
        onNext: () => _openSignIn(context),
        onSkip: () => _openSignIn(context),
      ),
    );
  }

  void _openSignIn(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }
}
