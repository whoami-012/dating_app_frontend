import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/core/services/api_service.dart';
import 'package:dating_app_mobile/features/home/providers/home_provider.dart';
import 'package:dating_app_mobile/features/home/models/feed_post.dart';

class FakeApiService implements ApiService {
  final List<String> getPaths = [];
  final List<String> putPaths = [];
  final List<String> deletePaths = [];
  final List<String> postPaths = [];

  Map<String, dynamic> getResponse = {};
  Map<String, dynamic> putResponse = {};
  Map<String, dynamic> deleteResponse = {};

  bool shouldThrow = false;

  @override
  String get baseUrl => 'http://127.0.0.1:8000/api/v1';

  @override
  Future<dynamic> get(String path) async {
    getPaths.add(path);
    if (shouldThrow) throw Exception('API Error');
    return getResponse;
  }

  @override
  Future<dynamic> post(String path, dynamic body) async {
    postPaths.add(path);
    if (shouldThrow) throw Exception('API Error');
    return {};
  }

  @override
  Future<dynamic> put(String path, dynamic body) async {
    putPaths.add(path);
    if (shouldThrow) throw Exception('API Error');
    return putResponse;
  }

  @override
  Future<dynamic> delete(String path) async {
    deletePaths.add(path);
    if (shouldThrow) throw Exception('API Error');
    return deleteResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ProviderContainer container;
  late FakeApiService fakeApi;

  setUp(() {
    fakeApi = FakeApiService();
    container = ProviderContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(fakeApi),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Home Feed Integration and Business Logic Tests', () {
    test('1. loadInitialData maps backend response fields correctly', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {
              'id': 'author_123',
              'display_name': 'Alice Smith',
            },
            'media': {
              'id': 'media_789',
              'url': 'http://image.com/1.jpg',
              'content_type': 'image/jpeg',
            },
            'like_count': 150,
            'viewer_has_liked': true,
            'created_at': '2026-07-16T12:00:00Z',
          }
        ],
        'next_cursor': 'cursor_page_2',
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      final state = container.read(homeProvider);
      expect(state.posts.length, equals(1));
      final post = state.posts.first;
      expect(post.id, equals('post_abc'));
      expect(post.authorId, equals('author_123'));
      expect(post.author, equals('Alice Smith'));
      expect(post.mediaId, equals('media_789'));
      expect(post.mediaUrl, equals('http://image.com/1.jpg'));
      expect(post.contentType, equals('image/jpeg'));
      expect(post.likeCount, equals(150));
      expect(post.isLiked, isTrue);
      expect(post.createdAt, equals('2026-07-16T12:00:00Z'));
      expect(state.nextCursor, equals('cursor_page_2'));
    });

    test('2. togglePostLike updates optimistically and calls PUT/DELETE correctly', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          }
        ],
        'next_cursor': null,
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      fakeApi.putResponse = {
        'post_id': 'post_abc',
        'like_count': 11,
        'viewer_has_liked': true,
      };

      final Future<void> likeFuture = notifier.togglePostLike('post_abc');

      // Optimistic check: immediately liked, count is 11
      var currentPost = container.read(homeProvider).posts.first;
      expect(currentPost.isLiked, isTrue);
      expect(currentPost.likeCount, equals(11));

      await likeFuture;

      currentPost = container.read(homeProvider).posts.first;
      expect(currentPost.isLiked, isTrue);
      expect(currentPost.likeCount, equals(11));
      expect(fakeApi.putPaths.first, equals('/posts/post_abc/like'));

      // Now unlike
      fakeApi.deleteResponse = {
        'post_id': 'post_abc',
        'like_count': 10,
        'viewer_has_liked': false,
      };

      final Future<void> unlikeFuture = notifier.togglePostLike('post_abc');

      // Optimistic check: immediately unliked, count is 10
      currentPost = container.read(homeProvider).posts.first;
      expect(currentPost.isLiked, isFalse);
      expect(currentPost.likeCount, equals(10));

      await unlikeFuture;

      currentPost = container.read(homeProvider).posts.first;
      expect(currentPost.isLiked, isFalse);
      expect(currentPost.likeCount, equals(10));
      expect(fakeApi.deletePaths.first, equals('/posts/post_abc/like'));
    });

    test('3. Failed like request restores prior count and state', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          }
        ],
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      fakeApi.shouldThrow = true;

      try {
        await notifier.togglePostLike('post_abc');
      } catch (_) {}

      final currentPost = container.read(homeProvider).posts.first;
      expect(currentPost.isLiked, isFalse);
      expect(currentPost.likeCount, equals(10));
    });

    test('4. Duplicate togglePostLike calls are ignored when one is in flight', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          }
        ],
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      fakeApi.putResponse = {
        'post_id': 'post_abc',
        'like_count': 11,
        'viewer_has_liked': true,
      };

      final future1 = notifier.togglePostLike('post_abc');
      final future2 = notifier.togglePostLike('post_abc');

      await Future.wait([future1, future2]);

      expect(fakeApi.putPaths.length, equals(1));
    });

    test('5. loadMorePosts appends and prevents duplicates', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          }
        ],
        'next_cursor': 'cursor_2',
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          },
          {
            'id': 'post_xyz',
            'author': {'id': 'author_456', 'display_name': 'Bob'},
            'media': {'id': 'media_000', 'url': 'http://2.jpg', 'content_type': 'image/jpeg'},
            'like_count': 5,
            'viewer_has_liked': false,
          }
        ],
        'next_cursor': null,
      };

      await notifier.loadMorePosts();

      final state = container.read(homeProvider);
      expect(state.posts.length, equals(2));
      expect(state.posts[0].id, equals('post_abc'));
      expect(state.posts[1].id, equals('post_xyz'));
    });

    test('6. refreshFeed preserves old content on failure', () async {
      fakeApi.getResponse = {
        'items': [
          {
            'id': 'post_abc',
            'author': {'id': 'author_123', 'display_name': 'Alice Smith'},
            'media': {'id': 'media_789', 'url': 'http://1.jpg', 'content_type': 'image/jpeg'},
            'like_count': 10,
            'viewer_has_liked': false,
          }
        ],
      };

      final notifier = container.read(homeProvider.notifier);
      await notifier.loadInitialData();

      fakeApi.shouldThrow = true;

      await notifier.refreshFeed();

      final state = container.read(homeProvider);
      expect(state.posts.length, equals(1));
      expect(state.posts.first.id, equals('post_abc'));
      expect(state.isError, isFalse);
      expect(state.errorMessage, contains('Refresh failed'));
    });
  });
}
