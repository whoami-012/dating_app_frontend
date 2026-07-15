import 'dart:ui';
import 'package:flutter/material.dart';

class ProfileStatItem {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;

  const ProfileStatItem({
    required this.icon,
    this.iconColor,
    required this.value,
    required this.label,
  });
}

class ProfileStatsCard extends StatelessWidget {
  final List<ProfileStatItem> stats;
  final double height;
  final double borderRadius;
  final double valueFontSize;

  const ProfileStatsCard({
    super.key,
    required this.stats,
    this.height = 90.0,
    this.borderRadius = 16.0,
    this.valueFontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark
        ? Colors.white.withOpacity(0.04) // 3-5% range
        : Colors.black.withOpacity(0.03); // Soft tint in light mode
    
    final borderColor = isDark
        ? Colors.white.withOpacity(0.09) // 8-10% range
        : Colors.black.withOpacity(0.06);

    final valueColor = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final labelColor = isDark ? const Color(0xFFB0B0B7) : const Color(0xFF666971);
    final dividerColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Row(
            children: List.generate(stats.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Return divider
                return Container(
                  width: 1,
                  height: 42,
                  color: dividerColor,
                );
              }

              // Return item
              final statIndex = index ~/ 2;
              final item = stats[statIndex];
              return Expanded(
                child: Semantics(
                  label: '${item.value} ${item.label}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            color: item.iconColor ?? (isDark ? Colors.white70 : Colors.black54),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.value,
                            style: TextStyle(
                              color: valueColor,
                              fontSize: valueFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
