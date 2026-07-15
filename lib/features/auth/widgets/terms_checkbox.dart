import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../../../core/theme/app_colors.dart';

class TermsAgreementCheckbox extends ConsumerWidget {
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const TermsAgreementCheckbox({
    super.key,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color baseTextColor = isDark ? Colors.white70 : Colors.black87;
    final Color borderCol = state.termsError != null
        ? AppColors.authError
        : (isDark ? AppColors.authMutedTextDark : AppColors.lightMutedText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            notifier.setAgreeToTerms(!state.agreeToTerms);
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom styled checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(top: 2, right: 12),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: state.agreeToTerms
                      ? AppColors.authNeonLime
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: state.agreeToTerms
                        ? AppColors.authNeonLime
                        : borderCol,
                    width: 1.8,
                  ),
                ),
                child: state.agreeToTerms
                    ? const Icon(Icons.check, color: Colors.black, size: 18)
                    : null,
              ),

              // Agreement text with tappable spans
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'SF ProText',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: baseTextColor,
                      height: 1.3,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: AppColors.authNeonLime,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.authNeonLime,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = onPrivacyTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.termsError != null)
          Padding(
            padding: const EdgeInsets.only(left: 38, top: 6),
            child: Text(
              state.termsError!,
              style: const TextStyle(
                color: AppColors.authError,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
