import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_user.dart';
import '../models/profile_interest.dart';
import '../models/profile_moment.dart';
import 'profile_state.dart';

final viewedProfileProvider = NotifierProvider<ViewedProfileNotifier, ProfileState>(
  ViewedProfileNotifier.new,
);

class ViewedProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future.microtask(() => loadProfile('arjun_28'));
    return const ProfileState(isLoading: true);
  }

  Future<void> loadProfile(String id) async {
    state = state.copyWith(isLoading: true, isError: false, isBlocked: false, isPrivate: false);
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      if (id == 'blocked_user') {
        state = const ProfileState(isBlocked: true);
        return;
      }
      if (id == 'private_user') {
        state = ProfileState(
          isPrivate: true,
          user: ProfileUser(
            id: 'private_user',
            displayName: 'Private User',
            username: 'private.user',
            bio: 'This profile is private.',
            coverImageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop',
            isVerified: false,
            photosCount: 0,
            admirersCount: 0,
            matchesCount: 0,
            likesCount: 0,
            interests: [],
            moments: [],
          ),
        );
        return;
      }
      if (id == 'error_user') {
        throw Exception('User not found');
      }

      // Default Arjun
      final arjun = ProfileUser(
        id: 'arjun_28',
        displayName: 'Arjun',
        username: 'arjun.28',
        age: 28,
        location: 'San Francisco, CA',
        bio: 'Product designer who loves exploring new cafés, weekend hikes, and live music.',
        coverImageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1000&auto=format&fit=crop',
        isVerified: true,
        photosCount: 6,
        admirersCount: 143,
        matchesCount: 0,
        likesCount: 0,
        interests: const [
          ProfileInterest(name: 'Hiking', icon: Icons.terrain),
          ProfileInterest(name: 'Coffee', icon: Icons.local_cafe),
          ProfileInterest(name: 'Travel', icon: Icons.explore),
          ProfileInterest(name: 'Photography', icon: Icons.photo_camera),
          ProfileInterest(name: 'Indie Music', icon: Icons.music_note),
        ],
        moments: const [
          ProfileMoment(id: 'arjun_m1', imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=400&auto=format&fit=crop'),
          ProfileMoment(id: 'arjun_m2', imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=400&auto=format&fit=crop'),
          ProfileMoment(id: 'arjun_m3', imageUrl: 'https://images.unsplash.com/photo-1489980508314-941910ded1f4?q=80&w=400&auto=format&fit=crop'),
          ProfileMoment(id: 'arjun_m4', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop'),
        ],
        isLiked: false,
        connectionState: 'connect',
      );

      state = ProfileState(user: arjun);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'Failed to load profile. Tap to retry.',
      );
    }
  }

  void toggleLike() {
    if (state.user != null) {
      final isLiked = !state.user!.isLiked;
      state = state.copyWith(
        user: state.user!.copyWith(isLiked: isLiked),
      );
    }
  }

  Future<void> connect() async {
    if (state.user != null) {
      final currentState = state.user!.connectionState;
      if (currentState == 'connect') {
        state = state.copyWith(user: state.user!.copyWith(connectionState: 'loading'));
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(user: state.user!.copyWith(connectionState: 'request_sent'));
      } else if (currentState == 'request_sent') {
        state = state.copyWith(user: state.user!.copyWith(connectionState: 'loading'));
        await Future.delayed(const Duration(milliseconds: 600));
        state = state.copyWith(user: state.user!.copyWith(connectionState: 'connect'));
      }
    }
  }

  void blockUser() {
    state = const ProfileState(isBlocked: true);
  }

  void unblockUser() {
    loadProfile('arjun_28');
  }

  void triggerErrorState() {
    state = state.copyWith(
      isLoading: false,
      isError: true,
      errorMessage: 'Network error occurred. Tap to retry.',
    );
  }

  void triggerEmptyState() {
    if (state.user != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          interests: [],
          moments: [],
          photosCount: 0,
        ),
      );
    }
  }
}
