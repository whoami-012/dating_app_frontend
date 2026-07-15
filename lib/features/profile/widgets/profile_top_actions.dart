import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileTopActions extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMorePressed;

  const ProfileTopActions({
    super.key,
    this.onBackPressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildCircularButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBackPressed,
              semanticLabel: 'Back',
            ),
            // More Options Button
            _buildCircularButton(
              icon: Icons.more_horiz_rounded,
              onTap: onMorePressed,
              semanticLabel: 'More options',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.43), // 38-48% range (43% average)
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.10), // 8-12% range (10% average)
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
