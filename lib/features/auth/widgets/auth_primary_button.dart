import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class AuthPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool effectiveDisabled =
        widget.isDisabled || widget.isLoading || widget.onPressed == null;

    // Saturation and opacity updates based on disabled state
    final Color gradientColor1 = effectiveDisabled
        ? const Color(0xFFC8FF32).withOpacity(0.5)
        : const Color(0xFFD7FF27);
    final Color gradientColor2 = effectiveDisabled
        ? const Color(0xFFBFFF38).withOpacity(0.5)
        : const Color(0xFFBFFF38);

    return GestureDetector(
      onTapDown: effectiveDisabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: effectiveDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: effectiveDisabled
          ? null
          : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: Container(
          height: 74,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            gradient: LinearGradient(
              colors: [gradientColor1, gradientColor2],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              if (!effectiveDisabled)
                BoxShadow(
                  color: AppColors.authNeonLime.withOpacity(0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main text inside button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  style: AppTypography.getAuthCTA(
                    effectiveDisabled
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black87,
                  ),
                ),
              ),

              // Arrow circle or spinner on the right
              Positioned(
                right: 8,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: widget.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.authNeonLime,
                              strokeWidth: 2.5,
                            ),
                          )
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            transform: Matrix4.translationValues(
                              _isPressed ? 4.0 : 0.0,
                              0,
                              0,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: effectiveDisabled
                                  ? AppColors.authNeonLime.withOpacity(0.5)
                                  : AppColors.authNeonLime,
                              size: 28,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
