import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthTagline extends StatelessWidget {
  const AuthTagline({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseStyle = AppTypography.getAuthTagline(
      isDark ? Colors.white : AppColors.lightPrimaryText,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'Where\n'),
            TextSpan(
              text: 'connections\n',
              style: baseStyle.copyWith(
                color: AppColors.authNeonLime,
                fontWeight: FontWeight.w600,
              ),
            ),
            const TextSpan(text: 'come alive.'),
          ],
        ),
      ),
    );
  }
}
