import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_state.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences has not been initialized');
});

final sessionProvider = NotifierProvider<SessionNotifier, bool>(
  SessionNotifier.new,
);

class SessionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool('is_logged_in') ?? false;
  }

  void setLoggedIn(bool value) {
    state = value;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  void switchTab(AuthTab tab) {
    if (state.activeTab == tab) return;
    // Clear validation states on tab switch
    state = AuthState(activeTab: tab);
  }

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: null, // Clear error when typing
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      passwordError: null, // Clear error when typing
    );
  }

  void toggleObscurePassword() {
    state = state.copyWith(isPasswordObscured: !state.isPasswordObscured);
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or username cannot be empty';
    }
    if (value.contains('@')) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Please enter a valid email address';
      }
    } else {
      if (value.trim().length < 3) {
        return 'Username must be at least 3 characters';
      }
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<bool> submit() async {
    final emailError = validateEmail(state.email);
    final passwordError = validatePassword(state.password);

    if (emailError != null || passwordError != null) {
      state = state.copyWith(
        emailError: emailError,
        passwordError: passwordError,
        generalError: null,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      generalError: null,
      emailError: null,
      passwordError: null,
      isSuccess: false,
    );

    try {
      // Simulate network request duration
      await Future.delayed(const Duration(milliseconds: 1500));

      // Basic mock credentials check for demonstration
      if (state.activeTab == AuthTab.login) {
        if (state.email.trim() == 'error@socialtree.com') {
          throw Exception('An unexpected server error occurred.');
        } else if (state.email.trim() == 'invalid@socialtree.com') {
          state = state.copyWith(
            isLoading: false,
            generalError: 'Invalid email/username or password.',
          );
          return false;
        }
      }

      state = state.copyWith(isLoading: false, isSuccess: true);

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_logged_in', true);
      ref.read(sessionProvider.notifier).setLoggedIn(true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> authenticateWithGoogle() async {
    return _socialAuthMock('Google');
  }

  Future<bool> authenticateWithApple() async {
    return _socialAuthMock('Apple');
  }

  Future<bool> authenticateWithFacebook() async {
    return _socialAuthMock('Facebook');
  }

  Future<bool> _socialAuthMock(String provider) async {
    state = state.copyWith(
      isLoading: true,
      generalError: null,
      isSuccess: false,
    );
    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      state = state.copyWith(isLoading: false, isSuccess: true);

      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('is_logged_in', true);
      ref.read(sessionProvider.notifier).setLoggedIn(true);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        generalError: 'Failed to sign in with $provider',
      );
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove('is_logged_in');
    ref.read(sessionProvider.notifier).setLoggedIn(false);
    resetState();
  }

  void resetState() {
    state = const AuthState();
  }
}
