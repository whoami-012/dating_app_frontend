import '../models/profile_user.dart';

class ProfileState {
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final ProfileUser? user;
  final bool isPrivate;
  final bool isBlocked;

  const ProfileState({
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.user,
    this.isPrivate = false,
    this.isBlocked = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isError,
    String? errorMessage,
    ProfileUser? user,
    bool? isPrivate,
    bool? isBlocked,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      isPrivate: isPrivate ?? this.isPrivate,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
