import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchUser {
  final String id;
  final String displayName;
  final String username;
  final String avatarUrl;
  final bool isVerified;
  final bool isOnline;
  final DateTime matchedAt;
  final String? conversationId;

  const MatchUser({
    required this.id,
    required this.displayName,
    required this.username,
    required this.avatarUrl,
    required this.isVerified,
    required this.isOnline,
    required this.matchedAt,
    this.conversationId,
  });
}

class MatchesState {
  final List<MatchUser> matches;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const MatchesState({
    required this.matches,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  MatchesState copyWith({
    List<MatchUser>? matches,
    bool? isLoading,
    bool? isError,
    String? errorMessage,
  }) {
    return MatchesState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final matchesProvider = NotifierProvider<MatchesNotifier, MatchesState>(
  MatchesNotifier.new,
);

class MatchesNotifier extends Notifier<MatchesState> {
  @override
  MatchesState build() {
    // Initial load
    Future.microtask(() => loadMatches());
    return const MatchesState(matches: [], isLoading: true);
  }

  final List<MatchUser> _sampleMatches = [
    MatchUser(
      id: 'match_sarah',
      displayName: 'Sarah Chen',
      username: 'sarah_c',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
      isVerified: true,
      isOnline: true,
      matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
      conversationId: 'conv_sarah',
    ),
    MatchUser(
      id: 'match_emma',
      displayName: 'Emma Watson',
      username: 'emma_w',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      isVerified: true,
      isOnline: false,
      matchedAt: DateTime.now().subtract(const Duration(days: 1)),
      conversationId: null,
    ),
    MatchUser(
      id: 'match_david',
      displayName: 'David Kim',
      username: 'david_k',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      isVerified: false,
      isOnline: true,
      matchedAt: DateTime.now().subtract(const Duration(days: 3)),
      conversationId: 'conv_david',
    ),
  ];

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      await Future.delayed(const Duration(milliseconds: 1500));
      state = MatchesState(matches: _sampleMatches, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'Failed to load matches. Please try again.',
      );
    }
  }

  Future<void> refresh() async {
    await loadMatches();
  }

  void simulateError() {
    state = const MatchesState(
      matches: [],
      isLoading: false,
      isError: true,
      errorMessage: 'Simulated connection error. Please try again.',
    );
  }

  void simulateEmpty() {
    state = const MatchesState(matches: [], isLoading: false, isError: false);
  }
}
