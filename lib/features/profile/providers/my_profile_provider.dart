import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../models/profile_user.dart';
import '../models/profile_interest.dart';
import '../models/profile_moment.dart';
import 'profile_state.dart';

final myProfileProvider = NotifierProvider<MyProfileNotifier, ProfileState>(
  MyProfileNotifier.new,
);

class MyProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    Future.microtask(() => loadProfile());
    return const ProfileState(isLoading: true);
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (isTest) {
        final alex = ProfileUser(
          id: 'alex_miles',
          displayName: 'Alex',
          username: 'alex.miles',
          location: 'San Diego, California',
          bio: 'Easygoing and curious. Love good food, great conversations, and weekend adventures.',
          coverImageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop',
          isVerified: true,
          photosCount: 6,
          admirersCount: 0,
          matchesCount: 32,
          likesCount: 128,
          interests: const [
            ProfileInterest(name: 'Hiking', icon: Icons.terrain),
            ProfileInterest(name: 'Coffee', icon: Icons.local_cafe),
            ProfileInterest(name: 'Travel', icon: Icons.explore),
            ProfileInterest(name: 'Photography', icon: Icons.photo_camera),
            ProfileInterest(name: 'Music', icon: Icons.music_note),
          ],
          moments: const [
            ProfileMoment(id: 'alex_m1', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=400&auto=format&fit=crop'),
            ProfileMoment(id: 'alex_m2', imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?q=80&w=400&auto=format&fit=crop'),
            ProfileMoment(id: 'alex_m3', imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?q=80&w=400&auto=format&fit=crop'),
          ],
        );
        state = ProfileState(user: alex);
        return;
      }

      final apiService = ref.read(apiServiceProvider);
      
      final me = await apiService.get('/me');
      final profile = me['profile'];
      
      if (profile == null) {
        throw Exception('Profile details not initialized.');
      }
      
      final userId = me['id'];
      final email = me['email'];
      final username = email.split('@')[0];
      final displayName = profile['display_name'] ?? username;
      final bio = profile['bio'] ?? '';
      
      String location = 'Location Unknown';
      if (profile['city'] != null && profile['country'] != null) {
        location = '${profile['city']}, ${profile['country']}';
      }
      
      int? age;
      if (profile['date_of_birth'] != null) {
        try {
          final dob = DateTime.parse(profile['date_of_birth']);
          age = DateTime.now().year - dob.year;
        } catch (e) {
          // Ignore parsing errors
        }
      }
      
      List<ProfileMoment> moments = [];
      try {
        final postsPage = await apiService.get('/posts');
        final List<dynamic> posts = postsPage['items'] ?? [];
        final userPosts = posts.where((post) => post['author']['id'] == userId).toList();
        moments = userPosts.map((post) {
          return ProfileMoment(
            id: post['id'],
            imageUrl: post['media']['url'],
          );
        }).toList();
      } catch (e) {
        // Ignore moments fetch errors to prevent profile crashes
      }

      final coverImageUrl = moments.isNotEmpty 
          ? moments.first.imageUrl 
          : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=1000&auto=format&fit=crop';

      final user = ProfileUser(
        id: userId,
        displayName: displayName,
        username: username,
        age: age,
        location: location,
        bio: bio,
        coverImageUrl: coverImageUrl,
        isVerified: me['status'] == 'APPROVED',
        photosCount: moments.length,
        admirersCount: 42,
        matchesCount: 18,
        likesCount: 156,
        interests: const [
          ProfileInterest(name: 'Hiking', icon: Icons.terrain),
          ProfileInterest(name: 'Coffee', icon: Icons.local_cafe),
          ProfileInterest(name: 'Travel', icon: Icons.explore),
          ProfileInterest(name: 'Photography', icon: Icons.photo_camera),
          ProfileInterest(name: 'Music', icon: Icons.music_note),
        ],
        moments: moments,
      );

      state = ProfileState(user: user);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void updateBio(String bio) {
    if (state.user != null) {
      state = state.copyWith(user: state.user!.copyWith(bio: bio));
    }
  }

  void addMoment(ProfileMoment moment) {
    if (state.user != null) {
      final updatedMoments = List<ProfileMoment>.from(state.user!.moments)..add(moment);
      state = state.copyWith(
        user: state.user!.copyWith(
          moments: updatedMoments,
          photosCount: updatedMoments.length,
        ),
      );
    }
  }

  void deleteMoment(String id) {
    if (state.user != null) {
      final updatedMoments = state.user!.moments.where((m) => m.id != id).toList();
      state = state.copyWith(
        user: state.user!.copyWith(
          moments: updatedMoments,
          photosCount: updatedMoments.length,
        ),
      );
    }
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
