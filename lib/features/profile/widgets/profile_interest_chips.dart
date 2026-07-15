import 'package:flutter/material.dart';
import '../models/profile_interest.dart';

class ProfileInterestChips extends StatelessWidget {
  final List<ProfileInterest> interests;
  final bool isOwnProfile;
  final VoidCallback? onViewAllTap;

  const ProfileInterestChips({
    super.key,
    required this.interests,
    required this.isOwnProfile,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final purpleColor = const Color(0xFFA96BFF);
    final chipBg = isDark ? const Color(0xFF18191C) : const Color(0xFFF0F1F3);
    final chipBorderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);
    final chipTextColor = isDark ? const Color(0xFFB0B0B7) : const Color(0xFF4B5563);
    final limeColor = const Color(0xFFBFFF27);

    if (interests.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isOwnProfile) {
      // Alex Profile: Single horizontally scrollable chip row, height 36-40
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(
              'Interests',
              style: TextStyle(
                color: titleColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              physics: const BouncingScrollPhysics(),
              itemCount: interests.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final interest = interests[index];
                // Alternate icon color between lime and purple
                final iconColor = index.isEven ? limeColor : purpleColor;

                return Semantics(
                  label: interest.name,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: chipBorderColor, width: 1.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          interest.icon,
                          color: iconColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          interest.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      // Arjun Profile: Wrap layout with header and top divider
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtle Divider above section
          Divider(
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08),
            thickness: 1.0,
            height: 32,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Interests',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onViewAllTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        color: purpleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: purpleColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 10.0,
            children: interests.map((interest) {
              return Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: chipBorderColor, width: 1.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      interest.icon,
                      color: limeColor, // Lime icon for Arjun
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      interest.name,
                      style: TextStyle(
                        color: chipTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      );
    }
  }
}
