class SignupFormState {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String password;
  final int? dobDay;
  final int? dobMonth;
  final int? dobYear;
  final bool agreeToTerms;
  final bool isPasswordObscured;
  final bool isLoading;
  final bool isSuccess;

  // Errors
  final String? fullNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? dobError;
  final String? termsError;
  final String? generalError;

  const SignupFormState({
    this.fullName = '',
    this.email = '',
    this.phoneNumber = '',
    this.password = '',
    this.dobDay,
    this.dobMonth,
    this.dobYear,
    this.agreeToTerms = false,
    this.isPasswordObscured = true,
    this.isLoading = false,
    this.isSuccess = false,
    this.fullNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.dobError,
    this.termsError,
    this.generalError,
  });

  SignupFormState copyWith({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? password,
    int? dobDay,
    int? dobMonth,
    int? dobYear,
    bool? agreeToTerms,
    bool? isPasswordObscured,
    bool? isLoading,
    bool? isSuccess,
    String? fullNameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? dobError,
    String? termsError,
    String? generalError,
    bool clearDob = false,
  }) {
    return SignupFormState(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      dobDay: clearDob ? null : (dobDay ?? this.dobDay),
      dobMonth: clearDob ? null : (dobMonth ?? this.dobMonth),
      dobYear: clearDob ? null : (dobYear ?? this.dobYear),
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      fullNameError: fullNameError,
      emailError: emailError,
      phoneError: phoneError,
      passwordError: passwordError,
      dobError: dobError,
      termsError: termsError,
      generalError: generalError,
    );
  }
}
