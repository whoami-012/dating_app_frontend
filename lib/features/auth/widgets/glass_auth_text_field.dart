import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class GlassAuthTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData leadingIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final List<String>? autofillHints;
  final String? errorText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;

  const GlassAuthTextField({
    super.key,
    this.controller,
    required this.hintText,
    required this.leadingIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged,
    this.autofillHints,
    this.errorText,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<GlassAuthTextField> createState() => _GlassAuthTextFieldState();
}

class _GlassAuthTextFieldState extends State<GlassAuthTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background and border styling
    final Color backgroundColor = isDark
        ? AppColors.authSurfaceGlassDark
        : AppColors.authSurfaceGlassLight;

    Color borderColor = isDark
        ? AppColors.authBorderDark
        : AppColors.authBorderLight;

    if (widget.errorText != null) {
      borderColor = AppColors.authError;
    } else if (_isFocused) {
      borderColor = AppColors.authNeonLime.withOpacity(0.65);
    }

    final Color iconColor = isDark
        ? AppColors.authNeonLime
        : (_isFocused ? AppColors.authNeonLime : Colors.black87);

    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color hintColor = isDark
        ? AppColors.darkMutedText
        : AppColors.lightMutedText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Glass container
        ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 74,
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(34),
                border: Border.all(
                  color: borderColor,
                  width: _isFocused || widget.errorText != null ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFocused && widget.errorText == null
                        ? AppColors.authNeonLime.withOpacity(0.06)
                        : Colors.transparent,
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  onChanged: widget.onChanged,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onFieldSubmitted,
                  style: AppTypography.getAuthFieldText(textColor),
                  cursorColor: AppColors.authNeonLime,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: AppTypography.getAuthFieldText(hintColor),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 26, right: 18),
                      child: Icon(
                        widget.leadingIcon,
                        color: iconColor,
                        size: 28,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    suffixIcon: widget.suffixIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: widget.suffixIcon,
                          )
                        : null,
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 22),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Error space below field (prevent layout shifting by reserving height if error occurs)
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 6),
            child: Text(
              widget.errorText!,
              style: TextStyle(
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
