import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoginRedirect extends StatelessWidget {
  final VoidCallback onTap;

  const LoginRedirect({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color baseColor = isDark
        ? AppColors.authSecondaryTextDark
        : AppColors.lightSecondaryText;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'SF ProText',
                fontSize: 17,
                fontWeight: FontWeight.w400,
                color: baseColor,
              ),
              children: const [
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Login',
                  style: TextStyle(
                    color: AppColors.authNeonLime,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
