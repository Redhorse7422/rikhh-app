import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/sf_pro_fonts.dart';

/// Modern App Logo Component for Rikhh
///
/// This component provides different variants of the Rikhh logo:
/// - Horizontal: Logo with text side by side
/// - Vertical: Logo stacked above text
/// - Icon only: Just the logo symbol
/// - Compact: Smaller version for headers
class AppLogo extends StatelessWidget {
  final AppLogoVariant variant;
  final double? size;
  final Color? color;
  final Color? textColor;
  final bool showTagline;
  final String? customTagline;

  const AppLogo({
    super.key,
    this.variant = AppLogoVariant.horizontal,
    this.size,
    this.color,
    this.textColor,
    this.showTagline = false,
    this.customTagline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final logoColor = color ?? AppColors.primary;
    final textColorValue =
        textColor ?? (isDark ? Colors.white : AppColors.heading);

    switch (variant) {
      case AppLogoVariant.horizontal:
        return _buildHorizontalLogo(logoColor, textColorValue);
      case AppLogoVariant.vertical:
        return _buildVerticalLogo(logoColor, textColorValue);
      case AppLogoVariant.iconOnly:
        return _buildIconOnly(logoColor);
      case AppLogoVariant.compact:
        return _buildCompactLogo(logoColor, textColorValue);
    }
  }

  Widget _buildHorizontalLogo(Color logoColor, Color textColor) {
    final logoSize = size ?? 32.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(logoColor, logoSize),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rikhh',
              style: SFProFonts.displayMedium(
                color: textColor,
                fontSize: logoSize * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: 2),
              Text(
                customTagline ?? 'Shop Smart',
                style: SFProFonts.caption(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: logoSize * 0.25,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalLogo(Color logoColor, Color textColor) {
    final logoSize = size ?? 40.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(logoColor, logoSize),
        const SizedBox(height: 8),
        Text(
          'Rikhh',
          style: SFProFonts.displayMedium(
            color: textColor,
            fontSize: logoSize * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            customTagline ?? 'Shop Smart',
            style: SFProFonts.caption(
              color: textColor.withValues(alpha: 0.7),
              fontSize: logoSize * 0.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconOnly(Color logoColor) {
    final logoSize = size ?? 32.0;
    return _buildLogoIcon(logoColor, logoSize);
  }

  Widget _buildCompactLogo(Color logoColor, Color textColor) {
    final logoSize = size ?? 24.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoIcon(logoColor, logoSize),
        const SizedBox(width: 8),
        Text(
          'Rikhh',
          style: SFProFonts.titleLarge(
            color: textColor,
            fontSize: logoSize * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoIcon(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withValues(alpha: 0.8)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _LogoPatternPainter(color: color.withValues(alpha: 0.1)),
            ),
          ),
          // Main logo symbol
          Center(
            child: CustomPaint(
              size: Size(size * 0.6, size * 0.6),
              painter: _RikhhSymbolPainter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo variants for different use cases
enum AppLogoVariant {
  horizontal, // Logo and text side by side
  vertical, // Logo above text
  iconOnly, // Just the logo symbol
  compact, // Smaller version for headers
}

/// Custom painter for the Rikhh logo symbol
class _RikhhSymbolPainter extends CustomPainter {
  final Color color;

  _RikhhSymbolPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    // Create a modern "R" shape with geometric elements
    // Main vertical line
    path.moveTo(centerX - radius * 0.6, centerY - radius * 0.8);
    path.lineTo(centerX - radius * 0.6, centerY + radius * 0.8);

    // Top horizontal line
    path.moveTo(centerX - radius * 0.6, centerY - radius * 0.8);
    path.lineTo(centerX + radius * 0.4, centerY - radius * 0.8);

    // Curved top right
    path.quadraticBezierTo(
      centerX + radius * 0.6,
      centerY - radius * 0.8,
      centerX + radius * 0.6,
      centerY - radius * 0.4,
    );

    // Diagonal line
    path.moveTo(centerX - radius * 0.6, centerY);
    path.lineTo(centerX + radius * 0.6, centerY + radius * 0.8);

    canvas.drawPath(path, paint);

    // Add a small circle accent
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX + radius * 0.2, centerY - radius * 0.2),
      radius * 0.15,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter for background pattern
class _LogoPatternPainter extends CustomPainter {
  final Color color;

  _LogoPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create subtle geometric pattern
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final x = (size.width / 3) * i + (size.width / 6);
        final y = (size.height / 3) * j + (size.height / 6);

        canvas.drawCircle(Offset(x, y), size.width * 0.02, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Predefined logo sizes for common use cases
class AppLogoSize {
  static const double small = 24.0;
  static const double medium = 32.0;
  static const double large = 48.0;
  static const double xlarge = 64.0;
}

/// Helper class for easy logo usage
class RikhhLogo {
  /// Logo for app bar/toolbar
  static Widget appBar({Color? color}) => AppLogo(
    variant: AppLogoVariant.compact,
    size: AppLogoSize.small,
    color: color,
  );

  /// Logo for splash screen
  static Widget splash({Color? color, Color? textColor}) => AppLogo(
    variant: AppLogoVariant.vertical,
    size: AppLogoSize.xlarge,
    color: color,
    textColor: textColor,
    showTagline: true,
  );

  /// Logo for authentication screens
  static Widget auth({Color? color, Color? textColor}) => AppLogo(
    variant: AppLogoVariant.vertical,
    size: AppLogoSize.large,
    color: color,
    textColor: textColor,
    showTagline: true,
  );

  /// Logo for home screen header
  static Widget home({Color? color, Color? textColor}) => AppLogo(
    variant: AppLogoVariant.horizontal,
    size: AppLogoSize.medium,
    color: color,
    textColor: textColor,
  );

  /// Icon only for buttons or small spaces
  static Widget icon({Color? color, double? size}) => AppLogo(
    variant: AppLogoVariant.iconOnly,
    size: size ?? AppLogoSize.small,
    color: color,
  );
}
