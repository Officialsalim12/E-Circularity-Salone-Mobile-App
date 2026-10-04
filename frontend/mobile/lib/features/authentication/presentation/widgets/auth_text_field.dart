import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_colors.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    this.leadingText,
    this.fontSize = 15,
    this.verticalPadding = 16,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? leadingText;
  final double fontSize;
  final double verticalPadding;

  static const double radius = 10;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: AppColors.loginNavy,
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.inputHint,
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: _prefix(),
          prefixIconConstraints: leadingText == null
              ? null
              : const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: verticalPadding,
          ),
          border: _outline(color: AppColors.secondary),
          enabledBorder: _outline(color: AppColors.secondary),
          focusedBorder: _outline(color: AppColors.secondary),
          errorBorder: _outline(color: AppColors.loginPrimary),
          focusedErrorBorder: _outline(color: AppColors.loginPrimary),
        ),
    );
  }

  Widget _prefix() {
    final icon = Icon(
      prefixIcon,
      color: AppColors.inputHint,
      size: fontSize + 7,
    );
    final label = leadingText;
    if (label == null) {
      return icon;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.loginNavy,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(radius),
  );

  _EvenOutlineBorder _outline({required Color color}) {
    return _EvenOutlineBorder(
      borderRadius: _borderRadius,
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}

/// Outline drawn as a filled ring so every side is the same thickness.
///
/// [OutlineInputBorder] strokes the edge, which rasterizes the top side
/// heavier than the other three.
class _EvenOutlineBorder extends InputBorder {
  const _EvenOutlineBorder({
    required this.borderRadius,
    super.borderSide,
  });

  final BorderRadius borderRadius;

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  _EvenOutlineBorder copyWith({BorderSide? borderSide}) {
    return _EvenOutlineBorder(
      borderRadius: borderRadius,
      borderSide: borderSide ?? this.borderSide,
    );
  }

  @override
  _EvenOutlineBorder scale(double t) {
    return _EvenOutlineBorder(
      borderRadius: borderRadius * t,
      borderSide: borderSide.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _EvenOutlineBorder) {
      return _EvenOutlineBorder(
        borderRadius: BorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        borderSide: BorderSide.lerp(a.borderSide, borderSide, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _EvenOutlineBorder) {
      return _EvenOutlineBorder(
        borderRadius: BorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        borderSide: BorderSide.lerp(borderSide, b.borderSide, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(_innerRRect(rect));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  void paintInterior(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    TextDirection? textDirection,
  }) {
    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none || borderSide.width <= 0) {
      return;
    }

    canvas.drawDRRect(
      borderRadius.toRRect(rect),
      _innerRRect(rect),
      Paint()..color = borderSide.color,
    );
  }

  RRect _innerRRect(Rect rect) {
    return borderRadius.toRRect(rect).deflate(borderSide.width);
  }
}
