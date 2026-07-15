import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dating_app_mobile/features/auth/screens/signup_screen.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_tagline.dart';
import 'package:dating_app_mobile/features/auth/widgets/signup_intro.dart';
import 'package:dating_app_mobile/features/auth/widgets/date_of_birth_selector.dart';
import 'package:dating_app_mobile/features/auth/widgets/terms_checkbox.dart';
import 'package:dating_app_mobile/features/auth/widgets/glass_auth_text_field.dart';
import 'package:dating_app_mobile/features/auth/widgets/auth_primary_button.dart';
import 'package:dating_app_mobile/features/auth/widgets/social_auth_button.dart';
import 'package:dating_app_mobile/features/auth/widgets/login_redirect.dart';
import 'package:dating_app_mobile/features/home/screens/social_home_screen.dart';
import 'package:dating_app_mobile/features/auth/providers/auth_provider.dart';

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
      overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
      child: const MaterialApp(home: SignupScreen()),
    );
  }

  void setupViewport(WidgetTester tester, {Size size = const Size(800, 1200)}) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Signup Screen Widget Tests', () {
    testWidgets('1. Initial rendering of SignupScreen', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check header and tagline
      expect(find.text('Social Tree'), findsOneWidget);
      expect(find.byType(AuthTagline), findsOneWidget);

      // Check intro heading
      expect(find.byType(SignupIntroSection), findsOneWidget);
      expect(find.textContaining('Create Account'), findsOneWidget);

      // Check text fields
      expect(find.byKey(const ValueKey('full_name_field')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('email_username_field')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('phone_field')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('signup_password_field')),
        findsOneWidget,
      );

      // Check DOB and Terms components
      expect(find.byType(DateOfBirthSelector), findsOneWidget);
      expect(find.byType(TermsAgreementCheckbox), findsOneWidget);

      // Check primary CTA and Redirect
      expect(find.byType(AuthPrimaryButton), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
      expect(find.byType(LoginRedirect), findsOneWidget);
    });

    testWidgets('2. Field validation triggers error messages', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Create Account button with all fields empty
      final ctaBtn = find.byType(AuthPrimaryButton);
      await tester.tap(ctaBtn);
      await tester.pump();

      // Verify validation errors
      expect(find.text('Full Name cannot be empty'), findsOneWidget);
      expect(find.text('Email or username cannot be empty'), findsOneWidget);
      expect(find.text('Password cannot be empty'), findsOneWidget);
      expect(find.text('Please complete your Date of Birth'), findsOneWidget);
      expect(
        find.text('You must agree to the Terms of Service'),
        findsOneWidget,
      );
    });

    testWidgets('3. Optional phone input validation', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter details except phone (keep phone empty)
      await tester.enterText(
        find.byKey(const ValueKey('full_name_field')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('email_username_field')),
        'john@gmail.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'password123',
      );

      // Submit and verify that phone does NOT have a validation error
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();
      expect(find.text('Please enter a valid phone number'), findsNothing);

      // Now enter a too-short phone number and check error
      await tester.enterText(find.byKey(const ValueKey('phone_field')), '123');
      await tester.tap(find.byType(AuthPrimaryButton));
      await tester.pump();
      expect(find.text('Please enter a valid phone number'), findsOneWidget);
    });

    testWidgets('4. Password visibility toggle works correctly', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final passwordFieldFinder = find.byKey(
        const ValueKey('signup_password_field'),
      );
      final passwordWidget = tester.widget<GlassAuthTextField>(
        passwordFieldFinder,
      );
      expect(passwordWidget.obscureText, isTrue);

      // Tap show password visibility toggle
      final visibilityToggle = find.bySemanticsLabel('Show password');
      expect(visibilityToggle, findsOneWidget);
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Verify that obscureText is now false
      final updatedPasswordWidget = tester.widget<GlassAuthTextField>(
        passwordFieldFinder,
      );
      expect(updatedPasswordWidget.obscureText, isFalse);
    });

    testWidgets('5. DOB custom selector and underage validation', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on Day selector ('DD')
      await tester.tap(find.text('DD'));
      await tester.pumpAndSettle();

      // Verify sheet opens with selection title
      expect(find.text('Select Day'), findsOneWidget);
      // Select day 01
      await tester.tap(find.text('01').first);
      await tester.pumpAndSettle();

      // Tap Month selector ('MM')
      await tester.tap(find.text('MM'));
      await tester.pumpAndSettle();
      expect(find.text('Select Month'), findsOneWidget);
      // Select January (1 (Jan))
      await tester.tap(find.text('1 (Jan)').first);
      await tester.pumpAndSettle();

      // Tap Year selector ('YYYY')
      await tester.tap(find.text('YYYY'));
      await tester.pumpAndSettle();
      expect(find.text('Select Year'), findsOneWidget);

      // Select underage year 2025
      await tester.tap(find.text('2025').first);
      await tester.pumpAndSettle();

      // Scroll to primary button and submit
      final mainScrollable = find.byType(Scrollable).first;
      final ctaFinder = find.byType(AuthPrimaryButton);
      await tester.scrollUntilVisible(
        ctaFinder,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(ctaFinder);
      await tester.pump();
      expect(find.text('You must be at least 18 years old'), findsOneWidget);
    });

    testWidgets('6. Terms checkbox toggles correctly', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final mainScrollable = find.byType(Scrollable).first;

      // Try submitting without checking terms
      final ctaBtn = find.byType(AuthPrimaryButton);
      await tester.scrollUntilVisible(ctaBtn, 50.0, scrollable: mainScrollable);
      await tester.tap(ctaBtn);
      await tester.pump();
      expect(
        find.text('You must agree to the Terms of Service'),
        findsOneWidget,
      );

      // Scroll to terms checkbox and check it
      final termsFinder = find.byType(TermsAgreementCheckbox);
      await tester.scrollUntilVisible(
        termsFinder,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(termsFinder);
      await tester.pump();

      // Verify error is cleared or doesn't show terms error anymore on submit
      await tester.tap(ctaBtn);
      await tester.pump();
      expect(find.text('You must agree to the Terms of Service'), findsNothing);
    });

    testWidgets('7. Signup loading state and successful home navigation', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final mainScrollable = find.byType(Scrollable).first;

      // Enter valid credentials
      await tester.enterText(
        find.byKey(const ValueKey('full_name_field')),
        'John Doe',
      );
      await tester.enterText(
        find.byKey(const ValueKey('email_username_field')),
        'john@socialtree.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('signup_password_field')),
        'password123',
      );

      // Setup valid adult DOB: Day 01, Month 1 (Jan), Year 2000
      await tester.tap(find.text('DD'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('01').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('MM'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('1 (Jan)').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('YYYY'));
      await tester.pumpAndSettle();

      // Scroll bottom sheet list to find year 2000
      final listScrollable = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('2000'),
        100.0,
        scrollable: listScrollable,
      );
      await tester.tap(find.text('2000').first);
      await tester.pumpAndSettle();

      // Scroll to Terms and accept them
      final termsFinder = find.byType(TermsAgreementCheckbox);
      await tester.scrollUntilVisible(
        termsFinder,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(termsFinder);
      await tester.pumpAndSettle();

      // Tap Create Account button
      final ctaFinder = find.byType(AuthPrimaryButton);
      await tester.scrollUntilVisible(
        ctaFinder,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(ctaFinder);
      await tester.pump(); // Enter loading state

      // Verify loading progress indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle simulated network call of 1500ms
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 1500),
      ); // Transition to Home

      // Verify transition to Home screen
      expect(find.byType(SocialHomeScreen), findsOneWidget);
    });

    testWidgets('8. Social Signup buttons action', (WidgetTester tester) async {
      setupViewport(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final mainScrollable = find.byType(Scrollable).first;

      final googleBtn = find.byWidgetPredicate(
        (widget) =>
            widget is SocialAuthButton &&
            widget.provider == SocialProvider.google,
      );
      expect(googleBtn, findsOneWidget);

      // Scroll to google button
      await tester.scrollUntilVisible(
        googleBtn,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(googleBtn);
      await tester.pump(); // Start social signup loading

      // Wait for mock duration
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.byType(SocialHomeScreen), findsOneWidget);
    });

    testWidgets('9. Login Redirect pops navigation stack', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);

      bool popped = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
          child: MaterialApp(
            home: Navigator(
              onPopPage: (route, result) {
                popped = true;
                return route.didPop(result);
              },
              pages: const [
                MaterialPage(child: Scaffold(body: Text('Base'))),
                MaterialPage(child: SignupScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mainScrollable = find.byType(Scrollable).first;

      final loginRedirect = find.byType(LoginRedirect);
      expect(loginRedirect, findsOneWidget);

      // Scroll to login redirect link before tapping it
      await tester.scrollUntilVisible(
        loginRedirect,
        50.0,
        scrollable: mainScrollable,
      );
      await tester.tap(loginRedirect);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('10. Small viewport responsive safety', (
      WidgetTester tester,
    ) async {
      // Set small dimensions (320 x 720)
      setupViewport(tester, size: const Size(320, 720));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify screen renders successfully without layout overflow exceptions
      expect(tester.takeException(), isNull);
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('11. 1.3x accessible text scaling safety', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaleFactor: 1.3),
          child: createTestWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify no exceptions and success rendering
      expect(tester.takeException(), isNull);
      expect(find.byType(SignupScreen), findsOneWidget);
    });

    testWidgets('12. Top-left back button pops navigation stack', (
      WidgetTester tester,
    ) async {
      setupViewport(tester);

      bool popped = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(testPrefs)],
          child: MaterialApp(
            home: Navigator(
              onPopPage: (route, result) {
                popped = true;
                return route.didPop(result);
              },
              pages: const [
                MaterialPage(child: Scaffold(body: Text('Base'))),
                MaterialPage(child: SignupScreen()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back_ios);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });
  });
}

// Custom Mock HTTP classes to support HTTP client tests correctly

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
    0x89,
    0x50,
    0x4E,
    0x47,
    0x0D,
    0x0A,
    0x1A,
    0x0A,
    0x00,
    0x00,
    0x00,
    0x0D,
    0x49,
    0x48,
    0x44,
    0x52,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x01,
    0x08,
    0x06,
    0x00,
    0x00,
    0x00,
    0x1F,
    0x15,
    0xC4,
    0x89,
    0x00,
    0x00,
    0x00,
    0x0A,
    0x49,
    0x44,
    0x41,
    0x54,
    0x78,
    0x9C,
    0x63,
    0x00,
    0x01,
    0x00,
    0x00,
    0x05,
    0x00,
    0x01,
    0x0D,
    0x0A,
    0x2D,
    0xB4,
    0x00,
    0x00,
    0x00,
    0x00,
    0x49,
    0x45,
    0x4E,
    0x44,
    0xAE,
    0x42,
    0x60,
    0x82,
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
