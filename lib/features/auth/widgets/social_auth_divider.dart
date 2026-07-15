import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SocialAuthDivider extends StatelessWidget {
  const SocialAuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lineColor = isDark
        ? Colors.white.withOpacity(0.2)
        : Colors.black.withOpacity(0.15);

    final textColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmall = screenWidth < 360;

    final textStr = isSmall ? 'or' : 'or continue with';
    final horizontalPadding = isSmall ? 8.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: lineColor)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Text(
              textStr,
              style: AppTypography.getAuthDividerText(textColor),
            ),
          ),
          Expanded(child: Container(height: 1, color: lineColor)),
        ],
      ),
    );
  }
}
