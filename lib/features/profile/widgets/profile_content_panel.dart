import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileContentPanel extends StatelessWidget {
  final Widget child;
  final double topRadius;
  final double horizontalMargin;
  final double horizontalPadding;
  final double topPadding;

  const ProfileContentPanel({
    super.key,
    required this.child,
    this.topRadius = 20.0,
    this.horizontalMargin = 16.0,
    this.horizontalPadding = 20.0,
    this.topPadding = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final panelBg = isDark
        ? const Color(0xFF111214).withOpacity(0.92) // Near-black 88-95% opacity
        : Colors.white.withOpacity(0.96);

    final borderTop = isDark
        ? Colors.white.withOpacity(0.07) // 6-8% opacity
        : Colors.black.withOpacity(0.06);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topRadius),
          topRight: Radius.circular(topRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // 18-24 backdrop blur
          child: Container(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: topPadding,
              bottom: 40, // Spacing for scrolling content
            ),
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topRadius),
                topRight: Radius.circular(topRadius),
              ),
              border: Border.all(
                color: borderTop,
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
