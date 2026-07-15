import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/viewed_profile_provider.dart';
import '../providers/profile_state.dart';
import '../widgets/profile_cover.dart';
import '../widgets/profile_top_actions.dart';
import '../widgets/profile_identity.dart';
import '../widgets/profile_stats_card.dart';
import '../widgets/profile_action_row.dart';
import '../widgets/profile_interest_chips.dart';
import '../widgets/profile_moments_grid.dart';

class OtherUserProfileScreen extends ConsumerWidget {
  const OtherUserProfileScreen({super.key});

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
                  leading: const Icon(Icons.share_rounded, color: Color(0xFFA96BFF)),
                  title: Text('Share Profile', style: TextStyle(color: tileColor)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile link copied to clipboard')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
                  title: Text('Report User', style: TextStyle(color: tileColor)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted successfully')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                  title: Text('Block User', style: TextStyle(color: tileColor)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(viewedProfileProvider.notifier).blockUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User blocked')),
                    );
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
    final state = ref.watch(viewedProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? const Color(0xFFF5F5F6) : const Color(0xFF111216);
    final secondaryText = isDark ? const Color(0xFFB0B0B7) : const Color(0xFF666971);

    // 1. Loading State
    if (state.isLoading) {
      return _buildSkeleton(context);
    }

    // 2. Blocked State
    if (state.isBlocked) {
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
                const Icon(Icons.block_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 16),
                Text(
                  'User Blocked',
                  style: TextStyle(color: primaryText, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have blocked this profile. Unblock to view their updates.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText, fontSize: 15),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.read(viewedProfileProvider.notifier).unblockUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBFFF27),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Unblock Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Error State
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
                  onPressed: () => ref.read(viewedProfileProvider.notifier).loadProfile('arjun_28'),
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
    final coverHeight = screenHeight * 0.58;

    // 4. Content Screen
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050506) : const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          // Cover Photo (stays at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileCover(
              imageUrl: user.coverImageUrl,
              height: coverHeight,
            ),
          ),

          // Scrollable Profile Info
          Positioned.fill(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Spacer matching cover height minus some overlap so name is over the image bottom gradient
                SliverToBoxAdapter(
                  child: SizedBox(height: coverHeight - 110),
                ),

                // Main Content transitioning into page background color
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 18.0,
                      right: 18.0,
                      top: 0.0,
                      bottom: 80.0,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF050506) : const Color(0xFFF5F6F8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileIdentity(
                          name: user.displayName,
                          isVerified: user.isVerified,
                          age: user.age,
                          location: user.location,
                          bio: user.bio,
                          isOwnProfile: false,
                        ),
                        const SizedBox(height: 24),

                        // Stats Card
                        ProfileStatsCard(
                          stats: [
                            ProfileStatItem(
                              icon: Icons.image_outlined,
                              value: '${user.photosCount}',
                              label: 'Photos',
                            ),
                            ProfileStatItem(
                              icon: Icons.favorite_border_rounded,
                              value: '${user.admirersCount}',
                              label: 'Admirers',
                            ),
                            ProfileStatItem(
                              icon: Icons.star_border_rounded,
                              value: '${user.interests.length}',
                              label: 'Interests',
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons Row
                        OtherUserActionRow(
                          connectionState: user.connectionState,
                          isLiked: user.isLiked,
                          onConnectTap: () => ref.read(viewedProfileProvider.notifier).connect(),
                          onMessageTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Message sent to ${user.displayName}!'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onLikeTap: () => ref.read(viewedProfileProvider.notifier).toggleLike(),
                        ),
                        const SizedBox(height: 24),

                        // Interests Section
                        ProfileInterestChips(
                          interests: user.interests,
                          isOwnProfile: false,
                          onViewAllTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Interests clicked')),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Moments Grid
                        ProfileMomentsGrid(
                          moments: user.moments,
                          isOwnProfile: false,
                          onMomentTap: (moment) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Opening moment detail...')),
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
          // Cover placeholder
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.58,
              color: isDark ? const Color(0xFF111214) : const Color(0xFFE5E5E5),
            ),
          ),
          // Skeleton Content
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.52),
                    // Name skeleton
                    Container(
                      width: 160,
                      height: 36,
                      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    // Age & Location skeleton
                    Container(
                      width: 220,
                      height: 18,
                      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 20),
                    // Bio skeleton
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 24),
                    // Stats card skeleton
                    Container(
                      width: double.infinity,
                      height: 90,
                      decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(16)),
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
