import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class FloatingAppNavigation extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double height;

  const FloatingAppNavigation({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.height = 88.0,
  });

  @override
  State<FloatingAppNavigation> createState() => _FloatingAppNavigationState();
}

class _FloatingAppNavigationState extends State<FloatingAppNavigation> {
  final List<_NavItemData> _items = [
    const _NavItemData(
      label: 'Home',
      activeIcon: Icons.home,
      inactiveIcon: Icons.home_outlined,
      semanticLabel: 'Home Tab',
    ),
    const _NavItemData(
      label: 'Search',
      activeIcon: Icons.search,
      inactiveIcon: Icons.search_outlined,
      semanticLabel: 'Search Tab',
    ),
    const _NavItemData(
      label: 'Create',
      activeIcon: Icons.add_circle,
      inactiveIcon: Icons.add_circle_outline_rounded,
      semanticLabel: 'Create Post Tab',
    ),
    const _NavItemData(
      label: 'Matches',
      activeIcon: Icons.favorite,
      inactiveIcon: Icons.favorite_border_rounded,
      semanticLabel: 'Likes and Matches Tab',
    ),
    const _NavItemData(
      label: 'Broadcast',
      activeIcon: Icons.sensors,
      inactiveIcon: Icons.sensors_outlined,
      semanticLabel: 'Live Broadcast Tab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final navBg = const Color(0xFF141414).withOpacity(0.95);
    final borderColor = Colors.white.withOpacity(0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: navBg,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: borderColor, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = widget.selectedIndex == index;

              return Expanded(
                child: _NavigationItemTile(
                  item: item,
                  isSelected: isSelected,
                  isDark: isDark,
                  onTap: () => widget.onTabSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String semanticLabel;

  const _NavItemData({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.semanticLabel,
  });
}

class _NavigationItemTile extends StatelessWidget {
  final _NavItemData item;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavigationItemTile({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeIconColor = AppColors.neonLime;
    final inactiveIconColor = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Semantics(
      label: item.semanticLabel,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.inactiveIcon,
                color: isSelected ? activeIconColor : inactiveIconColor,
                size: isSelected ? 28 : 28,
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: AppTypography.getNavigationLabel(
                    Colors.white,
                  ).copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.neonLime,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
