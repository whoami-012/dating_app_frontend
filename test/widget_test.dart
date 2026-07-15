import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/main.dart';
import 'package:dating_app_mobile/features/auth/screens/auth_screen.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_brand_header.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_tagline.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_mode_tabs.dart';
import 'package:dating_app_mobile/features/auth/widgets/glass_auth_text_field.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:dating_app_mobile/features/auth/widgets/social_auth_button.dart';
import 'package:dating_app_mobile/features/home/screens/social_home_screen.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';

import 'package:dating_app_mobile/features/auth/screens/signup_screen.dart';
import 'package:dating_app_mobile/features/auth/widgets/login_redirect.dart';

void main() {
  late SharedPreferences testPrefs;

  setUpAll(() async {
    HttpOverrides.global = MockHttpOverrides();
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
      child: const MyApp(),
    );
  }

  void setupViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Auth Screen Widget Tests', () {
    testWidgets('1. Initial rendering of AuthScreen', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check header components
      expect(find.byType(AuthBrandHeader), findsOneWidget);
      expect(find.text('Social Tree'), findsOneWidget);
      expect(find.byType(AuthTagline), findsOneWidget);

      // Check intro text
      expect(find.textContaining('Welcome'), findsOneWidget);
      expect(find.textContaining('Login to continue your journey'), findsOneWidget);

      // Check inputs and buttons
      expect(find.byType(AuthModeTabs), findsOneWidget);
      expect(find.byKey(const ValueKey('email_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('password_field')), findsOneWidget);
      expect(find.byType(AuthPrimaryButton), findsOneWidget);
      expect(find.text('Login'), findsWidgets); // Both tab & button text
    });

    testWidgets('2. Tab switching between Login and Sign Up', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Sign Up tab
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Check that it transitioned to SignupScreen
      expect(find.byType(SignupScreen), findsOneWidget);

      final mainScrollable = find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Scrollable),
      ).first;

      // Scroll to login redirect and tap it
      final loginRedirect = find.byType(LoginRedirect);
      await tester.scrollUntilVisible(loginRedirect, 50.0, scrollable: mainScrollable);
      await tester.tap(loginRedirect);
      await tester.pumpAndSettle();

      // Verify we returned to AuthScreen
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.textContaining('Welcome'), findsOneWidget);
    });

    testWidgets('3. Form validation triggers error messages', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Login button with empty inputs
      final loginButton = find.byType(AuthPrimaryButton);
      await tester.tap(loginButton);
      await tester.pump(); // Pump frame to trigger state update

      // Check validation error strings
      expect(find.text('Email or username cannot be empty'), findsOneWidget);
      expect(find.text('Password cannot be empty'), findsOneWidget);
    });

    testWidgets('4. Password visibility toggle works correctly', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final passwordFieldFinder = find.byKey(const ValueKey('password_field'));
      final passwordFieldWidget = tester.widget<GlassAuthTextField>(passwordFieldFinder);
      expect(passwordFieldWidget.obscureText, isTrue);

      // Tap visibility toggle icon
      final visibilityToggle = find.bySemanticsLabel('Show password');
      expect(visibilityToggle, findsOneWidget);
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Re-query text field widget and verify obscureText has changed
      final updatedTextField = tester.widget<GlassAuthTextField>(passwordFieldFinder);
      expect(updatedTextField.obscureText, isFalse);
    });

    testWidgets('5. Login loading state and successful home navigation', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byKey(const ValueKey('email_field')), 'test@socialtree.com');
      await tester.enterText(find.byKey(const ValueKey('password_field')), 'password123');
      await tester.pump();

      // Click CTA
      final loginBtn = find.byType(AuthPrimaryButton);
      await tester.tap(loginBtn);
      await tester.pump(); // Enter loading state

      // Verify that spinner displays inside loading button
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle simulated network call of 1500ms
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500)); // Transition to Home

      // Verify transition to Home screen
      expect(find.byType(SocialHomeScreen), findsOneWidget);
    });

    testWidgets('6. Social Auth button click triggers action', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find Google login button
      final googleBtn = find.byWidgetPredicate(
        (widget) => widget is SocialAuthButton && widget.provider == SocialProvider.google,
      );
      expect(googleBtn, findsOneWidget);

      await tester.tap(googleBtn);
      await tester.pump(); // Enter social loading status
      
      // Wait for mock duration
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500)); // Transition to Home

      // Verify transition to Home
      expect(find.byType(SocialHomeScreen), findsOneWidget);
    });

    testWidgets('7. Responsive Layout does not crash on small viewport', (WidgetTester tester) async {
      // Set small screen dimensions (320 x 720)
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Ensure no layout issues/overflows occur
      expect(tester.takeException(), isNull);
      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('8. Accessible text scaling adapts without clipping', (WidgetTester tester) async {
      // Simulate system text scaling at 1.3x
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.3),
          child: createTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure page renders fine and elements are accessible
      expect(tester.takeException(), isNull);
      expect(find.byType(AuthScreen), findsOneWidget);
    });

    group('Home feed regression check', () {
      testWidgets('Social Tree home feed can be opened directly', (WidgetTester tester) async {
        setupViewport(tester);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(testPrefs),
            ],
            child: const MaterialApp(
              home: SocialHomeScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));
        expect(find.byType(SocialHomeScreen), findsOneWidget);
      });
    });
  });
}

// Custom Mock HTTP classes using noSuchMethod dynamic routing to support arbitrary Dart SDK signatures

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #open ||
        invocation.memberName == #openUrl ||
        invocation.memberName == #get ||
        invocation.memberName == #getUrl) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    if (invocation.memberName == #close || invocation.memberName == #response) {
      return Future.value(MockHttpClientResponse());
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

class MockHttpClientResponse implements HttpClientResponse {
  static const List<int> _transparentImage = [
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
  int get contentLength => _transparentImage.length;
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
    return Stream<List<int>>.fromIterable([_transparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}
