import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/auth_scope.dart';
import '../../../app/responsive_layout.dart';
import '../../../core/networking/api_client.dart';
import 'auth_contact.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';
import 'signed_in_screen.dart';
import 'widgets/auth_bottom_illustration.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_method_toggle.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({this.accountCreated = false, super.key});

  final bool accountCreated;

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';
  static const String illustrationAsset =
      'assets/images/login_e_waste_illustration.jpg';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _usePhone = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthScope.of(context);
      if (_usePhone) {
        await auth.login(
          phone: sierraLeoneNationalNumber(_phoneController.text),
          password: _passwordController.text,
        );
      } else {
        await auth.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _authError = error.message;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    openSignedIn(context);
  }

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _authError = null;
      _isGoogleLoading = true;
    });

    try {
      final account = await AuthScope.of(context).continueWithGoogle(
        intent: 'sign_in',
      );
      if (!mounted) {
        return;
      }
      if (account == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isGoogleLoading = false;
        _authError = error.message;
      });
      return;
    }

    if (!mounted) {
      return;
    }
    openSignedIn(context);
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
                );
                final bottomInset = MediaQuery.paddingOf(context).bottom;

                return Column(
                  children: [
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
                                  SignInScreen.logoAsset,
                                  width: metrics.logoWidth,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: metrics.blockGap),
                              Text(
                                'Welcome Back',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.loginNavy,
                                  fontSize: metrics.titleFontSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                  letterSpacing: -0.35,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.accountCreated
                                    ? "You're all set. Sign in when you're ready."
                                    : 'Sign in to continue',
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
                                    _authError = null;
                                  });
                                },
                              ),
                              SizedBox(height: metrics.fieldGap),
                              if (_usePhone)
                                AuthTextField(
                                  key: const ValueKey('sign-in-phone'),
                                  controller: _phoneController,
                                  hintText: 'Phone number',
                                  prefixIcon: Icons.phone_outlined,
                                  leadingText: '+$sierraLeoneCountryCode',
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
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
                                  key: const ValueKey('sign-in-email'),
                                  controller: _emailController,
                                  hintText: 'Email',
                                  prefixIcon: Icons.mail_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  fontSize: metrics.fieldFontSize,
                                  verticalPadding: metrics.fieldVerticalPadding,
                                  autofillHints: const [AutofillHints.email],
                                  validator: validateEmailAddress,
                                ),
                              SizedBox(height: metrics.fieldGap),
                              AuthTextField(
                                controller: _passwordController,
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                fontSize: metrics.fieldFontSize,
                                verticalPadding: metrics.fieldVerticalPadding,
                                autofillHints: const [AutofillHints.password],
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ForgotPasswordScreen(
                                          initialUsePhone: _usePhone,
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.loginPrimary,
                                    padding: const EdgeInsets.only(top: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: metrics.linkFontSize,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (_authError != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _authError!,
                                  style: const TextStyle(
                                    color: AppColors.loginPrimary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              SizedBox(height: metrics.fieldGap),
                              AuthPrimaryButton(
                                label: 'Sign In',
                                isLoading: _isLoading,
                                height: metrics.primaryButtonHeight,
                                fontSize: metrics.fieldFontSize + 2,
                                onPressed: _isGoogleLoading ? null : _submitSignIn,
                              ),
                              SizedBox(height: metrics.blockGap),
                              const _OrDivider(),
                              SizedBox(height: metrics.blockGap),
                              GoogleSignInButton(
                                isLoading: _isGoogleLoading,
                                onPressed: _isLoading ? null : _continueWithGoogle,
                                height: metrics.primaryButtonHeight,
                                fontSize: metrics.fieldFontSize,
                              ),
                              SizedBox(height: metrics.footerGap),
                              _RegisterPrompt(
                                linkFontSize: metrics.linkFontSize,
                                onCreateAccount: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const CreateAccountScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AuthBottomIllustration(
                      asset: SignInScreen.illustrationAsset,
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.inputBorder, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.inputHint,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.inputBorder, height: 1)),
      ],
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt({
    required this.onCreateAccount,
    required this.linkFontSize,
  });

  final VoidCallback onCreateAccount;
  final double linkFontSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(color: AppColors.bodyMuted, fontSize: linkFontSize),
        ),
        GestureDetector(
          onTap: onCreateAccount,
          child: Text(
            'Create account',
            style: TextStyle(
              color: AppColors.loginPrimary,
              fontSize: linkFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
