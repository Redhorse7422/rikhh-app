import 'package:flutter/widgets.dart';

/// Utilities to keep spacing and padding consistent across devices.
///
/// Uses a "design baseline" approach and scales values relative to the
/// current device's size. Defaults are based on a 375x812pt reference
/// (common iPhone baseline), with gentle clamping to avoid extremes.
class Responsive {
  /// Reference logical width used by designers (in logical pixels).
  static const double _referenceWidth = 375.0;

  /// Reference logical height used by designers (in logical pixels).
  static const double _referenceHeight = 812.0;

  /// Optional clamp range to avoid overly large or tiny scaling on extreme devices.
  static const double _minScale = 0.85;
  static const double _maxScale = 1.25;

  /// Device size breakpoints for responsive design
  // Device width breakpoints (in logical pixels)
  static const double _xxSmallScreenBreakpoint =
      280.0; // very tiny devices (old phones, foldables)
  static const double _xSmallScreenBreakpoint = 320.0; // iPhone SE
  static const double _smallScreenBreakpoint = 360.0;
  static const double _semiMediumScreenBreakpoint =
      400.0; // common small Androids
  static const double _mediumScreenBreakpoint =
      414.0; // larger phones (iPhone Plus/Pro Max)
  static const double _largeScreenBreakpoint = 480.0; // phablets
  static const double _xLargeScreenBreakpoint = 600.0; // 7" tablets (portrait)
  static const double _tabletScreenBreakpoint = 768.0; // iPad portrait
  static const double _desktopSmallBreakpoint =
      1024.0; // iPad landscape / small laptops
  static const double _desktopMediumBreakpoint = 1280.0; // standard laptops
  static const double _desktopLargeBreakpoint = 1440.0; // large monitors

  /// Scale a horizontal size based on screen width.
  static double scaleWidth(BuildContext context, double base) {
    final double width = MediaQuery.sizeOf(context).width;
    final double rawScale = width / _referenceWidth;
    final double scale = rawScale.clamp(_minScale, _maxScale);
    return base * scale;
  }

  /// Scale a vertical size based on screen height.
  static double scaleHeight(BuildContext context, double base) {
    final double height = MediaQuery.sizeOf(context).height;
    final double rawScale = height / _referenceHeight;
    final double scale = rawScale.clamp(_minScale, _maxScale);
    return base * scale;
  }

  /// Helper method for responsive padding.
  ///
  /// Provide base (design) padding values; the method returns properly
  /// scaled `EdgeInsets`. If only [horizontal] or [vertical] is given,
  /// symmetric padding is applied. If all four sides are provided, they
  /// will be scaled independently.
  static EdgeInsets padding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      final double h = scaleWidth(context, all);
      final double v = scaleHeight(context, all);
      return EdgeInsets.symmetric(horizontal: h, vertical: v);
    }

    if (horizontal != null || vertical != null) {
      final double h = scaleWidth(context, horizontal ?? 0);
      final double v = scaleHeight(context, vertical ?? 0);
      return EdgeInsets.symmetric(horizontal: h, vertical: v);
    }

    // Individual sides
    return EdgeInsets.fromLTRB(
      scaleWidth(context, left ?? 0),
      scaleHeight(context, top ?? 0),
      scaleWidth(context, right ?? 0),
      scaleHeight(context, bottom ?? 0),
    );
  }

  /// Helper method for responsive vertical spacing.
  ///
  /// Returns a `SizedBox` with height scaled relative to screen height.
  /// Example: `Responsive.vSpace(context, 16)`.
  static Widget vSpace(BuildContext context, double base) {
    return SizedBox(height: scaleHeight(context, base));
  }

  /// Optional: responsive horizontal spacing.
  static Widget hSpace(BuildContext context, double base) {
    return SizedBox(width: scaleWidth(context, base));
  }

  /// Get device size category for responsive design
  static DeviceSize getDeviceSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < _xxSmallScreenBreakpoint) {
      return DeviceSize.xxSmall;
    } else if (width < _xSmallScreenBreakpoint) {
      return DeviceSize.xSmall;
    } else if (width < _smallScreenBreakpoint) {
      return DeviceSize.small;
    } else if (width < _semiMediumScreenBreakpoint) {
      return DeviceSize.semiMedium;
    } else if (width < _mediumScreenBreakpoint) {
      return DeviceSize.medium;
    } else if (width < _largeScreenBreakpoint) {
      return DeviceSize.large;
    } else if (width < _xLargeScreenBreakpoint) {
      return DeviceSize.xLarge;
    } else if (width < _tabletScreenBreakpoint) {
      return DeviceSize.tablet;
    } else if (width < _desktopSmallBreakpoint) {
      return DeviceSize.desktopSmall;
    } else if (width < _desktopMediumBreakpoint) {
      return DeviceSize.desktopMedium;
    } else if (width < _desktopLargeBreakpoint) {
      return DeviceSize.desktopLarge;
    } else {
      return DeviceSize.ultraWide;
    }
  }

  /// Check screen sizes
  static bool isXXSmallScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.xxSmall;

  static bool isXSmallScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.xSmall;

  static bool isSmallScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.small;

  static bool isSemiMediumScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.semiMedium;

  static bool isMediumScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.medium;

  static bool isLargeScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.large;

  static bool isXLargeScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.xLarge;

  static bool isTabletScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.tablet;

  static bool isDesktopSmallScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.desktopSmall;

  static bool isDesktopMediumScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.desktopMedium;

  static bool isDesktopLargeScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.desktopLarge;

  static bool isUltraWideScreen(BuildContext context) =>
      getDeviceSize(context) == DeviceSize.ultraWide;

  /// Get responsive aspect ratio for product cards
  static double getProductCardAspectRatio(BuildContext context) {
    switch (getDeviceSize(context)) {
      case DeviceSize.xxSmall:
        return 0.55; // ultra tiny
      case DeviceSize.xSmall:
        return 0.60;
      case DeviceSize.small:
        return 0.65;
      case DeviceSize.semiMedium:
        return 0.65;
      case DeviceSize.medium:
        return 0.72;
      case DeviceSize.large:
        return 0.80;
      case DeviceSize.xLarge:
        return 0.82;
      case DeviceSize.tablet:
        return 0.84;
      case DeviceSize.desktopSmall:
        return 0.86;
      case DeviceSize.desktopMedium:
        return 0.88;
      case DeviceSize.desktopLarge:
        return 0.90;
      case DeviceSize.ultraWide:
        return 0.92; // very wide → more space
    }
  }

  /// Get responsive padding for product cards
  static double getProductCardPadding(BuildContext context) {
    switch (getDeviceSize(context)) {
      case DeviceSize.xxSmall:
        return 2.0;
      case DeviceSize.xSmall:
        return 4.0;
      case DeviceSize.small:
        return 4.0;
      case DeviceSize.semiMedium:
        return 6.0;
      case DeviceSize.medium:
        return 6.0;
      case DeviceSize.large:
        return 10.0;
      case DeviceSize.xLarge:
        return 12.0;
      case DeviceSize.tablet:
        return 14.0;
      case DeviceSize.desktopSmall:
        return 16.0;
      case DeviceSize.desktopMedium:
        return 18.0;
      case DeviceSize.desktopLarge:
        return 20.0;
      case DeviceSize.ultraWide:
        return 24.0;
    }
  }

  /// Get responsive font size for product cards
  static double getProductCardFontSize(
    BuildContext context, {
    double baseSize = 12.0,
  }) {
    switch (getDeviceSize(context)) {
      case DeviceSize.xxSmall:
        return baseSize - 5;
      case DeviceSize.xSmall:
        return baseSize - 4;
      case DeviceSize.small:
        return baseSize - 3;
      case DeviceSize.semiMedium:
        return baseSize - 2;
      case DeviceSize.medium:
        return baseSize - 1;
      case DeviceSize.large:
        return baseSize;
      case DeviceSize.xLarge:
        return baseSize + 1;
      case DeviceSize.tablet:
        return baseSize + 2;
      case DeviceSize.desktopSmall:
        return baseSize + 3;
      case DeviceSize.desktopMedium:
        return baseSize + 4;
      case DeviceSize.desktopLarge:
        return baseSize + 5;
      case DeviceSize.ultraWide:
        return baseSize + 6;
    }
  }

  /// Get responsive image height for product cards
  static double getProductCardImageHeight(BuildContext context) {
    switch (getDeviceSize(context)) {
      case DeviceSize.xxSmall:
        return 50.0; // very tiny devices
      case DeviceSize.xSmall:
        return 50.0;
      case DeviceSize.small:
        return 60.0;
      case DeviceSize.semiMedium:
        return 100.0;
      case DeviceSize.medium:
        return 120.0;
      case DeviceSize.large:
        return 120.0;
      case DeviceSize.xLarge:
        return 180.0;
      case DeviceSize.tablet:
        return 200.0;
      case DeviceSize.desktopSmall:
        return 220.0;
      case DeviceSize.desktopMedium:
        return 240.0;
      case DeviceSize.desktopLarge:
        return 260.0;
      case DeviceSize.ultraWide:
        return 280.0; // make use of wide screens
    }
  }
}

/// Enum for device size categories
enum DeviceSize {
  xxSmall, // < 280
  xSmall, // 280–319
  small, // 320–359
  semiMedium, // 360-400
  medium, // 400–413
  large, // 414–479
  xLarge, // 480–599
  tablet, // 600–767
  desktopSmall, // 768–1023
  desktopMedium, // 1024–1279
  desktopLarge, // 1280–1439
  ultraWide, // >= 1440
}
