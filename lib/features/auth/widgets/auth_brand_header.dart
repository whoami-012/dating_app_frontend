import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class TreeLogoPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;

  TreeLogoPainter({required this.strokeColor, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw organic tree shape:
    // We start from the left side of the trunk
    path.moveTo(w * 0.46, h * 0.88);
    path.lineTo(w * 0.46, h * 0.68);

    // Left canopy curve (flared outward and upward)
    path.cubicTo(w * 0.12, h * 0.68, w * 0.08, h * 0.38, w * 0.28, h * 0.24);

    // Top center canopy curve
    path.cubicTo(w * 0.22, h * 0.02, w * 0.78, h * 0.02, w * 0.72, h * 0.24);

    // Right canopy curve (flared outward and downward)
    path.cubicTo(w * 0.92, h * 0.38, w * 0.88, h * 0.68, w * 0.54, h * 0.68);

    // Right side of the trunk
    path.lineTo(w * 0.54, h * 0.88);

    // Bottom root curve (slight curve to close trunk)
    path.quadraticBezierTo(w * 0.50, h * 0.86, w * 0.46, h * 0.88);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(36, 36),
          painter: TreeLogoPainter(
            strokeColor: AppColors.authNeonLime,
            strokeWidth: 2.2,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            'Social Tree',
            overflow: TextOverflow.ellipsis,
            style: AppTypography.getAuthBrand(
              isDark ? Colors.white : AppColors.lightPrimaryText,
            ),
          ),
        ),
      ],
    );
  }
}
