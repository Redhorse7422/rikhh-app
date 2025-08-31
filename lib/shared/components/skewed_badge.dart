import 'package:flutter/material.dart';

class SkewedBadge extends StatelessWidget {
  final String text;
  final Color color;

  const SkewedBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ReverseSkewWithRadiusClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        color: color,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ReverseSkewWithRadiusClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 12.0; // radius for top-left corner
    final path = Path();

    // Start with rounded top-left
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Top edge to top-right
    path.lineTo(size.width, 0);

    // Slant inward on bottom-right
    path.lineTo(size.width - 10, size.height);

    // Bottom-left corner
    path.lineTo(0, size.height);

    // Close path
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
