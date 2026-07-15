import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/story.dart';
import '../models/feed_post.dart';

class HomeState {
  final List<Story> stories;
  final List<FeedPost> posts;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const HomeState({
    required this.stories,
    required this.posts,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  HomeState copyWith({
    List<Story>? stories,
    List<FeedPost>? posts,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return HomeState(
      stories: stories ?? this.stories,
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return HomeState(
        stories: _sampleStories,
        posts: _samplePosts,
        isLoading: false,
      );
    }
    // Defer the initial async data fetch to prevent state updates during the widget build cycle
    Future.microtask(() => loadInitialData());
    return const HomeState(stories: [], posts: []);
  }

  // Pre-configured high quality sample images from Unsplash
  final List<Story> _sampleStories = [
    const Story(
      id: 'self',
      username: 'Your story',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      isCurrentUser: true,
      hasUnseenStory: false,
      isOnline: false,
    ),
    const Story(
      id: 'story1',
      username: 'vianjgd',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
      hasUnseenStory: true,
      isOnline: true,
    ),
    const Story(
      id: 'story2',
      username: 'Nikeron',
      avatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200&auto=format&fit=crop',
      hasUnseenStory: true,
      isOnline: false,
    ),
    const Story(
      id: 'story3',
      username: 'Ricky kin..',
      avatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
      hasUnseenStory: true,
      isOnline: true,
    ),
    const Story(
      id: 'story4',
      username: 'Mujotha',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      hasUnseenStory: true,
      isOnline: false,
    ),
  ];

  final List<FeedPost> _samplePosts = [
    const FeedPost(
      id: 'post1',
      author: 'Nikeron',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200&auto=format&fit=crop',
      // Cinematic cyber/neon lighting portrait
      mediaUrl:
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?q=80&w=1000&auto=format&fit=crop',
      isLive: true,
      viewerCount: '29.3K',
      likeCount: 5200,
      commentCount: 387,
      shareCount: 434,
      bookmarkCount: 2100,
      caption:
          "Let's begin the photoshop war to beat some AI tools where they can't feel and stay to up...",
      isLiked: false,
      isBookmarked: false,
      mediaAlignmentX: 0.0,
      mediaAlignmentY: -0.05,
    ),
  ];

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 1200));
      state = HomeState(
        stories: _sampleStories,
        posts: _samplePosts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'Failed to load feed. Tap to retry.',
      );
    }
  }

  Future<void> refreshFeed() async {
    // Keeps previous state while loading, standard UX
    state = state.copyWith(isLoading: true, isError: false);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));
      // Reset likes and bookmarks on refresh for demonstration
      final refreshedPosts = _samplePosts
          .map((p) => p.copyWith(isLiked: false, isBookmarked: false))
          .toList();
      state = HomeState(
        stories: _sampleStories,
        posts: refreshedPosts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'Failed to refresh feed.',
      );
    }
  }

  void toggleLike(String postId) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          final isLiked = !post.isLiked;
          return post.copyWith(
            isLiked: isLiked,
            likeCount: isLiked ? post.likeCount + 1 : post.likeCount - 1,
          );
        }
        return post;
      }).toList(),
    );
  }

  void toggleBookmark(String postId) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id == postId) {
          final isBookmarked = !post.isBookmarked;
          return post.copyWith(
            isBookmarked: isBookmarked,
            bookmarkCount: isBookmarked
                ? post.bookmarkCount + 1
                : post.bookmarkCount - 1,
          );
        }
        return post;
      }).toList(),
    );
  }

  void triggerErrorState() {
    state = state.copyWith(
      isLoading: false,
      isError: true,
      errorMessage: 'Network error simulated. Tap to try again.',
    );
  }

  void triggerEmptyState() {
    state = state.copyWith(isLoading: false, isError: false, posts: []);
  }

  void addPost(FeedPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  void addStory(Story story) {
    final index = state.stories.indexWhere((s) => s.isCurrentUser);
    List<Story> updatedStories = List.from(state.stories);
    if (index >= 0) {
      updatedStories[index] = story.copyWith(isCurrentUser: true);
    } else {
      updatedStories = [story, ...updatedStories];
    }
    state = state.copyWith(stories: updatedStories);
  }
}
