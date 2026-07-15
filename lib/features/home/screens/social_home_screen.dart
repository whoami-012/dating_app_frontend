import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/home_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/stories_list.dart';
import '../widgets/live_post_card.dart';
import '../widgets/engagement_bar.dart';
import '../widgets/post_caption.dart';
import '../widgets/floating_app_navigation.dart';
import '../widgets/matches_view.dart';
import '../../media_upload/screens/upload_media_screen.dart';
import '../../story/screens/story_composer_screen.dart';
import '../../profile/screens/other_user_profile_screen.dart';

class SocialHomeScreen extends ConsumerStatefulWidget {
  const SocialHomeScreen({super.key});

  @override
  ConsumerState<SocialHomeScreen> createState() => _SocialHomeScreenState();
}

class _SocialHomeScreenState extends ConsumerState<SocialHomeScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final mediaQuery = MediaQuery.of(context);
    final isShort = screenHeight < 820;
    final headerToMediaGap = isShort ? 16.0 : 24.0;

    const navigationHeight = 88.0;
    const navigationBottomGap = 12.0;
    const minimumActionNavGap = 16.0;

    final navTop =
        mediaQuery.size.height -
        mediaQuery.padding.bottom -
        navigationBottomGap -
        navigationHeight;

    final scrollBottomPadding =
        navigationHeight + mediaQuery.padding.bottom + navigationBottomGap + 24;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Scrollable Feed Content
            Positioned.fill(
              child: _currentNavIndex == 3
                  ? const MatchesView()
                  : RefreshIndicator(
                      color: AppColors.neonLime,
                backgroundColor: isDark
                    ? AppColors.darkSurface
                    : AppColors.lightSurface,
                onRefresh: () => homeNotifier.refreshFeed(),
                child: SafeArea(
                  bottom: false,
                  child: CustomScrollView(
                    clipBehavior: Clip.hardEdge,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // 1. Header
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: HomeHeader(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(height: headerToMediaGap),
                      ),

                      // Check for Error State
                      if (homeState.isError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: isDark
                                        ? AppColors.darkMutedText
                                        : AppColors.lightMutedText,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    homeState.errorMessage ??
                                        'Something went wrong',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.getCaption(
                                      secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => homeNotifier.refreshFeed(),
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      // Check for Empty State
                      else if (!homeState.isLoading && homeState.posts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.feed_outlined,
                                    color: isDark
                                        ? AppColors.darkMutedText
                                        : AppColors.lightMutedText,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No posts found.',
                                    style: AppTypography.getUsername(
                                      primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pull down to refresh or reset details.',
                                    textAlign: TextAlign.center,
                                    style: AppTypography.getCaption(
                                      secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () =>
                                        homeNotifier.loadInitialData(),
                                    child: const Text(
                                      'Reset Demo Data',
                                      style: TextStyle(
                                        color: AppColors.neonLime,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      // Render Posts List
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (itemContext, index) {
                              // Handle initial skeleton loading when posts lists are empty
                              final isSkeleton =
                                  homeState.isLoading &&
                                  homeState.posts.isEmpty;
                              final post = isSkeleton
                                  ? null
                                  : homeState.posts[index];

                              final mediaToCreatorGap = isShort ? 14.0 : 18.0;
                              final creatorToCaptionGap = isShort ? 8.0 : 12.0;
                              final captionToActionsGap = isShort ? 16.0 : 24.0;

                              final mediaAspectRatio = switch (screenHeight) {
                                < 760 => 1.02,
                                < 820 => 0.96,
                                < 880 => 0.92,
                                _ => 0.86,
                              };

                              final contentStartY =
                                  mediaQuery.padding.top +
                                  12.0 +
                                  48.0 +
                                  headerToMediaGap;
                              const creatorSectionHeight = 46.0;
                              const captionSectionHeight = 36.0;
                              const actionSectionHeight = 56.0;
                              final reservedSpacing =
                                  mediaToCreatorGap +
                                  creatorToCaptionGap +
                                  captionToActionsGap +
                                  minimumActionNavGap;

                              return LayoutBuilder(
                                builder: (layoutContext, constraints) {
                                  final mediaWidth =
                                      constraints.maxWidth - 36.0;
                                  final ratioHeight =
                                      mediaWidth / mediaAspectRatio;

                                  final availableMediaHeight =
                                      navTop -
                                      contentStartY -
                                      creatorSectionHeight -
                                      captionSectionHeight -
                                      actionSectionHeight -
                                      reservedSpacing;

                                  final mediaHeight = min(
                                    ratioHeight,
                                    availableMediaHeight,
                                  );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 3. Main Media Content Card
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                        ),
                                        child: SizedBox(
                                          width: mediaWidth,
                                          height: mediaHeight,
                                          child: LivePostCard(
                                            post: post,
                                            isLoading: isSkeleton,
                                            onDoubleTap: () {
                                              if (post != null) {
                                                homeNotifier.toggleLike(
                                                  post.id,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      post.isLiked
                                                          ? 'Unliked post'
                                                          : 'Liked post!',
                                                    ),
                                                    duration: const Duration(
                                                      milliseconds: 700,
                                                    ),
                                                    backgroundColor:
                                                        AppColors.liveRed,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),

                                      // 4. Creator Row & Caption
                                      PostCaption(
                                        post: post,
                                        isLoading: isSkeleton,
                                        padding: EdgeInsets.only(
                                          left: 18.0,
                                          right: 18.0,
                                          top: mediaToCreatorGap,
                                          bottom: 0.0,
                                        ),
                                        creatorToCaptionGap:
                                            creatorToCaptionGap,
                                        onTap: () {
                                          if (post != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const OtherUserProfileScreen(),
                                              ),
                                            );
                                          }
                                        },
                                      ),

                                      // 5. Action Row (Like / Not Interested)
                                      EngagementBar(
                                        post: post,
                                        isLoading: isSkeleton,
                                        padding: EdgeInsets.only(
                                          left: 14.0,
                                          right: 14.0,
                                          top: captionToActionsGap,
                                          bottom: 0.0,
                                        ),
                                        onLikeTap: () {
                                          if (post != null) {
                                            homeNotifier.toggleLike(post.id);
                                          }
                                        },
                                        onNotInterestedTap: () {
                                          if (post != null) {
                                            final currentPosts =
                                                homeState.posts;
                                            final idx = currentPosts.indexOf(
                                              post,
                                            );
                                            homeNotifier.notInterested(post.id);

                                            ScaffoldMessenger.of(
                                              context,
                                            ).clearSnackBars();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Post hidden',
                                                ),
                                                backgroundColor:
                                                    AppColors.darkSurface,
                                                duration: const Duration(
                                                  seconds: 4,
                                                ),
                                                action: SnackBarAction(
                                                  label: 'Undo',
                                                  textColor: AppColors.neonLime,
                                                  onPressed: () {
                                                    homeNotifier.insertPostAt(
                                                      idx,
                                                      post,
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),

                                      const SizedBox(height: 24),
                                    ],
                                  );
                                },
                              );
                            },
                            childCount:
                                homeState.isLoading && homeState.posts.isEmpty
                                ? 1
                                : homeState.posts.length,
                          ),
                        ),

                      // Bottom Spacer to prevent floating nav overlap
                      SliverToBoxAdapter(
                        child: SizedBox(height: scrollBottomPadding),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 6. Floating Navigation Bar Overlay
            Positioned(
              left: 18,
              right: 18,
              bottom: mediaQuery.padding.bottom + navigationBottomGap,
              child: FloatingAppNavigation(
                selectedIndex: _currentNavIndex,
                height: navigationHeight,
                onTabSelected: (index) {
                  if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UploadMediaScreen(),
                      ),
                    );
                  } else {
                    setState(() {
                      _currentNavIndex = index;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
