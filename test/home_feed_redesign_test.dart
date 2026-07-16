import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/features/home/screens/social_home_screen.dart';
import 'package:dating_app_mobile/features/home/widgets/home_header.dart';
import 'package:dating_app_mobile/features/home/widgets/engagement_bar.dart';
import 'package:dating_app_mobile/features/home/widgets/post_caption.dart';
import 'package:dating_app_mobile/features/home/widgets/live_post_card.dart';
import 'package:dating_app_mobile/features/home/widgets/floating_app_navigation.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';

import 'widget_test.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Home Feed Redesign Widget Tests', () {
    late SharedPreferences testPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      testPrefs = await SharedPreferences.getInstance();
    });

    testWidgets(
      '1. Home feed displays header, media card, creator info, and only two actions',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: SocialHomeScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));

        // Header is rendered
        expect(find.byType(HomeHeader), findsOneWidget);

        // Large media card is rendered
        expect(find.byType(LivePostCard), findsAtLeastNWidgets(1));

        // Creator info & caption is rendered
        expect(find.byType(PostCaption), findsAtLeastNWidgets(1));

        // EngagementBar (the action row) is rendered
        expect(find.byType(EngagementBar), findsAtLeastNWidgets(1));

        // Stories are NOT rendered on this screen anymore
        expect(find.text('Stories'), findsNothing);

        // Verify actions (only Like action is shown on public post feed)
        expect(find.byType(LikeActionButton), findsAtLeastNWidgets(1));
        expect(find.byType(NotInterestedButton), findsNothing);
      },
    );

    testWidgets(
      '2. "Not interested" button is not displayed on public post cards',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
            child: const MaterialApp(home: Scaffold(body: SocialHomeScreen())),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));

        // Verify we have a post initially
        expect(find.byType(LivePostCard), findsAtLeastNWidgets(1));

        // Find the "Not interested" button and confirm it does not exist
        final notInterestedFinder = find.byType(NotInterestedButton);
        expect(notInterestedFinder, findsNothing);
      },
    );

    testWidgets(
      '3. Action row remains at least 16px above bottom nav at 360x800, 390x844, and 430x932',
      (WidgetTester tester) async {
        final sizes = [
          const Size(360, 800),
          const Size(390, 844),
          const Size(430, 932),
        ];

        for (final size in sizes) {
          // Set physical size (devicePixelRatio = 1.0)
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(testPrefs),
              ],
              child: const MaterialApp(
                home: Scaffold(body: SocialHomeScreen()),
              ),
            ),
          );

          await tester.pump();
          await tester.pump(const Duration(milliseconds: 1500));

          // Find PostActionRow / EngagementBar and FloatingAppNavigation
          final actionRowFinder = find.byType(EngagementBar).first;
          final navFinder = find.byType(FloatingAppNavigation);

          expect(actionRowFinder, findsOneWidget);
          expect(navFinder, findsOneWidget);

          // Get the rects
          final actionRowRect = tester.getRect(actionRowFinder);
          final navRect = tester.getRect(navFinder);

          // Print metrics as required
          debugPrint(
            'At ${size.width.toInt()}x${size.height.toInt()}: '
            'EngagementBar bottom: ${actionRowRect.bottom}, '
            'FloatingAppNavigation top: ${navRect.top}, '
            'Gap: ${navRect.top - actionRowRect.bottom}',
          );

          // Assert bottom of ActionRow is at least 16px above top of FloatingAppNavigation
          expect(actionRowRect.bottom, lessThanOrEqualTo(navRect.top - 16.0));
        }

        // Clean up
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
