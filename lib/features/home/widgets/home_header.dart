import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../home/providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/screens/my_profile_screen.dart';
import '../../profile/providers/my_profile_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select App Theme',
                  style: AppTypography.getUsername(
                    isDark
                        ? AppColors.darkPrimaryText
                        : AppColors.lightPrimaryText,
                  ),
                ),
                const SizedBox(height: 16),
                _ThemeOptionTile(
                  title: 'System Default',
                  icon: Icons.brightness_auto,
                  selected: currentTheme == ThemeMode.system,
                  onTap: () {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.system);
                    Navigator.pop(context);
                  },
                ),
                _ThemeOptionTile(
                  title: 'Light Theme',
                  icon: Icons.light_mode_outlined,
                  selected: currentTheme == ThemeMode.light,
                  onTap: () {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.light);
                    Navigator.pop(context);
                  },
                ),
                _ThemeOptionTile(
                  title: 'Dark Theme',
                  icon: Icons.dark_mode_outlined,
                  selected: currentTheme == ThemeMode.dark,
                  onTap: () {
                    ref
                        .read(themeControllerProvider.notifier)
                        .setThemeMode(ThemeMode.dark);
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _LogoutOptionTile(
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authProvider.notifier).logout();
                  },
                ),
                const SizedBox(height: 12),
                // Extra options for testing empty & error states
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Demo Controls',
                  style: AppTypography.getStoryLabel(
                    isDark ? AppColors.darkMutedText : AppColors.lightMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Refresh'),
                        onPressed: () {
                          ref.read(homeProvider.notifier).refreshFeed();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.error_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Error State',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          ref.read(homeProvider.notifier).triggerErrorState();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: TextButton.icon(
                        icon: const Icon(
                          Icons.hourglass_empty,
                          size: 18,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          'Empty State',
                          style: TextStyle(color: Colors.orange),
                        ),
                        onPressed: () {
                          ref.read(homeProvider.notifier).triggerEmptyState();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;

    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.black.withOpacity(0.07);

    // Responsive parameters to prevent overflow on narrow screens
    final isNarrow = screenWidth < 440;
    final horizontalPadding = isNarrow ? 12.0 : 18.0;
    final brandLogoGap = isNarrow ? 8.0 : 10.0;
    final balanceAvatarGap = isNarrow ? 8.0 : 10.0;
    final avatarDiameter = isNarrow ? 42.0 : 48.0;
    final pillHeight = isNarrow ? 42.0 : 46.0;
    final pillHorizontalPadding = isNarrow ? 12.0 : 16.0;
    final notificationDotSize = isNarrow ? 9.0 : 11.0;

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          // Left: Brand Logo and Title
          Expanded(
            child: Row(
              children: [
                SvgPicture.string(
                  '''<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M14 26V18" stroke="#C9FF24" stroke-width="2" stroke-linecap="round"/>
                    <path d="M14 3C8.5 8 7 13.5 8 18C9.5 20.5 12 21 14 21C16 21 18.5 20.5 20 18C21 13.5 19.5 8 14 3Z" stroke="#C9FF24" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M14 18V9" stroke="#C9FF24" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M14 15C12 14 10.5 12.5 10 11" stroke="#C9FF24" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M14 12C16 11.5 17.5 10 18 8.5" stroke="#C9FF24" stroke-width="1.5" stroke-linecap="round"/>
                  </svg>''',
                  width: 28,
                  height: 28,
                  semanticsLabel: 'Social Tree Logo',
                ),
                SizedBox(width: brandLogoGap),
                Flexible(
                  child: Text(
                    'Social Tree',
                    style: AppTypography.getBrandTitle(
                      primaryColor,
                    ).copyWith(fontSize: isNarrow ? 20 : 23),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right: Gem Balance and Profile Avatar
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gem Balance Pill
              Container(
                height: pillHeight,
                padding: EdgeInsets.symmetric(
                  horizontal: pillHorizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : surfaceColor,
                  borderRadius: BorderRadius.circular(pillHeight / 2),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ShaderMask(
                      shaderCallback: _gemShader,
                      child: Icon(
                        Icons.diamond,
                        color: Colors.white,
                        size: 18,
                        semanticLabel: 'Gems',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '150',
                      style: AppTypography.getBalance(
                        primaryColor,
                      ).copyWith(fontSize: isNarrow ? 15 : 18),
                    ),
                  ],
                ),
              ),
              SizedBox(width: balanceAvatarGap),

              // Profile Avatar Button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyProfileScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: avatarDiameter,
                      height: avatarDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1.5,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            ref.watch(myProfileProvider).user?.coverImageUrl ??
                                'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Notification dot
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: notificationDotSize,
                        height: notificationDotSize,
                        decoration: BoxDecoration(
                          color: AppColors.liveOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Shader _gemShader(Rect bounds) {
    return const LinearGradient(
      colors: AppColors.gemGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.neonLime
                  : (isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.lightSecondaryText),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.getUsername(
                  selected
                      ? AppColors.neonLime
                      : (isDark
                            ? AppColors.darkPrimaryText
                            : AppColors.lightPrimaryText),
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.neonLime,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutOptionTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutOptionTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.liveRed,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Log Out',
                style: AppTypography.getUsername(AppColors.liveRed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
