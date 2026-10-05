import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/auth_scope.dart';
import '../../../app/responsive_layout.dart';
import '../../onboarding/presentation/onboarding_screen_one.dart';
import 'signed_in_screen.dart';
import 'widgets/splash_loading_section.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String backgroundAsset =
      'assets/images/splash_freetown_coast.jpg';
  /// Horizontal wordmark + symbol (white type on dark overlay).
  static const String logoAsset =
      'assets/brand/circular_salone_splash_logo.png';

  /// Matches [design.json] secondary blue with transparency for readability.
  static const Color overlayColor = Color(0x990045A5);

  static const Duration loadDuration = Duration(seconds: 4);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: MediaQuery(
          data: ResponsiveLayout.clampTextScale(context),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bottomInset = MediaQuery.paddingOf(context).bottom;
              final horizontalPadding = ResponsiveLayout.contentHorizontalPadding(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final contentWidth =
                  constraints.maxWidth - (horizontalPadding * 2);
              final tier = ResponsiveLayout.heightTier(constraints.maxHeight);
              final scale = ResponsiveLayout.mobileContentScale(tier);
              final compactHeight = tier == MobileHeightTier.compact;
              final progressWidth = contentWidth >= 220
                  ? 220.0
                  : contentWidth.clamp(160.0, 220.0).toDouble();

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  const ColoredBox(color: overlayColor),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, safeConstraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: safeConstraints.maxHeight,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(height: compactHeight ? 12 : 20),
                                  Column(
                                    children: [
                                      _LogoSection(
                                        maxWidth: contentWidth *
                                            (0.96 + (scale - 1) * 0.06),
                                      ),
                                      SizedBox(height: compactHeight ? 18 : 24),
                                      _Tagline(
                                        fontSize:
                                            (17 * scale).clamp(14, 19).toDouble(),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SplashLoadingSection(
                                        barWidth: progressWidth,
                                        duration: loadDuration,
                                        onComplete: () => _openNext(context),
                                      ),
                                      SizedBox(
                                        height: (compactHeight ? 20 : 28) +
                                            bottomInset,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openNext(BuildContext context) {
    unawaited(_openNextAsync(context));
  }

  Future<void> _openNextAsync(BuildContext context) async {
    final account = await AuthScope.of(context).restoreSession();
    if (!context.mounted) {
      return;
    }
    final Widget next = account == null
        ? const OnboardingScreenOne()
        : const SignedInScreen();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection({required this.maxWidth});

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final logoWidth = maxWidth.clamp(260.0, 420.0);

    return Image.asset(
      SplashScreen.logoAsset,
      width: logoWidth,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      height: 1.35,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    );

    return Column(
      children: [
        Text('Cleaner Communities', textAlign: TextAlign.center, style: style),
        Text(
          'A Greener Sierra Leone',
          textAlign: TextAlign.center,
          style: style,
        ),
      ],
    );
  }
}
