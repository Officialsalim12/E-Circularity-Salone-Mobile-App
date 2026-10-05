import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_colors.dart';

class AuthCodeSentCopy extends StatelessWidget {
  const AuthCodeSentCopy({
    required this.destination,
    required this.fontSize,
    super.key,
  });

  final String destination;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: AppColors.bodyMuted,
      fontSize: fontSize,
      height: 1.4,
      fontWeight: FontWeight.w400,
    );
    return Column(
      children: [
        Text(
          "We've sent a 6-digit code to",
          textAlign: TextAlign.center,
          style: style,
        ),
        const SizedBox(height: 2),
        Text(
          destination,
          textAlign: TextAlign.center,
          style: style.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class AuthResendLine extends StatelessWidget {
  const AuthResendLine({
    required this.secondsLeft,
    required this.timerLabel,
    required this.fontSize,
    required this.onResend,
    super.key,
  });

  final int secondsLeft;
  final String timerLabel;
  final double fontSize;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      color: AppColors.bodyMuted,
      fontSize: fontSize,
      height: 1.4,
    );
    if (secondsLeft == 0) {
      return GestureDetector(
        onTap: onResend,
        child: Text(
          'Resend code',
          textAlign: TextAlign.center,
          style: base.copyWith(
            color: AppColors.loginPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'Resend code in '),
          TextSpan(
            text: timerLabel,
            style: const TextStyle(
              color: AppColors.loginPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class AuthOtpCodeField extends StatelessWidget {
  const AuthOtpCodeField({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final code = controller.text;
    final boxHeight =
        (MediaQuery.sizeOf(context).height * 0.07).clamp(44.0, 56.0).toDouble();
    return SizedBox(
      height: boxHeight,
      child: Stack(
        children: [
          Row(
            children: [
              for (var index = 0; index < 6; index++) ...[
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _OtpBox(
                    digit: index < code.length ? code[index] : null,
                    focused: code.length == index,
                  ),
                ),
              ],
            ],
          ),
          Positioned.fill(
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.oneTimeCode],
              showCursor: false,
              enableSuggestions: false,
              autocorrect: false,
              cursorWidth: 0,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                isCollapsed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({required this.digit, required this.focused});

  final String? digit;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.secondary : AppColors.inputBorder,
        ),
      ),
      child: Center(
        child: Text(
          filled ? digit! : '–',
          style: TextStyle(
            color: filled ? AppColors.loginNavy : AppColors.inputHint,
            fontSize: filled ? 20 : 18,
            fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class PhoneVerifyArt extends StatelessWidget {
  const PhoneVerifyArt({this.codeLabel = '******', super.key});

  final String codeLabel;

  @override
  Widget build(BuildContext context) {
    final artHeight = (MediaQuery.sizeOf(context).height * 0.16)
        .clamp(96.0, 148.0)
        .toDouble();
    return SizedBox(
      height: artHeight,
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 280,
          height: 148,
          child: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0x1419A10F),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 128, height: 128),
          ),
          const Positioned(
            left: 36,
            bottom: 18,
            child: Icon(Icons.eco, color: Color(0xFF7DCEA0), size: 28),
          ),
          const Positioned(
            right: 42,
            bottom: 14,
            child: Icon(Icons.eco, color: AppColors.loginPrimary, size: 34),
          ),
          const _PhoneGlyph(),
          Positioned(right: 28, top: 18, child: _CodeBubble(label: codeLabel)),
        ],
          ),
        ),
      ),
    );
  }
}

class _PhoneGlyph extends StatelessWidget {
  const _PhoneGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 112,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.loginNavy, width: 2.5),
      ),
      child: const Icon(
        Icons.phone_in_talk,
        color: AppColors.loginPrimary,
        size: 36,
      ),
    );
  }
}

class _CodeBubble extends StatelessWidget {
  const _CodeBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.loginPrimary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
