import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/responsive_layout.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_primary_button.dart';

/// Shown once the new password is saved.
class PasswordChangedScreen extends StatelessWidget {
  const PasswordChangedScreen({super.key});

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';

  void _backToLogin(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        _backToLogin(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: MediaQuery(
            data: ResponsiveLayout.clampTextScale(context),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final metrics = AuthFormMetrics(
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                  );

                  return AuthFormViewport(
                    metrics: metrics,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            logoAsset,
                            width: metrics.logoWidth * 0.84,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: metrics.blockGap),
                        const Center(child: _SuccessMark()),
                        SizedBox(height: metrics.blockGap),
                        Text(
                          'Password changed',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.loginNavy,
                            fontSize: metrics.titleFontSize,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your password is updated. Sign in with the new one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.bodyMuted,
                            fontSize: metrics.subtitleFontSize,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: metrics.blockGap),
                        AuthPrimaryButton(
                          label: 'Back to Login',
                          height: metrics.primaryButtonHeight,
                          fontSize: metrics.fieldFontSize + 2,
                          onPressed: () => _backToLogin(context),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 168,
      height: 148,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1419A10F),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 132),
          ),
          Positioned(
            left: 8,
            bottom: 18,
            child: Icon(Icons.eco, color: Color(0xFF8ED39A), size: 28),
          ),
          Positioned(
            right: 6,
            bottom: 14,
            child: Icon(Icons.eco, color: AppColors.loginPrimary, size: 34),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.loginPrimary,
              shape: BoxShape.circle,
            ),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Center(
                child: Icon(Icons.check_rounded, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
