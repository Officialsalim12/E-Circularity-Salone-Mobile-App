import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/responsive_layout.dart';
import 'auth_contact.dart';
import 'widgets/auth_back_button.dart';
import 'widgets/auth_bottom_illustration.dart';
import 'widgets/auth_code_entry.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_primary_button.dart';

/// Collects a Sierra Leone number before create-account asks for a name and password.
///
/// Pops the eight-digit national number when the user confirms it.
/// No code is sent; the SMS provider is still open.
class VerifyPhoneNumberScreen extends StatefulWidget {
  const VerifyPhoneNumberScreen({super.key});

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';
  static const String illustrationAsset =
      'assets/images/signup_e_waste_illustration.png';

  @override
  State<VerifyPhoneNumberScreen> createState() =>
      _VerifyPhoneNumberScreenState();
}

class _VerifyPhoneNumberScreenState extends State<VerifyPhoneNumberScreen> {
  static const int _resendSeconds = 60;

  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _nationalNumber;
  String? _error;
  int _secondsLeft = 0;
  Timer? _resendTimer;

  bool get _enteringCode => _nationalNumber != null;

  String get _timerLabel {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _sendCode() {
    FocusScope.of(context).unfocus();
    final error = validatePhoneNumber(_phoneController.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _error = null;
      _nationalNumber = sierraLeoneNationalNumber(_phoneController.text);
      _codeController.clear();
    });
    _startResendCountdown();
  }

  void _confirmCode() {
    FocusScope.of(context).unfocus();
    final code = _codeController.text.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _error = 'Enter the 6-digit code');
      return;
    }
    Navigator.of(context).pop(_nationalNumber);
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
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

  void _resendCode() {
    if (_secondsLeft > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can request another code when the timer ends.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _error = null;
      _codeController.clear();
    });
    _startResendCountdown();
  }

  void _goBack() {
    if (_enteringCode) {
      _resendTimer?.cancel();
      setState(() {
        _nationalNumber = null;
        _error = null;
        _secondsLeft = 0;
        _codeController.clear();
      });
      return;
    }
    Navigator.of(context).pop();
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
                      onPressed: _goBack,
                    ),
                    Expanded(
                      child: AuthFormViewport(
                        metrics: metrics,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: Image.asset(
                                VerifyPhoneNumberScreen.logoAsset,
                                width: metrics.logoWidth * 0.72,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(height: metrics.blockGap),
                            Text(
                              'Verify Your Phone Number',
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
                            if (_enteringCode)
                              AuthCodeSentCopy(
                                destination: formatSierraLeoneNumber(
                                  _nationalNumber!,
                                ),
                                fontSize: metrics.subtitleFontSize,
                              )
                            else
                              Text(
                                "Enter your phone number and we'll send a 6-digit code to verify your account.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.bodyMuted,
                                  fontSize: metrics.subtitleFontSize,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            SizedBox(height: metrics.blockGap),
                            if (!_enteringCode) ...[
                              const PhoneVerifyArt(),
                              SizedBox(height: metrics.blockGap),
                              Text(
                                'Phone Number',
                                style: TextStyle(
                                  color: AppColors.loginNavy,
                                  fontSize: metrics.fieldFontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _PhoneNumberField(
                                controller: _phoneController,
                                fontSize: metrics.fieldFontSize,
                                verticalPadding: metrics.fieldVerticalPadding,
                              ),
                            ] else ...[
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
                            ],
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
                              label: _enteringCode ? 'Verify' : 'Send Code',
                              height: metrics.primaryButtonHeight,
                              fontSize: metrics.fieldFontSize + 2,
                              onPressed: _enteringCode
                                  ? _confirmCode
                                  : _sendCode,
                            ),
                            if (!_enteringCode) ...[
                              SizedBox(height: metrics.footerGap),
                              _AgreementText(
                                fontSize: metrics.linkFontSize - 1,
                              ),
                            ] else ...[
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
                          ],
                        ),
                      ),
                    ),
                    AuthBottomIllustration(
                      asset: VerifyPhoneNumberScreen.illustrationAsset,
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

OutlineInputBorder _fieldBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}

class _PhoneNumberField extends StatelessWidget {
  const _PhoneNumberField({
    required this.controller,
    required this.fontSize,
    required this.verticalPadding,
  });

  final TextEditingController controller;
  final double fontSize;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumber],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      style: TextStyle(
        color: AppColors.loginNavy,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: '78 123456',
        hintStyle: TextStyle(
          color: AppColors.inputHint,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: const _DialPrefix(),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: EdgeInsets.symmetric(vertical: verticalPadding),
        border: _fieldBorder(AppColors.inputBorder),
        enabledBorder: _fieldBorder(AppColors.inputBorder),
        focusedBorder: _fieldBorder(AppColors.secondary),
      ),
    );
  }
}

class _DialPrefix extends StatelessWidget {
  const _DialPrefix();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12, right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SierraLeoneFlag(),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: AppColors.loginNavy, size: 18),
          SizedBox(width: 8),
          Text(
            '+232',
            style: TextStyle(
              color: AppColors.loginNavy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 1,
            height: 22,
            child: ColoredBox(color: AppColors.inputBorder),
          ),
        ],
      ),
    );
  }
}

class _SierraLeoneFlag extends StatelessWidget {
  const _SierraLeoneFlag();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: const SizedBox(
        width: 22,
        height: 16,
        child: Column(
          children: [
            Expanded(child: ColoredBox(color: Color(0xFF1EB53A))),
            Expanded(child: ColoredBox(color: Color(0xFFFFFFFF))),
            Expanded(child: ColoredBox(color: Color(0xFF0072C6))),
          ],
        ),
      ),
    );
  }
}

class _AgreementText extends StatelessWidget {
  const _AgreementText({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(
      color: AppColors.bodyMuted,
      fontSize: fontSize,
      height: 1.4,
    );
    final link = TextStyle(
      color: AppColors.loginPrimary,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1.4,
    );

    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          textAlign: TextAlign.center,
          style: muted,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showComingSoon(context, 'Terms and Conditions'),
              child: Text('Terms and Conditions', style: link),
            ),
            Text(' and ', style: muted),
            GestureDetector(
              onTap: () => _showComingSoon(context, 'Privacy Policy'),
              child: Text('Privacy Policy', style: link),
            ),
            Text('.', style: muted),
          ],
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title — coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
