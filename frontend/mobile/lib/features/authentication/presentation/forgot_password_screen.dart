import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/responsive_layout.dart';
import 'auth_contact.dart';
import 'reset_code_screen.dart';
import 'widgets/auth_back_button.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_method_toggle.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

/// Collects an email or Sierra Leone number, then continues to the reset code.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({this.initialUsePhone = false, super.key});

  final bool initialUsePhone;

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  late bool _usePhone = widget.initialUsePhone;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final destination = _usePhone
        ? formatSierraLeoneNumber(
            sierraLeoneNationalNumber(_phoneController.text)!,
          )
        : _emailController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ResetCodeScreen(destination: destination, usePhone: _usePhone),
      ),
    );
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final metrics = AuthFormMetrics(
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                );

                return Column(
                  children: [
                    AuthBackButton(
                      horizontalPadding: metrics.horizontalPadding,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: AuthFormViewport(
                        metrics: metrics,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Image.asset(
                                  ForgotPasswordScreen.logoAsset,
                                  width: metrics.logoWidth * 0.84,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              Text(
                                'Forgot Password?',
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
                                _usePhone
                                    ? "No worries! Enter your registered phone number and we'll send you a code to reset your password."
                                    : "No worries! Enter your registered email address and we'll send you a code to reset your password.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.bodyMuted,
                                  fontSize: metrics.subtitleFontSize,
                                  height: 1.4,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              AuthMethodToggle(
                                usePhone: _usePhone,
                                fontSize: metrics.fieldFontSize,
                                onChanged: (usePhone) {
                                  setState(() {
                                    _usePhone = usePhone;
                                    _error = null;
                                  });
                                },
                              ),
                              SizedBox(height: metrics.blockGap),
                              const Center(child: _ResetMailArt()),
                              SizedBox(height: metrics.blockGap),
                              if (_usePhone)
                                AuthTextField(
                                  key: const ValueKey('reset-phone'),
                                  controller: _phoneController,
                                  hintText: 'Enter your phone number',
                                  prefixIcon: Icons.phone_outlined,
                                  leadingText: '+$sierraLeoneCountryCode',
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  fontSize: metrics.fieldFontSize,
                                  verticalPadding: metrics.fieldVerticalPadding,
                                  autofillHints: const [
                                    AutofillHints.telephoneNumber,
                                  ],
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(12),
                                  ],
                                  validator: validatePhoneNumber,
                                )
                              else
                                AuthTextField(
                                  key: const ValueKey('reset-email'),
                                  controller: _emailController,
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  fontSize: metrics.fieldFontSize,
                                  verticalPadding: metrics.fieldVerticalPadding,
                                  autofillHints: const [AutofillHints.email],
                                  validator: validateEmailAddress,
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
                                label: 'Send Reset Code',
                                height: metrics.primaryButtonHeight,
                                fontSize: metrics.fieldFontSize + 2,
                                onPressed: _submit,
                              ),
                              SizedBox(height: metrics.footerGap),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.loginPrimary,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    fontSize: metrics.linkFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

class _ResetMailArt extends StatelessWidget {
  const _ResetMailArt();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 220,
      height: 156,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFE7F4FB),
              shape: BoxShape.circle,
            ),
            child: SizedBox.square(dimension: 132),
          ),
          Positioned(
            left: 18,
            bottom: 22,
            child: Icon(Icons.eco, color: Color(0xFF8ED39A), size: 34),
          ),
          Positioned(
            right: 14,
            bottom: 16,
            child: Icon(Icons.eco, color: AppColors.loginPrimary, size: 40),
          ),
          _EnvelopeGraphic(),
        ],
      ),
    );
  }
}

class _EnvelopeGraphic extends StatelessWidget {
  const _EnvelopeGraphic();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 128,
      height: 112,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(size: Size(128, 84), painter: _EnvelopePainter()),
          Positioned(top: 2, right: 18, child: _Spark()),
          Positioned(top: 0, child: _LetterCard()),
        ],
      ),
    );
  }
}

class _LetterCard extends StatelessWidget {
  const _LetterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFE4EDF4)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140045A5),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, color: AppColors.secondary, size: 20),
          SizedBox(height: 2),
          Text(
            '•••••',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Spark extends StatelessWidget {
  const _Spark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CustomPaint(painter: _SparkPainter()),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FB4D6)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(8, 0), const Offset(8, 7), paint);
    canvas.drawLine(const Offset(12, 3), const Offset(16, 6), paint);
    canvas.drawLine(const Offset(4, 3), const Offset(0, 6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, height * 0.16, width, height * 0.84),
      const Radius.circular(10),
    );
    canvas.drawRRect(body, Paint()..color = AppColors.loginPrimary);

    final pocket = Path()
      ..moveTo(6, height * 0.28)
      ..lineTo(width / 2, height * 0.68)
      ..lineTo(width - 6, height * 0.28)
      ..lineTo(width - 10, height * 0.9)
      ..lineTo(10, height * 0.9)
      ..close();
    canvas.drawPath(pocket, Paint()..color = const Color(0xFF12850C));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
