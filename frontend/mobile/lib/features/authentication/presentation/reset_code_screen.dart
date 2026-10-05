import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/auth_scope.dart';
import '../../../app/responsive_layout.dart';
import '../../../core/networking/api_client.dart';
import 'new_password_screen.dart';
import 'widgets/auth_back_button.dart';
import 'widgets/auth_bottom_illustration.dart';
import 'widgets/auth_code_entry.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_primary_button.dart';

/// Password reset code.
class ResetCodeScreen extends StatefulWidget {
  const ResetCodeScreen({
    required this.destination,
    required this.usePhone,
    super.key,
  });

  final String destination;
  final bool usePhone;

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';
  static const String illustrationAsset =
      'assets/images/signup_e_waste_illustration.png';

  @override
  State<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends State<ResetCodeScreen> {
  static const int _resendSeconds = 60;

  final _codeController = TextEditingController();

  String? _error;
  int _secondsLeft = _resendSeconds;
  bool _isLoading = false;
  Timer? _resendTimer;

  String get _timerLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _armResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _secondsLeft = _resendSeconds);
    _armResendTimer();
  }

  void _armResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _resendCode() async {
    if (_isLoading) {
      return;
    }
    if (_secondsLeft > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for the timer to finish, then ask for another code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _error = null;
      _isLoading = true;
      _codeController.clear();
    });
    try {
      await AuthScope.of(context).requestVerificationCode(
        purpose: 'password_reset',
        destination: widget.destination,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = error.message;
      });
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
    _startResendCountdown();
  }

  Future<void> _verify() async {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    try {
      final token = await AuthScope.of(context).confirmVerificationCode(
        purpose: 'password_reset',
        destination: widget.destination,
        code: code,
      );
      if (!mounted) {
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NewPasswordScreen(
            destination: widget.destination,
            verificationToken: token,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.message);
    }

    if (!mounted) {
      return;
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = AuthFormMetrics(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  illustration: AuthIllustrationPreset.signup,
                );
                final bottomInset = MediaQuery.paddingOf(context).bottom;

                return Column(
                  children: [
                    AuthBackButton(
                      horizontalPadding: metrics.horizontalPadding,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: AuthFormViewport(
                        metrics: metrics,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.asset(
                                ResetCodeScreen.logoAsset,
                                width: metrics.logoWidth * 0.72,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: metrics.blockGap),
                            Text(
                              widget.usePhone
                                  ? 'Verify Your Phone Number'
                                  : 'Verify Your Email',
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
                            AuthCodeSentCopy(
                              destination: widget.destination,
                              fontSize: metrics.subtitleFontSize,
                            ),
                            SizedBox(height: metrics.blockGap),
                            const PhoneVerifyArt(codeLabel: '123456'),
                            SizedBox(height: metrics.blockGap),
                            AuthOtpCodeField(
                              controller: _codeController,
                              onChanged: (_) => setState(() => _error = null),
                            ),
                            SizedBox(height: metrics.blockGap),
                            AuthResendLine(
                              secondsLeft: _secondsLeft,
                              timerLabel: _timerLabel,
                              fontSize: metrics.linkFontSize,
                              onResend: _resendCode,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.loginPrimary,
                                  fontSize: metrics.linkFontSize,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            SizedBox(height: metrics.blockGap),
                            AuthPrimaryButton(
                              label: 'Verify',
                              isLoading: _isLoading,
                              height: metrics.primaryButtonHeight,
                              fontSize: metrics.fieldFontSize + 2,
                              onPressed: _verify,
                            ),
                            SizedBox(height: metrics.footerGap),
                            GestureDetector(
                              onTap: _resendCode,
                              child: Text(
                                "Didn't receive a code?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.loginPrimary,
                                  fontSize: metrics.linkFontSize,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AuthBottomIllustration(
                      asset: ResetCodeScreen.illustrationAsset,
                      width: constraints.maxWidth,
                      maxHeight: metrics.illustrationHeight,
                      bottomInset: bottomInset,
                      topGap: metrics.illustrationTopGap,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
