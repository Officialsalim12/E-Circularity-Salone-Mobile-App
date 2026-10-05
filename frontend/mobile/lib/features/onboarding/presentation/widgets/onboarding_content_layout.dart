import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/responsive_layout.dart';
import 'onboarding_next_button.dart';
import 'onboarding_progress_dots.dart';
import 'onboarding_skip_button.dart';

class OnboardingContentLayout extends StatelessWidget {
  const OnboardingContentLayout({
    required this.illustrationAsset,
    required this.heading,
    required this.description,
    required this.activeIndex,
    required this.onNext,
    this.primaryButtonLabel = 'Next',
    this.onSkip,
    super.key,
  });

  final String illustrationAsset;
  final String heading;
  final String description;
  final int activeIndex;
  final VoidCallback onNext;
  final String primaryButtonLabel;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: ResponsiveLayout.clampTextScale(context),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final metrics = OnboardingLayoutMetrics(
              height: constraints.maxHeight,
              width: constraints.maxWidth,
            );

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: metrics.horizontalPadding),
              child: Column(
                children: [
                  Expanded(
                    flex: metrics.illustrationFlex,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Image.asset(
                          illustrationAsset,
                          fit: BoxFit.contain,
                          width: metrics.illustrationMaxWidth,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: metrics.textBlockFlex,
                    child: LayoutBuilder(
                      builder: (context, textConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: textConstraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      heading,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.headingNavy,
                                        fontSize: metrics.headingFontSize,
                                        height: 1.12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    SizedBox(
                                      height: metrics.compactHeight ? 12.0 : 16.0,
                                    ),
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: metrics.contentMaxWidth,
                                      ),
                                      child: Text(
                                        description,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.bodyMuted,
                                          fontSize: metrics.descriptionFontSize,
                                          height: 1.5,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Center(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: metrics.contentMaxWidth,
                                        ),
                                        child: Column(
                                          children: [
                                            OnboardingProgressDots(
                                              pageCount: 3,
                                              activeIndex: activeIndex,
                                            ),
                                            SizedBox(
                                              height: metrics.progressDotsGap,
                                            ),
                                            OnboardingNextButton(
                                              onPressed: onNext,
                                              label: primaryButtonLabel,
                                              height: metrics.primaryButtonHeight,
                                              fontSize:
                                                  metrics.descriptionFontSize + 1,
                                            ),
                                            if (onSkip != null) ...[
                                              const SizedBox(height: 4),
                                              OnboardingSkipButton(
                                                onPressed: onSkip!,
                                                fontSize:
                                                    metrics.descriptionFontSize + 1,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.paddingOf(context)
                                              .bottom +
                                          metrics.bottomPadding,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
