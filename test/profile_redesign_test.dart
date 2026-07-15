import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/features/profile/screens/my_profile_screen.dart';
import 'package:dating_app_mobile/features/profile/screens/other_user_profile_screen.dart';
import 'package:dating_app_mobile/features/profile/widgets/profile_cover.dart';
import 'package:dating_app_mobile/features/profile/widgets/profile_stats_card.dart';
import 'package:dating_app_mobile/features/profile/widgets/profile_action_row.dart';
import 'package:dating_app_mobile/features/profile/widgets/profile_interest_chips.dart';
import 'package:dating_app_mobile/features/profile/widgets/profile_moments_grid.dart';
import 'package:dating_app_mobile/features/profile/providers/my_profile_provider.dart';
import 'package:dating_app_mobile/features/profile/providers/viewed_profile_provider.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';

import 'widget_test.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Profile Redesign Widget Tests', () {
    late SharedPreferences testPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      testPrefs = await SharedPreferences.getInstance();
    });

    testWidgets(
      '1. MyProfileScreen (Alex) displays cover, stats card, action buttons, interests scroll, and 3-column moments grid',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: MyProfileScreen()),
          ),
        );

        // Initially loading skeleton state (Alex is not rendered yet)
        expect(find.text('Alex'), findsNothing);

        // Wait for profile provider to load (1000ms delay in mock provider)
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1200));

        // Profile identity name and username
        expect(find.text('Alex'), findsOneWidget);
        expect(find.text('@alex.miles'), findsOneWidget);
        expect(find.text('San Diego, California'), findsOneWidget);

        // Cover photo image
        expect(find.byType(ProfileCover), findsOneWidget);

        // Stats card and correct values
        expect(find.byType(ProfileStatsCard), findsOneWidget);
        expect(find.text('6'), findsAtLeastNWidgets(1)); // Photos count
        expect(find.text('32'), findsOneWidget); // Matches count
        expect(find.text('128'), findsOneWidget); // Likes count

        // Actions Row buttons
        expect(find.text('Edit Profile'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Share Profile'), findsOneWidget);

        // Interests chips section
        expect(find.byType(ProfileInterestChips), findsOneWidget);
        expect(find.text('Hiking'), findsOneWidget);
        expect(find.text('Coffee'), findsOneWidget);

        // Moments grid section
        expect(find.byType(ProfileMomentsGrid), findsOneWidget);
      },
    );

    testWidgets(
      '2. OtherUserProfileScreen (Arjun) displays cover, stats card, Connect/Message/Like action row, and handles interactions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: OtherUserProfileScreen()),
          ),
        );

        // Wait for provider to load
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1200));

        // Name and age/location
        expect(find.text('Arjun'), findsOneWidget);
        expect(find.text('28'), findsOneWidget);
        expect(find.text('San Francisco, CA'), findsOneWidget);

        // Verify stats card values
        expect(find.text('6'), findsAtLeastNWidgets(1)); // Photos
        expect(find.text('143'), findsOneWidget); // Admirers
        expect(find.text('Interests'), findsNWidgets(2)); // Header and stat item

        // Verify action row elements
        expect(find.byType(OtherUserActionRow), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);
        expect(find.text('Message'), findsOneWidget);

        // Test Connect Button action sequence: Connect -> Loading -> Requested
        final connectBtn = find.text('Connect');
        await tester.tap(connectBtn);
        // Triggers connectionState loading
        await tester.pump();
        // Wait for connection duration (600ms delay in viewed_profile_provider)
        await tester.pump(const Duration(milliseconds: 700));
        await tester.pump();

        // Button should switch state to "Requested"
        expect(find.text('Requested'), findsOneWidget);

        // Test Like Button action
        final likeBtn = find.bySemanticsLabel('Like profile');
        expect(likeBtn, findsOneWidget);
        await tester.tap(likeBtn);
        await tester.pump();

        // Semantic label changes to "Unlike profile"
        expect(find.bySemanticsLabel('Unlike profile'), findsOneWidget);
      },
    );

    testWidgets(
      '3. Mobile viewport safety tests for narrow devices (320px width)',
      (WidgetTester tester) async {
        // Set physical size to 320x568 (iPhone SE / narrow android size)
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(
              home: Scaffold(body: OtherUserProfileScreen()),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1200));

        // Verify we render the complete layout
        expect(find.text('Arjun'), findsOneWidget);
        expect(find.byType(OtherUserActionRow), findsOneWidget);

        // Ensure there are no render overflows or clip errors by checking widgets
        expect(tester.takeException(), isNull);

        // Reset viewport settings
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
   group('Profile Special States Tests', () {
      late SharedPreferences testPrefs;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        testPrefs = await SharedPreferences.getInstance();
      });

      testWidgets(
        '4. OtherUserProfileScreen handles blocked state UI with unblock action',
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
              child: const MaterialApp(home: OtherUserProfileScreen()),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1200));

          // Initially Arjun loaded, let's trigger block from provider
          final container = ProviderScope.containerOf(tester.element(find.byType(OtherUserProfileScreen)));
          container.read(viewedProfileProvider.notifier).blockUser();
          await tester.pump();

          // Blocked screen elements should be visible
          expect(find.text('User Blocked'), findsOneWidget);
          expect(find.text('Unblock Profile'), findsOneWidget);

          // Click unblock profile
          await tester.tap(find.text('Unblock Profile'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1200));

          // Arjun should load again
          expect(find.text('Arjun'), findsOneWidget);
        },
      );
    });
  });
}
