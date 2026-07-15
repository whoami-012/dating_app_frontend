import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/signup_provider.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_gradient_overlay.dart';
import '../widgets/auth_tagline.dart';
import '../widgets/signup_intro.dart';
import '../widgets/glass_auth_text_field.dart';
import '../widgets/date_of_birth_selector.dart';
import '../widgets/terms_checkbox.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/social_auth_divider.dart';
import '../widgets/social_auth_button.dart';
import '../widgets/login_redirect.dart';
import '../../home/screens/social_home_screen.dart';
import '../../../core/theme/app_colors.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

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
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final double socialSpacing = screenWidth < 360 ? 18 : 32;

    // Listen to success status for navigation
    ref.listen(signupProvider, (previous, next) {
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
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: isDark
              ? AppColors.authBackground
              : const Color(0xFFF5F6F8),
          body: AuthBackground(
            child: Stack(
              children: [
                // Cinematic overlays
                AuthGradientOverlay(isDark: isDark),

                // Scrollable Form Layout
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenHeight = constraints.maxHeight;

                      // Responsive vertical spacing adjustment
                      final double topHeaderGap = screenHeight < 680 ? 12 : 24;
                      final double taglineIntroGap = screenHeight < 680
                          ? screenHeight * 0.04
                          : screenHeight * 0.06;
                      final double introFormGap = screenHeight < 680 ? 16 : 28;
                      final double formCtaGap = screenHeight < 680 ? 12 : 24;
                      final double bottomPadding = screenHeight < 680 ? 20 : 40;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: topHeaderGap),

                            // Brand Header with Back Button
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.15),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        padding: const EdgeInsets.only(left: 6),
                                        icon: const Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(child: AuthBrandHeader()),
                              ],
                            ),

                            SizedBox(height: taglineIntroGap),

                            // Upper Right Tagline
                            const AuthTagline(),

                            SizedBox(height: taglineIntroGap * 0.8),

                            // Signup Introduction Section ("Create Account 💜")
                            const SignupIntroSection(),

                            SizedBox(height: introFormGap),

                            // 1. Full Name Field
                            GlassAuthTextField(
                              key: const ValueKey('full_name_field'),
                              controller: _fullNameController,
                              focusNode: _fullNameFocus,
                              hintText: 'Full Name',
                              leadingIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              errorText: state.fullNameError,
                              onChanged: notifier.setFullName,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_emailFocus),
                            ),

                            const SizedBox(height: 14),

                            // 2. Email or Username Field
                            GlassAuthTextField(
                              key: const ValueKey('email_username_field'),
                              controller: _emailController,
                              focusNode: _emailFocus,
                              hintText: 'Email or username',
                              leadingIcon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.email,
                                AutofillHints.username,
                              ],
                              errorText: state.emailError,
                              onChanged: notifier.setEmail,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_phoneFocus),
                            ),

                            const SizedBox(height: 14),

                            // 3. Phone Number Field (Optional)
                            GlassAuthTextField(
                              key: const ValueKey('phone_field'),
                              controller: _phoneController,
                              focusNode: _phoneFocus,
                              hintText: 'Phone Number (optional)',
                              leadingIcon: Icons.phone_iphone_rounded,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              errorText: state.phoneError,
                              onChanged: notifier.setPhoneNumber,
                              onFieldSubmitted: (_) => FocusScope.of(
                                context,
                              ).requestFocus(_passwordFocus),
                            ),

                            const SizedBox(height: 14),

                            // 4. Password Field
                            GlassAuthTextField(
                              key: const ValueKey('signup_password_field'),
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              hintText: 'Create Password',
                              leadingIcon: Icons.lock_outline_rounded,
                              obscureText: state.isPasswordObscured,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.newPassword],
                              errorText: state.passwordError,
                              onChanged: notifier.setPassword,
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
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

                            const SizedBox(height: 14),

                            // Date of Birth Section
                            const DateOfBirthSelector(),

                            const SizedBox(height: 16),

                            // Terms Agreement Checkbox
                            TermsAgreementCheckbox(
                              onTermsTap: _handleTermsTap,
                              onPrivacyTap: _handlePrivacyTap,
                            ),

                            SizedBox(height: formCtaGap),

                            // Action CTA Button: Create Account
                            AuthPrimaryButton(
                              text: 'Create Account',
                              isLoading: state.isLoading,
                              isDisabled: state.isLoading,
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                await notifier.submit();
                              },
                            ),

                            SizedBox(height: formCtaGap * 1.2),

                            // Social Signup Divider
                            const SocialAuthDivider(),

                            // Social Signup Buttons
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

                            // Login Redirect Footer Link
                            LoginRedirect(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
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
      ),
    );
  }
}
