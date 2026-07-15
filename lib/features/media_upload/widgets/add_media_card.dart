import 'dart:math';
import 'package:flutter/material.dart';

class AddMoreMediaCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddMoreMediaCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme colors
    final primaryTextColor = isDark
        ? const Color(0xFFF7F7F8)
        : const Color(0xFF111216);
    final mutedTextColor = isDark
        ? const Color(0xFF6F7078)
        : const Color(0xFF92959D);
    final innerBtnColor = isDark
        ? const Color(0xFF0C0C0F)
        : const Color(0xFFFFFFFF);
    final innerBtnBorderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);
    final dashColor = isDark
        ? Colors.white.withOpacity(0.28)
        : Colors.black.withOpacity(0.28);
    const neonLime = Color(0xFFD2FF27);

    return Semantics(
      label: 'Add more media. Double tap to open media selector.',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: CustomPaint(
          painter: DashedBorderPainter(
            color: dashColor,
            strokeWidth: 1.5,
            radius: 18,
            dashPattern: const [6, 4],
          ),
          child: Container(
            width: 98,
            height: 198,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Add Button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: innerBtnColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: innerBtnBorderColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: neonLime, size: 30),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Add More Text
                  Text(
                    'Add More',
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // Subtitles
                  Text(
                    'Up to 10 photos',
                    style: TextStyle(
                      color: mutedTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'or 1 video',
                    style: TextStyle(
                      color: mutedTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final List<double> dashPattern;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = _buildDashedPath(path, dashPattern);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashedPath(Path source, List<double> pattern) {
    final path = Path();
    var distance = 0.0;

    for (final pathMetric in source.computeMetrics()) {
      var draw = true;
      while (distance < pathMetric.length) {
        final length = pattern[draw ? 0 : 1 % pattern.length];
        if (draw) {
          path.addPath(
            pathMetric.extractPath(
              distance,
              min(distance + length, pathMetric.length),
            ),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
      distance = 0.0; // reset for next metric
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
