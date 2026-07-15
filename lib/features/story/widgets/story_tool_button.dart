import 'package:flutter/material.dart';

class StoryToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const StoryToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFD1FF2F);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: label,
      button: true,
      selected: isActive,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFF18191D)
                  : Colors.black.withOpacity(0.55),
              border: Border.all(
                color: isActive
                    ? activeColor
                    : Colors.white.withOpacity(0.12),
                width: isActive ? 2.0 : 1.0,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.25),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isActive ? activeColor : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
