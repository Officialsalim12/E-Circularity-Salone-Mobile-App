import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';

/// Full-width bottom artwork for auth screens; keeps form content separate above.
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
    return ColoredBox(
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.only(
          top: topGap,
          bottom: bottomInset,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
          child: ClipRect(
            child: Image.asset(
              asset,
              width: width,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
      ),
    );
  }
}
