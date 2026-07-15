import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthLegalText extends StatefulWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const AuthLegalText({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  State<AuthLegalText> createState() => _AuthLegalTextState();
}

class _AuthLegalTextState extends State<AuthLegalText> {
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = widget.onTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = widget.onPrivacyTap;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseStyle = AppTypography.getAuthLegalText(
      isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText,
    );

    final linkStyle = baseStyle.copyWith(
      color: AppColors.authNeonLime,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.authNeonLime.withOpacity(0.3),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(text: 'By continuing, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: linkStyle,
              recognizer: _termsRecognizer,
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: _privacyRecognizer,
            ),
          ],
        ),
      ),
    );
  }
}
