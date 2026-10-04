import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

/// Email or phone choice on the sign-in, create-account, and forgot-password forms.
class AuthMethodToggle extends StatelessWidget {
  const AuthMethodToggle({
    required this.usePhone,
    required this.onChanged,
    this.fontSize = 15,
    super.key,
  });

  final bool usePhone;
  final ValueChanged<bool> onChanged;
  final double fontSize;

  static const double _radius = 14;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF142D24).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.78),
                  const Color(0xFFF7F9F8).withValues(alpha: 0.55),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _AuthMethodSegment(
                    label: 'Email',
                    fontSize: fontSize,
                    selected: !usePhone,
                    onTap: () => onChanged(false),
                  ),
                  _AuthMethodSegment(
                    label: 'Phone',
                    fontSize: fontSize,
                    selected: usePhone,
                    onTap: () => onChanged(true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthMethodSegment extends StatelessWidget {
  const _AuthMethodSegment({
    required this.label,
    required this.fontSize,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: selected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.lerp(AppColors.loginPrimary, Colors.white, 0.22)!,
                      AppColors.loginPrimary,
                    ],
                  )
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.loginPrimary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: selected ? null : onTap,
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 40,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.loginNavy,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
