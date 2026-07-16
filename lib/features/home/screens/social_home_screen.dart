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
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(homeProvider.notifier).loadMorePosts();
    }
  }

  void _showMatchDialog(String displayName, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.neonLime.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonLime.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "IT'S A MATCH!",
                  style: TextStyle(
                    color: AppColors.neonLime,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  "You and $displayName liked each other.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    "Keep Swiping",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
                    controller: _scrollController,
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
                                            onDoubleTap: () async {
                                              if (post != null) {
                                                try {
                                                  await homeNotifier.togglePostLike(post.id);
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Failed to like: $e'),
                                                        backgroundColor: Colors.redAccent,
                                                      ),
                                                    );
                                                  }
                                                }
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
                                        onLikeTap: () async {
                                          if (post != null) {
                                            try {
                                              await homeNotifier.togglePostLike(post.id);
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to like: $e'),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        },
                                        onNotInterestedTap: () async {
                                          if (post != null) {
                                            try {
                                              await homeNotifier.notInterested(post.id);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).clearSnackBars();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Profile passed'),
                                                    backgroundColor: AppColors.darkSurface,
                                                    duration: Duration(seconds: 2),
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Failed to pass: $e'),
                                                    backgroundColor: Colors.redAccent,
                                                  ),
                                                );
                                              }
                                            }
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

                      if (homeState.isPageLoading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.neonLime,
                              ),
                            ),
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

            // Floating Custom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingAppNavigation(
                selectedIndex: _currentNavIndex,
                onTabSelected: (index) {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoryComposerScreen(),
                      ),
                    );
                  } else if (index == 2) {
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
