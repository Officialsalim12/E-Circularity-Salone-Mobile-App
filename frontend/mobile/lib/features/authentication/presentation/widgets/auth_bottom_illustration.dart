import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

/// Picture under the form. Hidden while the keyboard is open.
class AuthBottomIllustration extends StatelessWidget {
  const AuthBottomIllustration({
    required this.asset,
    required this.width,
    required this.maxHeight,
    this.bottomInset = 0,
    this.topGap = 8,
    super.key,
  });

  final String asset;
  final double width;
  final double maxHeight;
  final double bottomInset;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen =
        MediaQueryData.fromView(View.of(context)).viewInsets.bottom > 0;
    if (keyboardOpen || maxHeight <= 0 || width <= 0) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: topGap,
          bottom: bottomInset,
        ),
        child: SizedBox(
          width: width,
          height: maxHeight,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              child: Image.asset(asset),
            ),
          ),
        ),
      ),
    );
  }
}
