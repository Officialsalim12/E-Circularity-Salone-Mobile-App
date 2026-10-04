import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/responsive_layout.dart';
import 'auth_contact.dart';
import 'password_changed_screen.dart';
import 'widgets/auth_back_button.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';

/// Collects a replacement password after the reset code step.
///
/// The new password is not saved. Account recovery is still open.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({required this.destination, super.key});

  final String destination;

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PasswordChangedScreen()),
    );
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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
                                  NewPasswordScreen.logoAsset,
                                  width: metrics.logoWidth * 0.84,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              Text(
                                'Create New Password',
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
                                'Choose a new password for ${widget.destination}.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.bodyMuted,
                                  fontSize: metrics.subtitleFontSize,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              AuthTextField(
                                controller: _passwordController,
                                hintText: 'New password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                fontSize: metrics.fieldFontSize,
                                verticalPadding: metrics.fieldVerticalPadding,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                validator: validatePassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.inputHint,
                                    size: 22,
                                  ),
                                ),
                              ),
                              SizedBox(height: metrics.fieldGap),
                              AuthTextField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                fontSize: metrics.fieldFontSize,
                                verticalPadding: metrics.fieldVerticalPadding,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                validator: _validateConfirmPassword,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.inputHint,
                                    size: 22,
                                  ),
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              AuthPrimaryButton(
                                label: 'Reset Password',
                                isLoading: _isLoading,
                                height: metrics.primaryButtonHeight,
                                fontSize: metrics.fieldFontSize + 2,
                                onPressed: _submit,
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
