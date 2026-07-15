import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_gradient_overlay.dart';
import '../widgets/auth_intro_section.dart';
import '../widgets/auth_legal_text.dart';
import '../widgets/auth_mode_tabs.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_tagline.dart';
import '../widgets/forgot_password_button.dart';
import '../widgets/glass_auth_text_field.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/social_auth_divider.dart';
import 'signup_screen.dart';
import '../../home/screens/social_home_screen.dart';
import '../../../core/theme/app_colors.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle successful navigation
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SocialHomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password reset link sent to your email.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTermsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Terms of Service...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handlePrivacyTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Privacy Policy...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final notifier = ref.read(authProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double socialSpacing = screenWidth < 360 ? 18 : 32;

    // Listen to success status for navigation
    ref.listen(authProvider, (previous, next) {
      if (next.isSuccess && !next.isLoading) {
        _navigateToHome();
      }
      if (next.generalError != null &&
          next.generalError != previous?.generalError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.generalError!),
            backgroundColor: AppColors.authError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: isDark
            ? AppColors.authBackground
            : const Color(0xFFF5F6F8),
        body: AuthBackground(
          child: Stack(
            children: [
              // Cinematic dark/light gradient overlay matching the theme brightness
              AuthGradientOverlay(isDark: isDark),

              // Vertically scrollable form elements to remain responsive
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenHeight = constraints.maxHeight;

                    // Responsive vertical spacing adjustment
                    final double topHeaderGap = screenHeight < 680 ? 12 : 24;
                    final double taglineIntroGap = screenHeight < 680
                        ? screenHeight * 0.04
                        : screenHeight * 0.08;
                    final double introFormGap = screenHeight < 680 ? 16 : 28;
                    final double formCtaGap = screenHeight < 680 ? 12 : 24;
                    final double bottomPadding = screenHeight < 680 ? 20 : 40;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: topHeaderGap),

                          // Brand Header
                          const AuthBrandHeader(),

                          SizedBox(height: taglineIntroGap),

                          // Upper Right Tagline
                          const AuthTagline(),

                          SizedBox(height: taglineIntroGap * 0.9),

                          // Welcome Introduction Section
                          AuthIntroSection(activeTab: state.activeTab),

                          SizedBox(height: introFormGap),

                          // Custom Login / Sign Up Tabs
                          AuthModeTabs(
                            activeTab: state.activeTab,
                            onTabChanged: (tab) {
                              if (tab == AuthTab.signUp) {
                                Navigator.of(context)
                                    .push(
                                      PageRouteBuilder(
                                        pageBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                            ) => const SignupScreen(),
                                        transitionsBuilder:
                                            (
                                              context,
                                              animation,
                                              secondaryAnimation,
                                              child,
                                            ) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: child,
                                              );
                                            },
                                        transitionDuration: const Duration(
                                          milliseconds: 250,
                                        ),
                                      ),
                                    )
                                    .then((_) {
                                      // Reset active tab to login when returning
                                      notifier.switchTab(AuthTab.login);
                                    });
                              } else {
                                notifier.switchTab(tab);
                                _emailController.clear();
                                _passwordController.clear();
                              }
                            },
                          ),

                          SizedBox(height: introFormGap),

                          // Username / Email Field
                          GlassAuthTextField(
                            key: const ValueKey('email_field'),
                            controller: _emailController,
                            hintText: 'Email or username',
                            leadingIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.email,
                              AutofillHints.username,
                            ],
                            errorText: state.emailError,
                            onChanged: notifier.setEmail,
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          GlassAuthTextField(
                            key: const ValueKey('password_field'),
                            controller: _passwordController,
                            hintText: 'Password',
                            leadingIcon: Icons.lock_outline_rounded,
                            obscureText: state.isPasswordObscured,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            errorText: state.passwordError,
                            onChanged: notifier.setPassword,
                            onFieldSubmitted: (_) => notifier.submit(),
                            suffixIcon: Semantics(
                              label: state.isPasswordObscured
                                  ? 'Show password'
                                  : 'Hide password',
                              child: InkWell(
                                onTap: notifier.toggleObscurePassword,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    state.isPasswordObscured
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: isDark
                                        ? AppColors.darkMutedText
                                        : AppColors.lightMutedText,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Forgot Password link (only in Login mode)
                          if (state.activeTab == AuthTab.login) ...[
                            const SizedBox(height: 12),
                            ForgotPasswordButton(onTap: _handleForgotPassword),
                          ],

                          SizedBox(height: formCtaGap),

                          // General Submission Error Message
                          if (state.generalError != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Text(
                                state.generalError!,
                                style: const TextStyle(
                                  color: AppColors.authError,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                          // Main Action CTA Button
                          AuthPrimaryButton(
                            text: state.activeTab == AuthTab.login
                                ? 'Login'
                                : 'Sign Up',
                            isLoading: state.isLoading,
                            isDisabled: state.isLoading,
                            onPressed: () async {
                              // Hide keyboard before submission
                              FocusScope.of(context).unfocus();
                              await notifier.submit();
                            },
                          ),

                          SizedBox(height: formCtaGap * 1.1),

                          // Social Login Divider
                          const SocialAuthDivider(),

                          // Social Login buttons: Google, Apple, Facebook
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialAuthButton(
                                provider: SocialProvider.google,
                                isDisabled: state.isLoading,
                                onTap: () async {
                                  final ok = await notifier
                                      .authenticateWithGoogle();
                                  if (ok) _navigateToHome();
                                },
                              ),
                              SizedBox(width: socialSpacing),
                              SocialAuthButton(
                                provider: SocialProvider.apple,
                                isDisabled: state.isLoading,
                                onTap: () async {
                                  final ok = await notifier
                                      .authenticateWithApple();
                                  if (ok) _navigateToHome();
                                },
                              ),
                              SizedBox(width: socialSpacing),
                              SocialAuthButton(
                                provider: SocialProvider.facebook,
                                isDisabled: state.isLoading,
                                onTap: () async {
                                  final ok = await notifier
                                      .authenticateWithFacebook();
                                  if (ok) _navigateToHome();
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: taglineIntroGap * 1.2),

                          // Bottom Legal Text
                          AuthLegalText(
                            onTermsTap: _handleTermsTap,
                            onPrivacyTap: _handlePrivacyTap,
                          ),

                          SizedBox(height: bottomPadding),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
