import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';

enum SocialProvider { google, apple, facebook }

class SocialAuthButton extends StatefulWidget {
  final SocialProvider provider;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;

  const SocialAuthButton({
    super.key,
    required this.provider,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  bool _isPressed = false;

  // Inline SVG strings for guaranteed cross-platform rendering without missing asset files
  static const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#EA4335" d="M12 5.04c1.66 0 3.2.57 4.38 1.69l3.27-3.27C17.68 1.54 14.98 1 12 1 7.35 1 3.37 3.67 1.39 7.56l3.85 2.99c.92-2.76 3.51-4.51 6.76-4.51z"/>
  <path fill="#4285F4" d="M23.49 12.27c0-.81-.07-1.59-.2-2.36H12v4.51h6.46c-.29 1.48-1.14 2.73-2.4 3.58l3.73 2.89c2.18-2.01 3.7-4.99 3.7-8.62z"/>
  <path fill="#FBBC05" d="M5.24 10.55c-.24-.72-.37-1.49-.37-2.3c0-.8.13-1.57.37-2.3L1.39 2.96C.5 4.77 0 6.82 0 8.98c0 2.16.5 4.2 1.39 6.01l3.85-2.99c-.24-.72-.37-1.49-.37-2.3l.01-.15z"/>
  <path fill="#34A853" d="M12 23c3.24 0 5.97-1.07 7.96-2.91l-3.73-2.89c-1.1.74-2.5 1.18-4.23 1.18-3.25 0-5.84-1.75-6.76-4.51L1.39 14.99C3.37 18.88 7.35 23 12 23z"/>
</svg>
''';

  static const String _appleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="currentColor" d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.81-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M15.97 4.17c.66-.81 1.11-1.93.99-3.06-1 .04-2.22.67-2.94 1.51-.64.74-1.2 1.88-1.05 2.99 1.11.09 2.24-.55 3-1.44z"/>
</svg>
''';

  static const String _facebookSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#1877F2" d="M24 12.07C24 5.41 18.63 0 12 0S0 5.41 0 12.07c0 6.03 4.39 11.02 10.12 11.93v-8.44H7.08v-3.49h3.04V9.41c0-3.01 1.79-4.67 4.52-4.67 1.31 0 2.68.23 2.68.23v2.95h-1.5c-1.49 0-1.96.93-1.96 1.88v2.26h3.32l-.53 3.49h-2.79v8.44C19.61 23.09 24 18.1 24 12.07z"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = isDark
        ? AppColors.authSurfaceGlassDark
        : AppColors.authSurfaceGlassLight;

    final Color borderColor = isDark
        ? AppColors.authBorderDark
        : AppColors.authBorderLight;

    final Color appleColor = isDark ? Colors.white : Colors.black87;

    Widget iconWidget;
    String semanticLabel;

    switch (widget.provider) {
      case SocialProvider.google:
        iconWidget = SvgPicture.string(_googleSvg, width: 32, height: 32);
        semanticLabel = 'Sign in with Google';
        break;
      case SocialProvider.apple:
        iconWidget = SvgPicture.string(
          _appleSvg,
          width: 32,
          height: 32,
          colorFilter: ColorFilter.mode(appleColor, BlendMode.srcIn),
        );
        semanticLabel = 'Sign in with Apple';
        break;
      case SocialProvider.facebook:
        iconWidget = SvgPicture.string(_facebookSvg, width: 32, height: 32);
        semanticLabel = 'Sign in with Facebook';
        break;
    }

    final bool effectiveDisabled = widget.isDisabled || widget.isLoading;

    return Semantics(
      button: true,
      enabled: !effectiveDisabled,
      label: semanticLabel,
      child: GestureDetector(
        onTapDown: effectiveDisabled
            ? null
            : (_) => setState(() => _isPressed = true),
        onTapUp: effectiveDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                widget.onTap?.call();
              },
        onTapCancel: effectiveDisabled
            ? null
            : () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeInOut,
          child: Opacity(
            opacity: effectiveDisabled ? 0.5 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.authNeonLime,
                              strokeWidth: 2.0,
                            ),
                          )
                        : iconWidget,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
