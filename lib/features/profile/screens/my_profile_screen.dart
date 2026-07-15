import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/my_profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_cover.dart';
import '../widgets/profile_top_actions.dart';
import '../widgets/profile_identity.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_action_row.dart';
import '../widgets/profile_interest_chips.dart';
import '../widgets/profile_moments_grid.dart';
import '../widgets/profile_content_panel.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  void _showMoreOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF111214) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                ListTile(
                  leading: const Icon(Icons.edit_note_rounded, color: Color(0xFFBFFF27)),
                  title: Text('Account Information', style: TextStyle(color: tileColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded, color: Color(0xFFA96BFF)),
                  title: Text('Privacy Controls', style: TextStyle(color: tileColor)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final secondaryText = isDark ? const Color(0xFFB0B0B7) : const Color(0xFF666971);

    // 1. Loading State
    if (state.isLoading) {
      return _buildSkeleton(context);
    }

    // 2. Error State
    if (state.isError || state.user == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF050506) : const Color(0xFFF5F6F8),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: primaryText),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Failed to load profile',
                  style: TextStyle(color: primaryText, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Please check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(myProfileProvider.notifier).loadProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBFFF27),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final user = state.user!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // Cover image height: Alex cover photo occupies upper 42-48%
    final coverHeight = screenHeight * 0.45;

    // 3. Content Screen
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050506) : const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          // Cover Photo (Alex: upper 42-48% height)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileCover(
              imageUrl: user.coverImageUrl,
              height: coverHeight,
            ),
          ),

          // Scrollable Profile Content
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Spacer matching cover height minus some overlap
                SliverToBoxAdapter(
                  child: SizedBox(height: coverHeight - 45),
                ),

                // Large rounded content panel
                SliverToBoxAdapter(
                  child: ProfileContentPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileIdentity(
                          name: user.displayName,
                          isVerified: user.isVerified,
                          username: user.username,
                          location: user.location,
                          bio: user.bio,
                          isOwnProfile: true,
                        ),
                        const SizedBox(height: 24),

                        // Stats Card (Alex styling: lime and purple icons, slightly larger values)
                        ProfileStatsCard(
                          stats: [
                            ProfileStatItem(
                              icon: Icons.image_outlined,
                              iconColor: const Color(0xFFBFFF27), // Lime
                              value: '${user.photosCount}',
                              label: 'Photos',
                            ),
                            ProfileStatItem(
                              icon: Icons.favorite_border_rounded,
                              iconColor: const Color(0xFFA96BFF), // Purple
                              value: '${user.matchesCount}',
                              label: 'Matches',
                            ),
                            ProfileStatItem(
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFBFFF27), // Filled Lime
                              value: '${user.likesCount}',
                              label: 'Likes',
                            ),
                          ],
                          valueFontSize: 22,
                        ),
                        const SizedBox(height: 24),

                        // Actions Row (Edit Profile, Settings, Share Profile)
                        MyProfileActionRow(
                          onEditProfileTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Edit Profile screen...')),
                            );
                          },
                          onSettingsTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Settings...')),
                            );
                          },
                          onShareProfileTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile link shared!')),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Interests Section (horizontal list view scrollable)
                        ProfileInterestChips(
                          interests: user.interests,
                          isOwnProfile: true,
                        ),
                        const SizedBox(height: 24),

                        // Moments Grid (3 columns grid view)
                        ProfileMomentsGrid(
                          moments: user.moments,
                          isOwnProfile: true,
                          onMomentTap: (moment) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Opening moment: ${moment.id}'),
                                action: SnackBarAction(
                                  label: 'Delete',
                                  textColor: Colors.redAccent,
                                  onPressed: () {
                                    ref.read(myProfileProvider.notifier).deleteMoment(moment.id);
                                  },
                                ),
                              ),
                            );
                          },
                          onViewAllTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All moments clicked')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Controls (Back, More)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileTopActions(
              onBackPressed: () => Navigator.pop(context),
              onMorePressed: () => _showMoreOptionsBottomSheet(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark ? Colors.white12 : Colors.black12;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050506) : const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.45,
              color: isDark ? const Color(0xFF111214) : const Color(0xFFE5E5E5),
            ),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.41),
                    // Profile content panel skeleton
                    Container(
                      width: double.infinity,
                      height: 400,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF111214) : Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 36,
                            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8)),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 100,
                            height: 18,
                            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 90,
                            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileTopActions(
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
