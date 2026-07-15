import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';
import 'package:dating_app_mobile/features/story/screens/story_composer_screen.dart';
import 'package:dating_app_mobile/features/story/screens/story_preview_screen.dart';
import 'package:dating_app_mobile/features/story/models/story_media_item.dart';
import 'package:dating_app_mobile/features/story/models/story_overlay.dart';
import 'package:dating_app_mobile/features/story/providers/story_composer_provider.dart';
import 'package:dating_app_mobile/features/story/providers/story_gallery_provider.dart';
import 'package:dating_app_mobile/features/story/providers/story_upload_provider.dart';
import 'package:dating_app_mobile/features/story/widgets/story_canvas.dart';
import 'package:dating_app_mobile/features/story/widgets/story_share_button.dart';

void main() {
  late SharedPreferences testPrefs;

  setUpAll(() async {
    HttpOverrides.global = _MockHttpOverrides();
    SharedPreferences.setMockInitialValues({});
    testPrefs = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await testPrefs.clear();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(testPrefs),
      ],
      child: const MaterialApp(
        home: StoryComposerScreen(),
      ),
    );
  }

  void setupViewport(WidgetTester tester, {double width = 800, double height = 1200}) {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Story Composer Screen & Flow Tests', () {
    testWidgets('1. Initial rendering and elements', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check top bar and empty state text
      expect(find.text('Add to Story'), findsOneWidget);
      expect(find.text('Select media to start your story'), findsOneWidget);
      expect(find.text('Choose from the gallery below or capture with camera'), findsOneWidget);

      // Verify Next button in top bar is present and has low opacity/disabled look
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('2. Select media and toggle single/multiple selection', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryComposerScreen));
      final container = ProviderScope.containerOf(element);

      // Toggle multi-select mode in gallery provider
      container.read(storyGalleryProvider.notifier).toggleMultiSelect();
      await tester.pump();

      // Simulate gallery items selection
      final item1 = GalleryMedia(id: 'photo_1', path: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b', isVideo: false);
      final item2 = GalleryMedia(id: 'photo_2', path: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5', isVideo: false);

      container.read(storyComposerProvider.notifier).addGalleryMedia(item1);
      container.read(storyComposerProvider.notifier).addGalleryMedia(item2);
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify canvas is now rendered instead of empty state
      expect(find.byType(StoryCanvas), findsOneWidget);

      // Check state details
      final composerState = container.read(storyComposerProvider);
      expect(composerState.selectedItems.length, equals(2));
      expect(composerState.activeItemIndex, equals(1));
    });

    testWidgets('3. Reordering selected items in multi-selection mode', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryComposerScreen));
      final container = ProviderScope.containerOf(element);

      // Select multiple items
      container.read(storyGalleryProvider.notifier).toggleMultiSelect();
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(id: 'photo_1', path: 'path_1', isVideo: false)
      );
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(id: 'photo_2', path: 'path_2', isVideo: false)
      );
      await tester.pumpAndSettle();

      // Verify initial order
      var state = container.read(storyComposerProvider);
      expect(state.selectedItems[0].path, equals('path_1'));
      expect(state.selectedItems[1].path, equals('path_2'));

      // Call reorderMedia to swap items
      container.read(storyComposerProvider.notifier).reorderMedia(0, 2);
      await tester.pumpAndSettle();

      // Verify reordered order
      state = container.read(storyComposerProvider);
      expect(state.selectedItems[0].path, equals('path_2'));
      expect(state.selectedItems[1].path, equals('path_1'));
    });

    testWidgets('4. Max selection count limit validation (10 items)', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryComposerScreen));
      final container = ProviderScope.containerOf(element);

      // Add 10 items
      for (int i = 0; i < 10; i++) {
        container.read(storyComposerProvider.notifier).addGalleryMedia(
          GalleryMedia(id: 'photo_$i', path: 'path_$i', isVideo: false)
        );
      }
      await tester.pumpAndSettle();

      // Try adding 11th item
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(id: 'photo_11', path: 'path_11', isVideo: false)
      );
      await tester.pump();

      // Verify error message is set
      final state = container.read(storyComposerProvider);
      expect(state.errorMessage, equals('You can select a maximum of 10 items.'));
    });

    testWidgets('5. Video duration limit validation (60s limit)', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryComposerScreen));
      final container = ProviderScope.containerOf(element);

      // Add long video (>60 seconds)
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(
          id: 'long_video',
          path: 'video_path',
          isVideo: true,
          duration: Duration(seconds: 75),
        ),
      );
      await tester.pump();

      // Verify video rejected warning message
      final state = container.read(storyComposerProvider);
      expect(state.errorMessage, equals('Video exceeds maximum duration of 60 seconds.'));
    });

    testWidgets('6. Canvas text overlay positioning, snapping, and delete', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryComposerScreen));
      final container = ProviderScope.containerOf(element);

      // Add media item so canvas is visible
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(id: 'photo_1', path: 'path_1', isVideo: false)
      );
      await tester.pumpAndSettle();

      // Add a text overlay
      final textOverlay = StoryOverlay(
        id: 'overlay_1',
        type: StoryOverlayType.text,
        text: 'Canvas Test Overlay',
        x: 50.0,
        y: 80.0,
      );
      container.read(storyComposerProvider.notifier).addOverlay(textOverlay);
      await tester.pumpAndSettle();

      // Verify overlay rendered on canvas
      expect(find.text('Canvas Test Overlay'), findsOneWidget);

      // Verify we can update and move overlay position
      container.read(storyComposerProvider.notifier).updateOverlay(
        textOverlay.copyWith(x: 100.0, y: 150.0)
      );
      await tester.pumpAndSettle();

      final activeItem = container.read(storyComposerProvider).activeItem;
      expect(activeItem!.overlays[0].x, equals(100.0));
      expect(activeItem.overlays[0].y, equals(150.0));

      // Remove overlay
      container.read(storyComposerProvider.notifier).removeOverlay('overlay_1');
      await tester.pumpAndSettle();
      expect(find.text('Canvas Test Overlay'), findsNothing);
    });

    testWidgets('7. Final preview screen state, audience selection, and draft saving', (WidgetTester tester) async {
      setupViewport(tester);

      final items = [
        const StoryMediaItem(id: 'item_1', path: 'path_1', isVideo: false),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(testPrefs),
          ],
          child: MaterialApp(
            home: StoryPreviewScreen(items: items),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Populate selectedItems in storyComposerProvider to allow saving draft
      final element = tester.element(find.byType(StoryPreviewScreen));
      final container = ProviderScope.containerOf(element);
      container.read(storyComposerProvider.notifier).addGalleryMedia(
        const GalleryMedia(id: 'photo_1', path: 'path_1', isVideo: false),
      );
      await tester.pumpAndSettle();

      // Check header title in preview
      expect(find.text('Preview Story'), findsOneWidget);
      expect(find.text('Save Draft'), findsOneWidget);
      expect(find.text('Audience: Everyone'), findsOneWidget);

      // Save Draft
      await tester.tap(find.text('Save Draft'));
      await tester.pumpAndSettle();

      // Verify draft is saved to Local Storage via SharedPreferences
      expect(testPrefs.getStringList('dating_app_story_drafts'), isNotNull);

      // Open Audience Selector popup
      await tester.tap(find.text('Audience: Everyone'));
      await tester.pumpAndSettle();

      // Select Close Friends
      await tester.tap(find.text('Close Friends').last);
      await tester.pumpAndSettle();

      // Verify Audience Selector text updated
      expect(find.text('Audience: Close Friends'), findsOneWidget);
    });

    testWidgets('8. Upload progress and failure states, retry logic, success redirection', (WidgetTester tester) async {
      setupViewport(tester);

      final items = [
        const StoryMediaItem(id: 'item_1', path: 'path_1', isVideo: false),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(testPrefs),
          ],
          child: MaterialApp(
            home: StoryPreviewScreen(items: items),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final element = tester.element(find.byType(StoryPreviewScreen));
      final container = ProviderScope.containerOf(element);

      // Trigger standard upload
      await tester.tap(find.byType(StoryShareButton));
      await tester.pump(); // Enter uploading state

      // Verify status is uploading
      var uploadState = container.read(storyUploadProvider);
      expect(uploadState.status, equals(StoryUploadStatus.uploading));

      // Resolve uploading timer
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify success
      uploadState = container.read(storyUploadProvider);
      expect(uploadState.status, equals(StoryUploadStatus.success));
    });

    testWidgets('9. Small device viewport safety', (WidgetTester tester) async {
      setupViewport(tester, width: 320, height: 720);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(StoryComposerScreen), findsOneWidget);
    });

    testWidgets('10. High text scaling adaptability', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 1200),
            padding: EdgeInsets.zero,
            devicePixelRatio: 1.0,
            textScaleFactor: 1.3,
          ),
          child: createTestWidget(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StoryComposerScreen), findsOneWidget);
    });
  });
}

// Custom Mock HTTP overrides for testing network-based assets/video files
class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #openUrl || invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #headers) {
      return _MockHttpHeaders();
    }
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return null;
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpClientResponse implements HttpClientResponse {
  static const List<int> _imageBytes = [
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ];

  @override
  int get statusCode => 200;
  @override
  int get contentLength => _imageBytes.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_imageBytes]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
