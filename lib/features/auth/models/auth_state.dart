enum AuthTab { login, signUp }

class AuthState {
  final AuthTab activeTab;
  final String email;
  final String password;
  final bool isPasswordObscured;
  final bool isLoading;
  final String? emailError;
  final String? passwordError;
  final String? generalError;
  final bool isSuccess;

  const AuthState({
    this.activeTab = AuthTab.login,
    this.email = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.isLoading = false,
    this.emailError,
    this.passwordError,
    this.generalError,
    this.isSuccess = false,
  });

  AuthState copyWith({
    AuthTab? activeTab,
    String? email,
    String? password,
    bool? isPasswordObscured,
    bool? isLoading,
    String? emailError,
    String? passwordError,
    String? generalError,
    bool? isSuccess,
  }) {
    return AuthState(
      activeTab: activeTab ?? this.activeTab,
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isLoading: isLoading ?? this.isLoading,
      emailError:
          emailError, // Allow setting to null explicitly by not coalescing if omitted
      passwordError: passwordError,
      generalError: generalError,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
