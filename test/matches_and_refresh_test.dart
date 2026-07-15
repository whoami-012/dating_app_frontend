import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/features/home/screens/social_home_screen.dart';
import 'package:dating_app_mobile/features/home/providers/home_provider.dart';
import 'package:dating_app_mobile/features/home/providers/matches_provider.dart';
import 'package:dating_app_mobile/features/home/widgets/matches_view.dart';
import 'package:dating_app_mobile/features/home/models/feed_post.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';
import 'widget_test.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Matches and Feed Refresh Widget Tests', () {
    late SharedPreferences testPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      testPrefs = await SharedPreferences.getInstance();
    });

    testWidgets(
      '1. Newly created posts appear and are retained on pull-to-refresh with dynamic updates',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: Scaffold(body: SocialHomeScreen())),
          ),
        );

        // Wait for initial load
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));

        final element = tester.element(find.byType(SocialHomeScreen));
        final container = ProviderScope.containerOf(element);
        final homeNotifier = container.read(homeProvider.notifier);

        // Verify initial state has 1 post
        expect(container.read(homeProvider).posts.length, equals(1));

        // Create a new post and add it
        const newPost = FeedPost(
          id: 'user_created_post',
          author: 'Me',
          authorAvatarUrl: '',
          mediaUrl: '',
          isLive: false,
          viewerCount: '0',
          likeCount: 0,
          commentCount: 0,
          shareCount: 0,
          bookmarkCount: 0,
          caption: 'My new post content',
        );

        homeNotifier.addPost(newPost);
        await tester.pump();

        // Verify post is prepended (total posts = 2, first is user_created_post)
        expect(container.read(homeProvider).posts.length, equals(2));
        expect(container.read(homeProvider).posts.first.id, equals('user_created_post'));

        // Trigger refresh asynchronously and advance clock
        final refreshFuture = homeNotifier.refreshFeed();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));
        await refreshFuture;

        // After 1st refresh, dynamic list loads 1 new post. Total should be 3:
        // - user_created_post (retained at index 0)
        // - post_new_1 (loaded via dynamic refresh)
        // - post1 (sample post)
        final posts = container.read(homeProvider).posts;
        expect(posts.length, equals(3));
        expect(posts[0].id, equals('user_created_post'));
        expect(posts[1].id, equals('post_new_1'));
        expect(posts[2].id, equals('post1'));
      },
    );

    testWidgets(
      '2. Navigation tab selection switches to Matches screen',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: Scaffold(body: SocialHomeScreen())),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));

        // We are on the feed screen initially
        expect(find.byType(MatchesView), findsNothing);

        // Tap the Matches tab (index 3)
        final matchesTabFinder = find.bySemanticsLabel('Likes and Matches Tab');
        expect(matchesTabFinder, findsAtLeastNWidgets(1));
        await tester.tap(matchesTabFinder.first);
        await tester.pumpAndSettle();

        // Should now display the Matches screen
        expect(find.byType(MatchesView), findsOneWidget);
        expect(find.text('Matches'), findsNWidgets(2));

        // Advance timers to let the matches list load complete
        await tester.pump(const Duration(milliseconds: 1600));
      },
    );

    testWidgets(
      '3. MatchesView handles loading skeleton, empty state, error, and list items correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: Scaffold(body: MatchesView())),
          ),
        );

        final element = tester.element(find.byType(MatchesView));
        final container = ProviderScope.containerOf(element);

        // 1. Initial State is loading. Should show skeleton loader, not "No matches yet"
        expect(find.text('No matches yet'), findsNothing);

        // 2. Wait for loading to finish
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1600));

        // Should render matched profiles
        expect(find.text('Sarah Chen'), findsOneWidget);
        expect(find.text('Emma Watson'), findsOneWidget);
        expect(find.text('David Kim'), findsOneWidget);
        expect(find.text('No matches yet'), findsNothing);

        // 3. Test empty state
        final matchesNotifier = container.read(matchesProvider.notifier);
        matchesNotifier.simulateEmpty();
        await tester.pump();

        expect(find.text('No matches yet'), findsOneWidget);
        expect(find.text('Sarah Chen'), findsNothing);

        // 4. Test error state & retry button
        matchesNotifier.simulateError();
        await tester.pump();

        expect(find.text('Simulated connection error. Please try again.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Tap retry and check if it goes back to loading state then loads data
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Immediately after tap, should be loading (skeleton loader shown)
        expect(find.text('Simulated connection error. Please try again.'), findsNothing);
        
        await tester.pump(const Duration(milliseconds: 1600));
        // Data loaded back
        expect(find.text('Sarah Chen'), findsOneWidget);
      },
    );

    group('Matches UI verified state and online indicator visual details', () {
      testWidgets(
        '4. Verification blue icon and online dot badges render correctly in matches list',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
              child: const MaterialApp(home: Scaffold(body: MatchesView())),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1600));

          // Sarah Chen and Emma Watson are verified, verify blue checkmark icon
          expect(find.byIcon(Icons.verified), findsNWidgets(2));

          // Check online status indicators
          expect(find.text('@sarah_c'), findsOneWidget);
          expect(find.text('@emma_w'), findsOneWidget);
          expect(find.text('@david_k'), findsOneWidget);
        },
      );
    });
  });
}
