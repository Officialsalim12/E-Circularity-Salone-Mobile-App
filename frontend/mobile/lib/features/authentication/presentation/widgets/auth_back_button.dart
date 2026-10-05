import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

/// Back button, kept above the scrolling form.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    required this.onPressed,
    required this.horizontalPadding,
    super.key,
  });

  final VoidCallback onPressed;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final inset = (horizontalPadding - 8).clamp(0.0, 24.0);

    return SizedBox(
      height: 44,
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: inset),
          child: IconButton(
            onPressed: onPressed,
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.loginNavy,
              size: 24,
            ),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: AppColors.loginNavy,
            ),
          ),
        ),
      ),
    );
  }
}
