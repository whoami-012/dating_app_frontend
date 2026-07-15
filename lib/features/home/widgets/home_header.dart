import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_controller.dart';
import '../../home/providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';

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

    final primaryColor = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Brand Logo and Title
          Row(
            children: [
              SvgPicture.string(
                '''<svg viewBox="0 0 28 28" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M14 26V18" stroke="#D4FF00" stroke-width="2" stroke-linecap="round"/>
                  <path d="M14 3C8.5 8 7 13.5 8 18C9.5 20.5 12 21 14 21C16 21 18.5 20.5 20 18C21 13.5 19.5 8 14 3Z" stroke="#D4FF00" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M14 18V9" stroke="#D4FF00" stroke-width="1.5" stroke-linecap="round"/>
                  <path d="M14 15C12 14 10.5 12.5 10 11" stroke="#D4FF00" stroke-width="1.5" stroke-linecap="round"/>
                  <path d="M14 12C16 11.5 17.5 10 18 8.5" stroke="#D4FF00" stroke-width="1.5" stroke-linecap="round"/>
                </svg>''',
                width: 28,
                height: 28,
                semanticsLabel: 'Social Tree Logo',
              ),
              const SizedBox(width: 10),
              Text(
                'Social Tree',
                style: AppTypography.getBrandTitle(primaryColor),
              ),
            ],
          ),

          // Right: Gem Balance and Profile Avatar
          Row(
            children: [
              Row(
                children: [
                  // Gem Balance Pill
                  Container(
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(23),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const ShaderMask(
                          shaderCallback: _gemShader,
                          child: Icon(
                            Icons.diamond,
                            color: Colors.white,
                            size: 20,
                            semanticLabel: 'Gems',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '150',
                          style: AppTypography.getBalance(primaryColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Profile Avatar Button
                  GestureDetector(
                    onTap: () => _showThemeSelector(context, ref),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? Colors.white10 : Colors.black12,
                              width: 1.5,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
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
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.liveOrange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 2.0,
                              ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
