import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/signup_form_state.dart';
import 'auth_provider.dart';

final signupProvider = NotifierProvider<SignupNotifier, SignupFormState>(
  SignupNotifier.new,
);

class SignupNotifier extends Notifier<SignupFormState> {
  @override
  SignupFormState build() {
    return const SignupFormState();
  }

  void setFullName(String name) {
    state = state.copyWith(fullName: name, fullNameError: null);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, emailError: null);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone, phoneError: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, passwordError: null);
  }

  void setDob(int? day, int? month, int? year) {
    state = state.copyWith(
      dobDay: day,
      dobMonth: month,
      dobYear: year,
      dobError: null,
    );
  }

  void setAgreeToTerms(bool agree) {
    state = state.copyWith(agreeToTerms: agree, termsError: null);
  }

  void toggleObscurePassword() {
    state = state.copyWith(isPasswordObscured: !state.isPasswordObscured);
  }

  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full Name cannot be empty';
    }
    return null;
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

  String? validatePhoneNumber(String? value) {
    // Optional field. If non-empty, we can do light formatting validation.
    if (value != null && value.trim().isNotEmpty) {
      if (value.trim().length < 7) {
        return 'Please enter a valid phone number';
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

  String? validateDob(int? day, int? month, int? year) {
    if (day == null || month == null || year == null) {
      return 'Please complete your Date of Birth';
    }

    // Check for valid date construct
    try {
      final dob = DateTime(year, month, day);
      final now = DateTime.now();

      if (dob.isAfter(now)) {
        return 'Date of Birth cannot be in the future';
      }

      // Calculate age
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }

      if (age < 18) {
        return 'You must be at least 18 years old';
      }
    } catch (_) {
      return 'Please select a valid date';
    }

    return null;
  }

  String? validateTerms(bool agreed) {
    if (!agreed) {
      return 'You must agree to the Terms of Service';
    }
    return null;
  }

  Future<bool> submit() async {
    final nameErr = validateFullName(state.fullName);
    final emailErr = validateEmail(state.email);
    final phoneErr = validatePhoneNumber(state.phoneNumber);
    final passErr = validatePassword(state.password);
    final dobErr = validateDob(state.dobDay, state.dobMonth, state.dobYear);
    final termsErr = validateTerms(state.agreeToTerms);

    if (nameErr != null ||
        emailErr != null ||
        phoneErr != null ||
        passErr != null ||
        dobErr != null ||
        termsErr != null) {
      state = state.copyWith(
        fullNameError: nameErr,
        emailError: emailErr,
        phoneError: phoneErr,
        passwordError: passErr,
        dobError: dobErr,
        termsError: termsErr,
        generalError: null,
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      generalError: null,
      fullNameError: null,
      emailError: null,
      phoneError: null,
      passwordError: null,
      dobError: null,
      termsError: null,
      isSuccess: false,
    );

    try {
      // Simulate network request duration
      await Future.delayed(const Duration(milliseconds: 1500));

      if (state.email.trim() == 'error@socialtree.com') {
        throw Exception('An unexpected server error occurred.');
      } else if (state.email.trim() == 'exists@socialtree.com') {
        state = state.copyWith(
          isLoading: false,
          generalError: 'This email/username is already registered.',
        );
        return false;
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
      fullNameError: null,
      emailError: null,
      phoneError: null,
      passwordError: null,
      dobError: null,
      termsError: null,
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
        generalError: 'Failed to sign up with $provider',
      );
      return false;
    }
  }

  void resetState() {
    state = const SignupFormState();
  }
}
