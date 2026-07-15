import 'package:flutter/material.dart';
import '../models/auth_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthModeTabs extends StatelessWidget {
  final AuthTab activeTab;
  final ValueChanged<AuthTab> onTabChanged;

  const AuthModeTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final tabWidth = totalWidth / 2;
        final activeIndex = activeTab == AuthTab.login ? 0 : 1;

        return SizedBox(
          height: 58,
          width: totalWidth,
          child: Stack(
            children: [
              // 1. Bottom border line across full width
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                ),
              ),

              // 2. Animated active tab underline in neon lime
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: activeIndex * tabWidth,
                bottom: 0,
                width: tabWidth,
                height: 2,
                child: Container(color: AppColors.authNeonLime),
              ),

              // 3. Tab buttons
              Row(
                children: [
                  // Login Tab
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(AuthTab.login),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                          style: AppTypography.getAuthTab(
                            activeTab == AuthTab.login
                                ? AppColors.authNeonLime
                                : (isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText),
                            isActive: activeTab == AuthTab.login,
                          ),
                          child: const Text('Login'),
                        ),
                      ),
                    ),
                  ),

                  // Sign Up Tab
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabChanged(AuthTab.signUp),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeIn,
                          style: AppTypography.getAuthTab(
                            activeTab == AuthTab.signUp
                                ? AppColors.authNeonLime
                                : (isDark
                                      ? AppColors.darkSecondaryText
                                      : AppColors.lightSecondaryText),
                            isActive: activeTab == AuthTab.signUp,
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
