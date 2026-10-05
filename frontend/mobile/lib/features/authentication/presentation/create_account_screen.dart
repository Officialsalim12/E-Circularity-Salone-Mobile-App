import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_colors.dart';
import '../../../app/auth_scope.dart';
import '../../../app/responsive_layout.dart';
import '../../../core/networking/api_client.dart';
import 'auth_contact.dart';
import 'confirm_account_screen.dart';
import 'sign_in_screen.dart';
import 'signed_in_screen.dart';
import 'verify_phone_number_screen.dart';
import 'widgets/auth_back_button.dart';
import 'widgets/auth_bottom_illustration.dart';
import 'widgets/auth_form_viewport.dart';
import 'widgets/auth_method_toggle.dart';
import 'widgets/auth_or_divider.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/google_sign_in_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const String logoAsset = 'assets/brand/circular_salone_logo.png';
  static const String illustrationAsset =
      'assets/images/signup_e_waste_illustration.png';

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _usePhone = false;
  String? _confirmedPhone;
  String? _verificationToken;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _authError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitSignup() async {
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);

    if (!_agreedToTerms) {
      setState(() {
        _authError = 'Accept the terms and privacy policy to continue.';
      });
      return;
    }

    if (_usePhone && (_confirmedPhone == null || _verificationToken == null)) {
      setState(() => _authError = 'Check your phone number first.');
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = AuthScope.of(context);
      if (_usePhone) {
        await auth.register(
          fullName: _fullNameController.text.trim(),
          password: _passwordController.text,
          phone: _confirmedPhone,
          verificationToken: _verificationToken,
        );
      } else {
        final email = _emailController.text.trim();
        await auth.requestVerificationCode(
          purpose: 'email_registration',
          destination: email,
        );
        if (!mounted) {
          return;
        }
        final token = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => ConfirmAccountScreen(email: email),
          ),
        );
        if (!mounted) {
          return;
        }
        if (token == null) {
          setState(() => _isLoading = false);
          return;
        }
        await auth.register(
          fullName: _fullNameController.text.trim(),
          password: _passwordController.text,
          email: email,
          verificationToken: token,
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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const SignInScreen(accountCreated: true),
      ),
      (_) => false,
    );
  }

  Future<void> _continueWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);

    if (!_agreedToTerms) {
      setState(() {
        _authError = 'Accept the terms and privacy policy to continue.';
      });
      return;
    }

    setState(() => _isGoogleLoading = true);

    try {
      final account = await AuthScope.of(context).continueWithGoogle(
        intent: 'sign_up',
        acceptedTerms: true,
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

  Future<void> _openPhoneVerification() async {
    final verified = await Navigator.of(context).push<VerifiedPhone>(
      MaterialPageRoute(
        builder: (_) => const VerifyPhoneNumberScreen(),
      ),
    );
    if (!mounted || verified == null) {
      return;
    }
    setState(() {
      _usePhone = true;
      _confirmedPhone = verified.nationalNumber;
      _verificationToken = verified.verificationToken;
      _authError = null;
    });
  }

  void _openSignIn() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
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
                        child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Image.asset(
                                      CreateAccountScreen.logoAsset,
                                      width: metrics.logoWidth,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: metrics.blockGap),
                                  Text(
                                    'Create Account',
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
                                    'Join Circular Salone today',
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
                                      if (!usePhone) {
                                        setState(() {
                                          _usePhone = false;
                                          _confirmedPhone = null;
                                          _verificationToken = null;
                                          _authError = null;
                                        });
                                        return;
                                      }
                                      _openPhoneVerification();
                                    },
                                  ),
                                  SizedBox(height: metrics.fieldGap),
                                  if (_confirmedPhone != null)
                                    Column(
                                      children: [
                                        Text(
                                          formatSierraLeoneNumber(
                                            _confirmedPhone!,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.loginNavy,
                                            fontSize: metrics.fieldFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _openPhoneVerification,
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.loginPrimary,
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'Change number',
                                            style: TextStyle(
                                              fontSize: metrics.linkFontSize,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  else
                                    AuthTextField(
                                      key: const ValueKey('signup-email'),
                                      controller: _emailController,
                                      hintText: 'Email',
                                      prefixIcon: Icons.mail_outline,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      fontSize: metrics.fieldFontSize,
                                      verticalPadding:
                                          metrics.fieldVerticalPadding,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      validator: validateEmailAddress,
                                    ),
                                  SizedBox(height: metrics.fieldGap),
                                  AuthTextField(
                                    controller: _fullNameController,
                                    hintText: 'Full name',
                                    prefixIcon: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                    fontSize: metrics.fieldFontSize,
                                    verticalPadding:
                                        metrics.fieldVerticalPadding,
                                    autofillHints: const [AutofillHints.name],
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Enter your full name';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: metrics.fieldGap),
                                  AuthTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    fontSize: metrics.fieldFontSize,
                                    verticalPadding:
                                        metrics.fieldVerticalPadding,
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
                                    verticalPadding:
                                        metrics.fieldVerticalPadding,
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
                                  SizedBox(height: metrics.fieldGap * 0.75),
                                  _TermsCheckbox(
                                    value: _agreedToTerms,
                                    fontSize: metrics.linkFontSize - 1,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreedToTerms = value ?? false;
                                        if (_agreedToTerms) {
                                          _authError = null;
                                        }
                                      });
                                    },
                                  ),
                                  if (!_agreedToTerms) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tick this box before you create an account.',
                                      style: TextStyle(
                                        color: AppColors.bodyMuted,
                                        fontSize: metrics.linkFontSize - 1,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                  if (_authError != null) ...[
                                    SizedBox(height: metrics.fieldGap * 0.5),
                                    Text(
                                      _authError!,
                                      style: TextStyle(
                                        color: AppColors.loginPrimary,
                                        fontSize: metrics.linkFontSize,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                  SizedBox(height: metrics.fieldGap),
                                  AuthPrimaryButton(
                                    label: 'Create Account',
                                    isLoading: _isLoading,
                                    height: metrics.primaryButtonHeight,
                                    fontSize: metrics.fieldFontSize + 2,
                                    onPressed: _agreedToTerms && !_isGoogleLoading
                                        ? _submitSignup
                                        : null,
                                  ),
                                  SizedBox(height: metrics.blockGap),
                                  const AuthOrDivider(),
                                  SizedBox(height: metrics.blockGap),
                                  GoogleSignInButton(
                                    isLoading: _isGoogleLoading,
                                    onPressed: _agreedToTerms && !_isLoading
                                        ? _continueWithGoogle
                                        : null,
                                    height: metrics.primaryButtonHeight,
                                    fontSize: metrics.fieldFontSize,
                                  ),
                                  SizedBox(height: metrics.footerGap),
                                  _SignInPrompt(
                                    onSignIn: _openSignIn,
                                    linkFontSize: metrics.linkFontSize,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    AuthBottomIllustration(
                      asset: CreateAccountScreen.illustrationAsset,
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

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.value,
    required this.onChanged,
    this.fontSize = 13,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.loginPrimary,
            side: const BorderSide(color: AppColors.secondary),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              GestureDetector(
                onTap: () => onChanged(!value),
                child: Text(
                  'I agree to the ',
                  style: TextStyle(
                    color: AppColors.bodyMuted,
                    fontSize: fontSize,
                    height: 1.4,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Terms and Conditions aren't ready yet."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    color: AppColors.loginPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  color: AppColors.bodyMuted,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Privacy Policy isn't ready yet."),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppColors.loginPrimary,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({
    required this.onSignIn,
    required this.linkFontSize,
  });

  final VoidCallback onSignIn;
  final double linkFontSize;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(
            color: AppColors.bodyMuted,
            fontSize: linkFontSize,
          ),
        ),
        GestureDetector(
          onTap: onSignIn,
          child: Text(
            'Sign In',
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
