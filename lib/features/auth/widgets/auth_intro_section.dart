import 'package:flutter/material.dart';
import '../models/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class BrushUnderlinePainter extends CustomPainter {
  final Color color;

  BrushUnderlinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Drawing an organic, hand-drawn brush stroke
    path.moveTo(w * 0.02, h * 0.45);
    path.cubicTo(w * 0.25, h * 0.15, w * 0.65, h * 0.10, w * 0.98, h * 0.35);
    path.cubicTo(w * 0.95, h * 0.75, w * 0.70, h * 0.90, w * 0.48, h * 0.85);
    path.cubicTo(w * 0.25, h * 0.80, w * 0.08, h * 0.70, w * 0.02, h * 0.45);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthIntroSection extends StatelessWidget {
  final AuthTab activeTab;

  const AuthIntroSection({super.key, required this.activeTab});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final welcomeStyle = AppTypography.getAuthWelcome(
      isDark ? Colors.white : AppColors.lightPrimaryText,
    );

    final subtitleStyle = AppTypography.getAuthSubtitle(
      isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    );

    final isLogin = activeTab == AuthTab.login;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading with organic brush underline
        isLogin
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Welcome ', style: welcomeStyle),
                    WidgetSpan(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Text('back', style: welcomeStyle),
                          Positioned(
                            left: -4,
                            right: -4,
                            bottom: -6,
                            height: 10,
                            child: CustomPaint(
                              painter: BrushUnderlinePainter(
                                color: AppColors.authNeonLime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: ' 💜',
                      style: welcomeStyle.copyWith(
                        color: AppColors.authPurpleHeart,
                      ),
                    ),
                  ],
                ),
              )
            : Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Get ', style: welcomeStyle),
                    WidgetSpan(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Text('started', style: welcomeStyle),
                          Positioned(
                            left: -4,
                            right: -4,
                            bottom: -6,
                            height: 10,
                            child: CustomPaint(
                              painter: BrushUnderlinePainter(
                                color: AppColors.authNeonLime,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: ' 💜',
                      style: welcomeStyle.copyWith(
                        color: AppColors.authPurpleHeart,
                      ),
                    ),
                  ],
                ),
              ),
        const SizedBox(height: 16),
        // Subtitle
        Text(
          isLogin
              ? 'Login to continue your journey\nand meet amazing people.'
              : 'Sign up to continue your journey\nand meet amazing people.',
          style: subtitleStyle,
        ),
      ],
    );
  }
}
