import 'profile_interest.dart';
import 'profile_moment.dart';

class ProfileUser {
  final String id;
  final String displayName;
  final String username;
  final int? age;
  final String? location;
  final String bio;
  final String coverImageUrl;
  final bool isVerified;
  final int photosCount;
  final int admirersCount;
  final int matchesCount;
  final int likesCount;
  final List<ProfileInterest> interests;
  final List<ProfileMoment> moments;
  final bool isLiked;
  final String connectionState; // 'connect', 'request_sent', 'connected', 'loading', 'disabled'

  const ProfileUser({
    required this.id,
    required this.displayName,
    required this.username,
    this.age,
    this.location,
    required this.bio,
    required this.coverImageUrl,
    required this.isVerified,
    required this.photosCount,
    required this.admirersCount,
    required this.matchesCount,
    required this.likesCount,
    required this.interests,
    required this.moments,
    this.isLiked = false,
    this.connectionState = 'connect',
  });

  ProfileUser copyWith({
    String? id,
    String? displayName,
    String? username,
    int? age,
    String? location,
    String? bio,
    String? coverImageUrl,
    bool? isVerified,
    int? photosCount,
    int? admirersCount,
    int? matchesCount,
    int? likesCount,
    List<ProfileInterest>? interests,
    List<ProfileMoment>? moments,
    bool? isLiked,
    String? connectionState,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      age: age ?? this.age,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      isVerified: isVerified ?? this.isVerified,
      photosCount: photosCount ?? this.photosCount,
      admirersCount: admirersCount ?? this.admirersCount,
      matchesCount: matchesCount ?? this.matchesCount,
      likesCount: likesCount ?? this.likesCount,
      interests: interests ?? this.interests,
      moments: moments ?? this.moments,
      isLiked: isLiked ?? this.isLiked,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}
