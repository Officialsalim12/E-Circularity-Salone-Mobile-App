import 'package:flutter/material.dart';

/// Breakpoints aligned with [design.json] responsive section.
enum ScreenSizeClass {
  mobile,
  tablet,
  desktop,
}

enum AuthIllustrationPreset {
  login,
  signup,
}

/// Phone viewport height bands (logical pixels, post–SafeArea body).
enum MobileHeightTier {
  compact,
  standard,
  large,
}

class ResponsiveLayout {
  ResponsiveLayout._();

  static const double tabletMinWidth = 600;
  static const double desktopMinWidth = 900;
  static const double authFormMaxWidth = 440;

  static const double _compactHeightMax = 620;
  static const double _largeHeightMin = 780;

  static ScreenSizeClass sizeClass(double width) {
    if (width >= desktopMinWidth) {
      return ScreenSizeClass.desktop;
    }
    if (width >= tabletMinWidth) {
      return ScreenSizeClass.tablet;
    }
    return ScreenSizeClass.mobile;
  }

  static bool isMobileWidth(double width) =>
      sizeClass(width) == ScreenSizeClass.mobile;

  /// Full-width phone auth/onboarding (same as narrow login), including wide
  /// but short web preview panels (e.g. 812×637).
  static bool usePhoneLayout(double width, double height) {
    if (width < tabletMinWidth) {
      return true;
    }
    if (height < 720) {
      return true;
    }
    return false;
  }

  static double contentHorizontalPadding(double width, double height) {
    if (usePhoneLayout(width, height)) {
      return width >= 360 ? 16 : 12;
    }
    return horizontalGutter(width);
  }

  static MobileHeightTier heightTier(double height) {
    if (height < _compactHeightMax) {
      return MobileHeightTier.compact;
    }
    if (height >= _largeHeightMin) {
      return MobileHeightTier.large;
    }
    return MobileHeightTier.standard;
  }

  /// Typography and control scale for phones (larger on tall devices).
  static double mobileContentScale(MobileHeightTier tier) {
    switch (tier) {
      case MobileHeightTier.compact:
        return 0.86;
      case MobileHeightTier.standard:
        return 1.0;
      case MobileHeightTier.large:
        return 1.1;
    }
  }

  static double horizontalGutter(double width) {
    switch (sizeClass(width)) {
      case ScreenSizeClass.desktop:
      case ScreenSizeClass.tablet:
        return 32;
      case ScreenSizeClass.mobile:
        return width >= 360 ? 24 : 20;
    }
  }

  static MediaQueryData clampTextScale(
    BuildContext context, {
    double maxScaleFactor = 1.2,
  }) {
    return MediaQuery.of(context).copyWith(
      textScaler: MediaQuery.textScalerOf(context).clamp(
        maxScaleFactor: maxScaleFactor,
      ),
    );
  }
}

/// Spacing and typography for auth screens with bottom illustration.
class AuthFormMetrics {
  AuthFormMetrics({
    required double height,
    required double width,
    AuthIllustrationPreset illustration = AuthIllustrationPreset.login,
  }) {
    final isSignup = illustration == AuthIllustrationPreset.signup;
    final phoneLayout = ResponsiveLayout.usePhoneLayout(width, height);
    final tier = ResponsiveLayout.heightTier(height);
    final scale = phoneLayout
        ? ResponsiveLayout.mobileContentScale(tier)
        : (tier == MobileHeightTier.large ? 1.05 : 1.0);
    final cappedTabletForm = !phoneLayout &&
        width >= ResponsiveLayout.tabletMinWidth;

    allowScroll = !phoneLayout;
    tabletCenteredForm = cappedTabletForm;
    contentScale = scale;
    heightTier = tier;

    horizontalPadding =
        ResponsiveLayout.contentHorizontalPadding(width, height);
    formMaxWidth = cappedTabletForm
        ? ResponsiveLayout.authFormMaxWidth
        : width - (horizontalPadding * 2);

    final logoCap = cappedTabletForm
        ? 300.0
        : (tier == MobileHeightTier.large ? 300.0 : 280.0);
    logoWidth = (formMaxWidth * (0.88 + (scale - 1) * 0.15)).clamp(180 * scale, logoCap);

    illustrationHeight = _illustrationHeight(
      height: height,
      tier: tier,
      preset: illustration,
      isMobile: phoneLayout,
    );

    titleFontSize = _scaled(26, scale, min: 21, max: 30);
    subtitleFontSize = _scaled(15, scale, min: 12, max: 17);
    linkFontSize = _scaled(15, scale, min: 12, max: 16);
    fieldFontSize = _scaled(15, scale, min: 13, max: 16);
    fieldVerticalPadding = _scaled(16, scale, min: 10, max: 18);
    primaryButtonHeight = _scaled(56, scale, min: 46, max: 60);
    final gapScale = isSignup ? scale * 0.92 : scale;
    fieldGap = _scaled(12, gapScale, min: 5, max: 14);
    blockGap = _scaled(isSignup ? 14 : 18, gapScale, min: 8, max: 20);
    footerGap = _scaled(14, gapScale, min: 6, max: 16);

    formPaddingBottom = switch (tier) {
      MobileHeightTier.compact => 8.0,
      MobileHeightTier.standard => isSignup ? 2.0 : 4.0,
      MobileHeightTier.large => 0.0,
    };
    illustrationTopGap = 0;
    scrollPaddingTop = tier == MobileHeightTier.large
        ? _scaled(4, scale, min: 2, max: 8)
        : _scaled(8, scale, min: 4, max: 16);
  }

  late final bool allowScroll;
  late final bool tabletCenteredForm;
  late final double contentScale;
  late final MobileHeightTier heightTier;
  late final double horizontalPadding;
  late final double formMaxWidth;
  late final double logoWidth;
  late final double illustrationHeight;
  late final double scrollPaddingTop;
  late final double titleFontSize;
  late final double subtitleFontSize;
  late final double linkFontSize;
  late final double fieldFontSize;
  late final double fieldVerticalPadding;
  late final double primaryButtonHeight;
  late final double fieldGap;
  late final double blockGap;
  late final double footerGap;
  late final double formPaddingBottom;
  late final double illustrationTopGap;

  static double _scaled(
    double base,
    double scale, {
    required double min,
    required double max,
  }) {
    return (base * scale).clamp(min, max);
  }

  static double _illustrationHeight({
    required double height,
    required MobileHeightTier tier,
    required AuthIllustrationPreset preset,
    required bool isMobile,
  }) {
    if (preset == AuthIllustrationPreset.signup) {
      final factor = switch (tier) {
        MobileHeightTier.compact => 0.14,
        MobileHeightTier.standard => 0.18,
        MobileHeightTier.large => 0.22,
      };
      final min = switch (tier) {
        MobileHeightTier.compact => 90.0,
        MobileHeightTier.standard => 110.0,
        MobileHeightTier.large => 130.0,
      };
      final max = switch (tier) {
        MobileHeightTier.compact => 150.0,
        MobileHeightTier.standard => 180.0,
        MobileHeightTier.large => 210.0,
      };
      return (height * factor).clamp(min, max);
    }

    final factor = switch (tier) {
      MobileHeightTier.compact => 0.28,
      MobileHeightTier.standard => 0.32,
      MobileHeightTier.large => 0.34,
    };
    final min = switch (tier) {
      MobileHeightTier.compact => 150.0,
      MobileHeightTier.standard => 180.0,
      MobileHeightTier.large => 200.0,
    };
    final max = switch (tier) {
      MobileHeightTier.compact => 220.0,
      MobileHeightTier.standard => 270.0,
      MobileHeightTier.large => 300.0,
    };
    final raw = (height * factor).clamp(min, max);
    if (!isMobile && tier == MobileHeightTier.large) {
      return raw * 1.05;
    }
    return raw;
  }
}

/// Onboarding copy and control spacing by viewport.
class OnboardingLayoutMetrics {
  OnboardingLayoutMetrics({
    required double height,
    required double width,
  }) {
    final tier = ResponsiveLayout.heightTier(height);
    final phoneLayout = ResponsiveLayout.usePhoneLayout(width, height);
    final scale = phoneLayout
        ? ResponsiveLayout.mobileContentScale(tier)
        : 1.0;
    final cappedTabletContent = !phoneLayout &&
        width >= ResponsiveLayout.tabletMinWidth;

    horizontalPadding =
        ResponsiveLayout.contentHorizontalPadding(width, height);
    contentMaxWidth = cappedTabletContent
        ? 480.0
        : width - (horizontalPadding * 2);
    illustrationMaxWidth =
        contentMaxWidth * (0.92 + (scale - 1) * 0.08).clamp(0.85, 1.05);

    headingFontSize = AuthFormMetrics._scaled(28, scale, min: 22, max: 32);
    descriptionFontSize = AuthFormMetrics._scaled(15, scale, min: 12, max: 17);
    illustrationFlex = switch (tier) {
      MobileHeightTier.compact => 8,
      MobileHeightTier.standard => 11,
      MobileHeightTier.large => 12,
    };
    textBlockFlex = switch (tier) {
      MobileHeightTier.compact => 12,
      MobileHeightTier.standard => 10,
      MobileHeightTier.large => 10,
    };
    progressDotsGap = AuthFormMetrics._scaled(24, scale, min: 16, max: 28);
    bottomPadding = tier == MobileHeightTier.compact ? 4 : 8;
    compactHeight = tier == MobileHeightTier.compact;
    primaryButtonHeight = AuthFormMetrics._scaled(48, scale, min: 42, max: 52);
  }

  late final bool compactHeight;
  late final double horizontalPadding;
  late final double contentMaxWidth;
  late final double illustrationMaxWidth;
  late final double headingFontSize;
  late final double descriptionFontSize;
  late final int illustrationFlex;
  late final int textBlockFlex;
  late final double progressDotsGap;
  late final double bottomPadding;
  late final double primaryButtonHeight;
}
