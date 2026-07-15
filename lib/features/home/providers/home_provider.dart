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
  final List<FeedPost> _addedPosts = [];
  int _refreshCount = 0;

  final List<FeedPost> _dynamicSamplePosts = [
    const FeedPost(
      id: 'post_new_1',
      author: 'Ricky kin..',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200&auto=format&fit=crop',
      mediaUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1000&auto=format&fit=crop',
      isLive: false,
      viewerCount: '12.4K',
      likeCount: 1200,
      commentCount: 98,
      shareCount: 45,
      bookmarkCount: 340,
      caption:
          "Cyberpunk night vibes in downtown. The neon lights here hit different...",
      isLiked: false,
      isBookmarked: false,
    ),
    const FeedPost(
      id: 'post_new_2',
      author: 'Mujotha',
      authorAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      mediaUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1000&auto=format&fit=crop',
      isLive: false,
      viewerCount: '5.2K',
      likeCount: 430,
      commentCount: 24,
      shareCount: 12,
      bookmarkCount: 88,
      caption: "Chasing the golden hour. A perfect ending to a busy week.",
      isLiked: false,
      isBookmarked: false,
    ),
  ];

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
      _refreshCount++;
      
      final List<FeedPost> loadedPosts = List.from(_samplePosts);
      // Dynamically add a new post based on refresh count to simulate new feed updates
      if (_refreshCount == 1 && _dynamicSamplePosts.isNotEmpty) {
        loadedPosts.insert(0, _dynamicSamplePosts[0]);
      } else if (_refreshCount >= 2 && _dynamicSamplePosts.length >= 2) {
        loadedPosts.insert(0, _dynamicSamplePosts[0]);
        loadedPosts.insert(0, _dynamicSamplePosts[1]);
      }

      // Reset likes and bookmarks on refresh for demonstration
      final refreshedPosts = loadedPosts
          .map((p) => p.copyWith(isLiked: false, isBookmarked: false))
          .toList();

      // Merge user created/added posts with refreshed posts
      final allPosts = [
        ..._addedPosts,
        ...refreshedPosts.where((p) => !_addedPosts.any((ap) => ap.id == p.id))
      ];

      state = HomeState(
        stories: _sampleStories,
        posts: allPosts,
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

  void notInterested(String postId) {
    state = state.copyWith(
      posts: state.posts.where((post) => post.id != postId).toList(),
    );
  }

  void insertPostAt(int index, FeedPost post) {
    final updatedPosts = List<FeedPost>.from(state.posts);
    if (index >= 0 && index <= updatedPosts.length) {
      updatedPosts.insert(index, post);
    } else {
      updatedPosts.add(post);
    }
    state = state.copyWith(posts: updatedPosts);
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
    if (!_addedPosts.any((p) => p.id == post.id)) {
      _addedPosts.insert(0, post);
    }
    state = state.copyWith(
      posts: [post, ...state.posts.where((p) => p.id != post.id)],
    );
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
