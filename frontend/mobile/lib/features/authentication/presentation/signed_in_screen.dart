import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/auth_scope.dart';
import '../../../app/responsive_layout.dart';
import 'sign_in_screen.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_primary_button.dart';

class SignedInScreen extends StatefulWidget {
  const SignedInScreen({super.key});

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';

  @override
  State<SignedInScreen> createState() => _SignedInScreenState();
}

class _SignedInScreenState extends State<SignedInScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await AuthScope.of(context).signOut();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = AuthScope.of(context).account;
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                          SignedInScreen.logoAsset,
                          width: metrics.logoWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: metrics.blockGap),
                      Text(
                        'You are signed in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.loginNavy,
                          fontSize: metrics.titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (account != null) ...[
                        Text(
                          account.fullName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.loginNavy,
                            fontSize: metrics.subtitleFontSize,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        if (account.contact.isNotEmpty)
                          Text(
                            account.contact,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.bodyMuted,
                              fontSize: metrics.subtitleFontSize,
                              height: 1.4,
                            ),
                          ),
                      ],
                      SizedBox(height: metrics.blockGap),
                      AuthPrimaryButton(
                        label: 'Sign out',
                        isLoading: _isSigningOut,
                        height: metrics.primaryButtonHeight,
                        fontSize: metrics.fieldFontSize + 2,
                        onPressed: _signOut,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void openSignedIn(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const SignedInScreen()),
    (_) => false,
  );
}
