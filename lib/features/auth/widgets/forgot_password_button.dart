import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onTap;

  const ForgotPasswordButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
          alignment: Alignment.centerRight,
          child: Text(
            'Forgot password?',
            style: AppTypography.getAuthForgotPassword(AppColors.authNeonLime),
          ),
        ),
      ),
    );
  }
}
