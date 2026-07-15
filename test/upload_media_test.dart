import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';
import 'package:dating_app_mobile/features/media_upload/models/selected_media.dart';
import 'package:dating_app_mobile/features/media_upload/models/upload_post_state.dart';
import 'package:dating_app_mobile/features/media_upload/providers/upload_post_provider.dart';
import 'package:dating_app_mobile/features/media_upload/screens/upload_media_screen.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/media_preview_card.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/add_media_card.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/upload_primary_button.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/tag_selector.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/upload_error_banner.dart';

void main() {
  late SharedPreferences testPrefs;

  setUpAll(() async {
    // Setup Mock HTTP overrides
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
        home: UploadMediaScreen(),
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

  group('Upload Media Screen Widget Tests', () {
    testWidgets('1. Initial rendering and empty state', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check header titles
      expect(find.text('Upload Media'), findsOneWidget);
      expect(find.text('Share your moment'), findsOneWidget);
      expect(find.text('Drafts'), findsOneWidget);

      // Check preview strip has 0 media cards and exactly 1 AddMoreMediaCard
      expect(find.byType(MediaPreviewCard), findsNothing);
      expect(find.byType(AddMoreMediaCard), findsOneWidget);

      // Check that the limit helper text is visible
      expect(find.textContaining('You can add up to 10 photos or 1 video'), findsOneWidget);

      // Check caption input elements
      expect(find.text('Write a caption'), findsOneWidget);
      expect(find.text('0/300'), findsOneWidget);

      // Check tags presets
      expect(find.text('Adventure'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);

      // Check settings rows
      expect(find.text('Who can see this?'), findsOneWidget);
      expect(find.text('Add Location'), findsOneWidget);
      expect(find.text('Advanced Settings'), findsOneWidget);

      // Verify that primary upload CTA is disabled when there's no media
      final uploadBtn = tester.widget<UploadPrimaryButton>(find.byType(UploadPrimaryButton));
      expect(uploadBtn.isEnabled, isFalse);
    });

    testWidgets('2. Add and Remove media', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      
      // Directly add media via the provider state to simulate picker success
      container.read(uploadPostProvider.notifier).addMedia(
        const SelectedMedia(id: 'photo_test_1', path: 'photo_test_path', isVideo: false),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify media preview card rendered
      expect(find.byType(MediaPreviewCard), findsOneWidget);

      // Verify button is now enabled
      final uploadBtn = tester.widget<UploadPrimaryButton>(find.byType(UploadPrimaryButton));
      expect(uploadBtn.isEnabled, isTrue);

      // Tap remove overlay button on the card
      await tester.tap(
        find.descendant(
          of: find.byType(MediaPreviewCard),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify card was removed
      expect(find.byType(MediaPreviewCard), findsNothing);
    });

    testWidgets('3. Maximum-media validation', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      final notifier = container.read(uploadPostProvider.notifier);

      // Add 10 photos
      for (int i = 0; i < 10; i++) {
        notifier.addMedia(SelectedMedia(id: 'photo_$i', path: 'path_$i', isVideo: false));
      }
      await tester.pumpAndSettle();

      // Try to add the 11th photo
      notifier.addMedia(const SelectedMedia(id: 'photo_11', path: 'path_11', isVideo: false));
      await tester.pump();

      // Verify state has validation error
      final state = container.read(uploadPostProvider);
      expect(state.errorMessage, equals('Maximum of 10 photos allowed.'));
    });

    testWidgets('4. Video-duration validation', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      final notifier = container.read(uploadPostProvider.notifier);

      // Add long video (>60 seconds)
      notifier.addMedia(const SelectedMedia(
        id: 'long_vid',
        path: 'vid_path',
        isVideo: true,
        duration: Duration(seconds: 75),
      ));
      await tester.pump();

      // Verify error message is set
      final state = container.read(uploadPostProvider);
      expect(state.errorMessage, equals('Video exceeds maximum duration of 60 seconds.'));
    });

    testWidgets('5. Caption counter updates', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Type text into caption input field
      await tester.enterText(find.byType(TextField).first, 'Hello World!');
      await tester.pump();

      // Verify counter shows correct length
      expect(find.text('12/300'), findsOneWidget);
    });

    testWidgets('6. Tag selection toggles state', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Adventure chip
      final adventureChip = find.text('Adventure');
      expect(adventureChip, findsOneWidget);

      // Tap to select tag
      await tester.tap(find.byType(TagChip).first);
      await tester.pump();

      // Verify in provider that tag is selected
      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      expect(container.read(uploadPostProvider).tags, contains('Adventure'));
    });

    testWidgets('7. Visibility settings update', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap privacy setting tile
      await tester.tap(find.byKey(const ValueKey('visibility_tile')));
      await tester.pumpAndSettle();

      // Tap "Everyone" option inside bottom sheet
      await tester.tap(find.text('Everyone'));
      await tester.pumpAndSettle();

      // Verify tile subtitle updated
      expect(find.text('Everyone'), findsOneWidget);
    });

    testWidgets('8. Upload progress and loading states', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      
      // Add media so button is enabled
      container.read(uploadPostProvider.notifier).addMedia(
        const SelectedMedia(id: 'photo_test', path: 'path', isVideo: false),
      );
      await tester.pumpAndSettle();

      // Click upload CTA
      await tester.tap(find.byType(UploadPrimaryButton));
      await tester.pump(); // Enter uploading state

      // Verify progress indicators are shown
      expect(find.textContaining('Uploading'), findsWidgets);
      
      // Complete mock uploading
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      // Allow homeProvider's initial load timer to complete
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('9. Upload failure and retry', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(UploadMediaScreen)));
      container.read(uploadPostProvider.notifier).addMedia(
        const SelectedMedia(id: 'photo_test', path: 'path', isVideo: false),
      );
      
      // Set caption to trigger failure simulation
      container.read(uploadPostProvider.notifier).updateCaption('trigger failure');
      await tester.pumpAndSettle();

      // Tap Upload CTA
      await tester.tap(find.byType(UploadPrimaryButton));
      await tester.pump(); // Enter uploading state
      await tester.pump(const Duration(seconds: 2)); // Resolve uploads
      await tester.pumpAndSettle();

      // Verify error banner is visible
      expect(find.byType(UploadErrorBanner), findsOneWidget);
      expect(find.textContaining('Network connection timed out'), findsOneWidget);

      // Verify state is failure
      expect(container.read(uploadPostProvider).status, equals(UploadStatus.failure));

      // Dismiss banner first
      await tester.tap(
        find.descendant(
          of: find.byType(UploadErrorBanner),
          matching: find.byIcon(Icons.close),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Upload Failed'), findsNothing);
      expect(find.textContaining('Network connection timed out'), findsNothing);

      // Trigger another upload failure
      await tester.tap(find.byType(UploadPrimaryButton));
      await tester.pump(); // Enter uploading state
      await tester.pump(const Duration(seconds: 2)); // Resolve uploads
      await tester.pumpAndSettle();

      // Tap Retry Upload button
      await tester.tap(find.text('Retry Upload'));
      await tester.pump();
      expect(container.read(uploadPostProvider).status, equals(UploadStatus.uploading));

      // Resolve the retried upload (fails again)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('10. Small viewport safety', (WidgetTester tester) async {
      // Setup small device dimensions (320 x 720)
      setupViewport(tester, width: 320, height: 720);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify page is rendered completely without overflows/crashes
      expect(tester.takeException(), isNull);
      expect(find.byType(UploadMediaScreen), findsOneWidget);
    });

    testWidgets('11. Text scaling adaptations', (WidgetTester tester) async {
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

      // Verify page adapts correctly without any issues
      expect(tester.takeException(), isNull);
      expect(find.byType(UploadMediaScreen), findsOneWidget);
    });
  });
}

// Custom Mock HTTP classes for tests
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
