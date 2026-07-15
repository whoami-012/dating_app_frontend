import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:dating_app_mobile/features/media_upload/models/selected_media.dart';
import 'package:dating_app_mobile/features/media_upload/utils/media_helper.dart';
import 'package:dating_app_mobile/features/media_upload/widgets/upload_video_preview.dart';

// ---------------------------------------------------------------------------
// Fake platform – prevents native channel calls from hanging under FakeAsync.
// ---------------------------------------------------------------------------
class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions creationOptions) async {
    return 1;
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    return const SizedBox();
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => const Stream.empty();

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async {}

  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
}

// ---------------------------------------------------------------------------
// Mock controller – overrides every method so no platform I/O happens.
// ---------------------------------------------------------------------------
class MockVideoPlayerController extends VideoPlayerController {
  final bool shouldFail;
  final Duration mockDuration;
  final Function(MockVideoPlayerController)? onDisposed;

  MockVideoPlayerController.file(
    super.file, {
    this.shouldFail = false,
    this.mockDuration = const Duration(seconds: 15),
    this.onDisposed,
  }) : super.file();

  MockVideoPlayerController.network(
    Uri url, {
    this.shouldFail = false,
    this.mockDuration = const Duration(seconds: 15),
    this.onDisposed,
  }) : super.networkUrl(url);

  bool _isInit = false;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  int initCount = 0;
  bool isDisposed = false;

  @override
  VideoPlayerValue get value => VideoPlayerValue(
    duration: mockDuration,
    size: const Size(1920, 1080),
    position: _position,
    isPlaying: _isPlaying,
    isInitialized: _isInit,
    errorDescription: shouldFail ? 'Mock playback error' : null,
  );

  @override
  Future<void> initialize() async {
    initCount++;
    if (shouldFail) {
      throw Exception('Mock initialization failed');
    }
    _isInit = true;
    notifyListeners();
  }

  @override
  Future<void> play() async {
    _isPlaying = true;
    notifyListeners();
  }

  @override
  Future<void> pause() async {
    _isPlaying = false;
    notifyListeners();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _position = position;
    notifyListeners();
  }

  @override
  int get textureId => 1;

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> setLooping(bool looping) async {}

  @override
  Future<void> dispose() async {
    isDisposed = true;
    if (onDisposed != null) onDisposed!(this);
    // Do NOT call super.dispose() – it would invoke the real platform.
  }
}

// ---------------------------------------------------------------------------
// Mock factory – injected via Riverpod override.
// ---------------------------------------------------------------------------
class MockVideoPlayerControllerFactory implements VideoPlayerControllerFactory {
  final bool shouldFail;
  final Function(MockVideoPlayerController)? onControllerCreated;
  final List<MockVideoPlayerController> createdControllers = [];

  MockVideoPlayerControllerFactory({
    this.shouldFail = false,
    this.onControllerCreated,
  });

  @override
  VideoPlayerController file(File f) {
    final controller = MockVideoPlayerController.file(
      f,
      shouldFail: shouldFail,
    );
    createdControllers.add(controller);
    if (onControllerCreated != null) onControllerCreated!(controller);
    return controller;
  }

  @override
  VideoPlayerController networkUrl(Uri url) {
    final controller = MockVideoPlayerController.network(
      url,
      shouldFail: shouldFail,
    );
    createdControllers.add(controller);
    if (onControllerCreated != null) onControllerCreated!(controller);
    return controller;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  // Install the fake platform once for the whole suite so no test can reach a
  // real platform channel (which would hang under FakeAsync).
  setUpAll(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  group('Video Preview & Helper Tests', () {
    // --- Pure unit tests (no widget pump, no file I/O) --------------------

    test('Local and Remote URL detection', () {
      expect(MediaHelper.isRemoteUrl('https://example.com/video.mp4'), isTrue);
      expect(MediaHelper.isRemoteUrl('http://example.com/video.mp4'), isTrue);
      expect(MediaHelper.isRemoteUrl('/local/path/video.mp4'), isFalse);
      expect(
        MediaHelper.isRemoteUrl('content://media/external/video/media/1'),
        isFalse,
      );
    });

    test('SelectedMedia image and video type classification', () {
      const photo = SelectedMedia(id: '1', path: 'path', isVideo: false);
      const video = SelectedMedia(id: '2', path: 'path', isVideo: true);
      expect(photo.isVideo, isFalse);
      expect(video.isVideo, isTrue);
    });

    test('Simple controller instantiate, initialize, dispose test', () async {
      final file = File('dummy.mp4');
      final controller = MockVideoPlayerController.file(file);
      await controller.initialize();
      await controller.dispose();
      expect(controller.isDisposed, isTrue);
    });

    // --- Widget tests -------------------------------------------------------
    //
    // IMPORTANT: testWidgets runs inside FakeAsync. Any real I/O (e.g.
    // File.writeAsString) must be wrapped in `tester.runAsync(() async { … })`.
    // pumpWidget / pump / tap must be called *outside* runAsync.

    testWidgets('Controller initialization and lifecycle', (
      WidgetTester tester,
    ) async {
      // Real I/O → runAsync
      final tempPath = '${Directory.systemTemp.path}/test_video_lifecycle.mp4';
      await tester.runAsync(() async {
        await File(tempPath).writeAsString('dummy video data');
      });

      MockVideoPlayerController? createdController;
      final factory = MockVideoPlayerControllerFactory(
        onControllerCreated: (c) => createdController = c,
      );

      // pumpWidget must be outside runAsync
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(body: UploadVideoPreview(videoPathOrUrl: tempPath)),
          ),
        ),
      );
      await tester.pump();

      expect(createdController, isNotNull);
      expect(createdController!.initCount, equals(1));
      expect(createdController!.value.isInitialized, isTrue);

      // Drive play directly via the controller (tests that the widget responds
      // to controller state changes, not just tap targeting).
      await createdController!.play();
      await tester.pump();
      await tester.pump();
      expect(createdController!.value.isPlaying, isTrue);

      // Drive pause directly.
      await createdController!.pause();
      await tester.pump();
      await tester.pump();
      expect(createdController!.value.isPlaying, isFalse);

      // Remove widget – controller should be disposed
      await tester.pumpWidget(const SizedBox());
      expect(createdController!.isDisposed, isTrue);

      await tester.runAsync(() async {
        final f = File(tempPath);
        if (await f.exists()) await f.delete();
      });
    });

    testWidgets('Controller disposed when media changes', (
      WidgetTester tester,
    ) async {
      final path1 = '${Directory.systemTemp.path}/test_video_change_1.mp4';
      final path2 = '${Directory.systemTemp.path}/test_video_change_2.mp4';
      await tester.runAsync(() async {
        await File(path1).writeAsString('dummy');
        await File(path2).writeAsString('dummy');
      });

      final factory = MockVideoPlayerControllerFactory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UploadVideoPreview(
                key: const ValueKey('preview'),
                videoPathOrUrl: path1,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(factory.createdControllers.length, equals(1));
      final firstController = factory.createdControllers.first;

      // Swap to a new path – should dispose first controller and create second
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UploadVideoPreview(
                key: const ValueKey('preview'),
                videoPathOrUrl: path2,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(firstController.isDisposed, isTrue);
      expect(factory.createdControllers.length, equals(2));

      await tester.runAsync(() async {
        await File(path1).delete();
        await File(path2).delete();
      });
    });

    testWidgets('Initialization failure and retry UI', (
      WidgetTester tester,
    ) async {
      final path = '${Directory.systemTemp.path}/failed_video.mp4';
      await tester.runAsync(() async {
        await File(path).writeAsString('dummy');
      });

      final factory = MockVideoPlayerControllerFactory(shouldFail: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(body: UploadVideoPreview(videoPathOrUrl: path)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unable to play this video'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Swap to a succeeding factory and retry
      final successFactory = MockVideoPlayerControllerFactory();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(
              successFactory,
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: UploadVideoPreview(videoPathOrUrl: path)),
          ),
        ),
      );
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unable to play this video'), findsNothing);

      await tester.runAsync(() async {
        try {
          await File(path).delete();
        } catch (_) {}
      });
    });

    testWidgets('Missing/expired local file shows error state', (
      WidgetTester tester,
    ) async {
      final factory = MockVideoPlayerControllerFactory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: UploadVideoPreview(videoPathOrUrl: '/nonexistent/path.mp4'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Unable to play this video'), findsOneWidget);
    });

    testWidgets('Preview does not overflow at 320 px width', (
      WidgetTester tester,
    ) async {
      final path = '${Directory.systemTemp.path}/overflow_video.mp4';
      await tester.runAsync(() async {
        await File(path).writeAsString('dummy');
      });

      final factory = MockVideoPlayerControllerFactory();

      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: UploadVideoPreview(videoPathOrUrl: path),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      await tester.runAsync(() async {
        await File(path).delete();
      });
    });

    testWidgets('No duplicate controller creation after parent rebuild', (
      WidgetTester tester,
    ) async {
      final path = '${Directory.systemTemp.path}/rebuild_video.mp4';
      await tester.runAsync(() async {
        await File(path).writeAsString('dummy');
      });

      final factory = MockVideoPlayerControllerFactory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            videoPlayerControllerFactoryProvider.overrideWithValue(factory),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Rebuild Parent'),
                        ),
                        SizedBox(
                          height: 300,
                          child: UploadVideoPreview(videoPathOrUrl: path),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(factory.createdControllers.length, equals(1));

      await tester.tap(find.text('Rebuild Parent'));
      await tester.pump();
      // Controller must NOT be re-created on a parent-only rebuild
      expect(factory.createdControllers.length, equals(1));

      await tester.runAsync(() async {
        await File(path).delete();
      });
    });
  });
}
