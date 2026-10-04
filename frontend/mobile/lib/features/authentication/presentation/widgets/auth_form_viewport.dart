import 'package:flutter/material.dart';

import '../../../../app/responsive_layout.dart';

/// Auth form area: fixed viewport on phones (no scroll), scroll when keyboard
/// is open or on tablet-wide layouts.
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
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final useScroll = metrics.allowScroll || keyboardOpen;

    Widget formArea({required double width}) {
      final form = SizedBox(
        width: width,
        child: child,
      );

      return Padding(
        padding: EdgeInsets.fromLTRB(
          metrics.horizontalPadding,
          metrics.scrollPaddingTop,
          metrics.horizontalPadding,
          metrics.formPaddingBottom,
        ),
        child: Center(child: form),
      );
    }

    if (useScroll) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final width = metrics.tabletCenteredForm
              ? metrics.formMaxWidth
              : constraints.maxWidth - (metrics.horizontalPadding * 2);

          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: formArea(width: width),
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - (metrics.horizontalPadding * 2);

        final fitted = FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(
            width: constraints.maxWidth,
            child: formArea(width: width),
          ),
        );

        return Align(
          alignment: Alignment.center,
          child: fitted,
        );
      },
    );
  }
}
