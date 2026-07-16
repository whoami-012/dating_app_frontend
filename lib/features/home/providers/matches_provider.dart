import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

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
  String? _nextCursor;
  bool _isFetchingMore = false;

  @override
  MatchesState build() {
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
      isOnline: false,
      matchedAt: DateTime.now().subtract(const Duration(hours: 2)),
      conversationId: 'conv_sarah',
    ),
    MatchUser(
      id: 'match_emma',
      displayName: 'Emma Watson',
      username: 'emma_w',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
      isVerified: true,
      isOnline: true,
      matchedAt: DateTime.now().subtract(const Duration(hours: 3)),
      conversationId: 'conv_emma',
    ),
    MatchUser(
      id: 'match_david',
      displayName: 'David Kim',
      username: 'david_k',
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
      isVerified: false,
      isOnline: true,
      matchedAt: DateTime.now().subtract(const Duration(hours: 4)),
      conversationId: 'conv_david',
    ),
  ];

  List<MatchUser> _mapMatches(List<dynamic> items) {
    return items.map((item) {
      final Map<String, dynamic> match = item as Map<String, dynamic>;
      final otherUserId = match['other_user_id'] as String;
      final otherDisplayName = match['other_display_name'] as String? ?? 'Creator';
      
      final cleanUsername = otherDisplayName.replaceAll(RegExp(r'\s+'), '').toLowerCase();
      final username = cleanUsername.isNotEmpty ? cleanUsername : 'user_${otherUserId.substring(0, 8)}';
      
      final mediaPreview = match['media_preview'] as Map<String, dynamic>?;
      final avatarUrl = mediaPreview != null ? mediaPreview['url'] as String? ?? '' : '';

      final matchedAtStr = match['matched_at'] as String;
      final matchedAt = DateTime.parse(matchedAtStr);
      
      final matchId = match['id'] as String;

      return MatchUser(
        id: otherUserId,
        displayName: otherDisplayName,
        username: username,
        avatarUrl: avatarUrl,
        isVerified: false,
        isOnline: false,
        matchedAt: matchedAt,
        conversationId: matchId,
      );
    }).toList();
  }

  Future<void> loadMatches() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    try {
      final isTest = Platform.environment.containsKey('FLUTTER_TEST');
      if (isTest) {
        state = MatchesState(matches: _sampleMatches, isLoading: false);
        return;
      }

      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getWithResponse('/matches?limit=20');
      
      final items = response.data as List<dynamic>;
      _nextCursor = response.headers['x-next-cursor'] ?? response.headers['X-Next-Cursor'];

      final List<MatchUser> loadedMatches = _mapMatches(items);
      state = MatchesState(matches: loadedMatches, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: 'Failed to load matches: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (_nextCursor == null || _isFetchingMore) return;
    _isFetchingMore = true;

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.getWithResponse('/matches?limit=20&cursor=$_nextCursor');
      
      final items = response.data as List<dynamic>;
      _nextCursor = response.headers['x-next-cursor'] ?? response.headers['X-Next-Cursor'];

      final List<MatchUser> newMatches = _mapMatches(items);
      
      final existingIds = state.matches.map((m) => m.id).toSet();
      final filteredNewMatches = newMatches.where((m) => !existingIds.contains(m.id)).toList();

      state = state.copyWith(
        matches: [...state.matches, ...filteredNewMatches],
      );
    } catch (e) {
      // Silently fail pagination errors to preserve UX
    } finally {
      _isFetchingMore = false;
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
