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
import '../../media_upload/screens/upload_media_screen.dart';
import '../../story/screens/story_composer_screen.dart';

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

    const navigationHeight = 90.0;
    const navigationBottomGap = 12.0;
    final scrollBottomPadding =
        navigationHeight +
        MediaQuery.paddingOf(context).bottom +
        navigationBottomGap +
        24;

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
              child: RefreshIndicator(
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
                      const SliverToBoxAdapter(child: HomeHeader()),
                      const SliverToBoxAdapter(child: SizedBox(height: 10)),

                      // 2. Stories Row
                      SliverToBoxAdapter(
                        child: StoriesList(
                          stories: homeState.stories,
                          isLoading:
                              homeState.isLoading && homeState.stories.isEmpty,
                          onStoryTap: (story) {
                            if (story.isCurrentUser) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StoryComposerScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Opening ${story.username}\'s story...',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      // Check for Error State
                      if (homeState.isError)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.wifi_off_rounded,
                                    size: 64,
                                    color: AppColors.liveRed,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    homeState.errorMessage ??
                                        'An error occurred',
                                    style: AppTypography.getCaption(
                                      primaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neonLime,
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () =>
                                        homeNotifier.loadInitialData(),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.feed_outlined,
                                    size: 64,
                                    color: AppColors.gemBlue,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No updates in your circle right now.',
                                    style: AppTypography.getUsername(
                                      primaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pull down to refresh or follow more creators.',
                                    style: AppTypography.getCaption(
                                      secondaryText,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
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
                            (context, index) {
                              // Handle initial skeleton loading when posts lists are empty
                              final isSkeleton =
                                  homeState.isLoading &&
                                  homeState.posts.isEmpty;
                              final post = isSkeleton
                                  ? null
                                  : homeState.posts[index];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 3. Main Live Content Card
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 0.96,
                                      child: LivePostCard(
                                        post: post,
                                        isLoading: isSkeleton,
                                        onDoubleTap: () {
                                          if (post != null) {
                                            homeNotifier.toggleLike(post.id);
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

                                  // 4. Engagement Controls Row
                                  EngagementBar(
                                    post: post,
                                    isLoading: isSkeleton,
                                    onLikeTap: () {
                                      if (post != null)
                                        homeNotifier.toggleLike(post.id);
                                    },
                                    onBookmarkTap: () {
                                      if (post != null)
                                        homeNotifier.toggleBookmark(post.id);
                                    },
                                    onCommentTap: () {
                                      if (post != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Opening comments for ${post.author}...',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    onShareTap: () {
                                      if (post != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Sharing ${post.author}\'s broadcast...',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),

                                  // 5. Post Caption
                                  PostCaption(
                                    post: post,
                                    isLoading: isSkeleton,
                                    onTap: () {
                                      if (post != null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Navigating to detail screen for ${post.author}',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
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
              bottom: MediaQuery.paddingOf(context).bottom + 12,
              child: FloatingAppNavigation(
                selectedIndex: _currentNavIndex,
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
