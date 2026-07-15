import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BrushUnderlinePainter extends CustomPainter {
  final Color color;

  BrushUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw an irregular brush stroke shape with a slight angle
    path.moveTo(0, h * 0.35);
    path.cubicTo(w * 0.25, h * 0.15, w * 0.65, h * 0.45, w, h * 0.10);
    path.cubicTo(w * 0.90, h * 0.80, w * 0.40, h * 0.95, w * 0.10, h * 0.85);
    path.quadraticBezierTo(w * 0.03, h * 0.80, 0, h * 0.35);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SignupIntroSection extends StatelessWidget {
  const SignupIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color titleColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark
        ? AppColors.authSecondaryTextDark
        : AppColors.lightSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Heading text with the purple heart
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'SF ProText',
              fontSize: 37,
              fontWeight: FontWeight.w800,
              color: titleColor,
              height: 1.1,
            ),
            children: const [
              TextSpan(text: 'Create Account '),
              TextSpan(
                text: '💜',
                style: TextStyle(
                  // Set fallback font or keep default to display the heart emoji cleanly
                  fontFamily: 'Apple Color Emoji',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        // Hand-drawn neon-lime underline
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: CustomPaint(
            size: const Size(100, 8),
            painter: BrushUnderlinePainter(color: AppColors.authNeonLime),
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle
        Text(
          'Join Social Tree and discover\namazing people around you.',
          style: TextStyle(
            fontFamily: 'SF ProText',
            fontSize: 19,
            fontWeight: FontWeight.w400,
            color: subtitleColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
