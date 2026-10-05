import 'package:flutter/material.dart';

import '../../../../app/responsive_layout.dart';

/// Scrolls the form. Don't swap this widget when the keyboard opens, or the
/// field loses focus and the typed text never lands.
class AuthFormViewport extends StatelessWidget {
  const AuthFormViewport({
    required this.metrics,
    required this.child,
    super.key,
  });

  final AuthFormMetrics metrics;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = metrics.tabletCenteredForm
            ? metrics.formMaxWidth
            : constraints.maxWidth - (metrics.horizontalPadding * 2);

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                metrics.horizontalPadding,
                metrics.scrollPaddingTop,
                metrics.horizontalPadding,
                metrics.formPaddingBottom,
              ),
              child: Center(
                child: SizedBox(
                  width: width,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
