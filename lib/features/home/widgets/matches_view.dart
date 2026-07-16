import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/matches_provider.dart';
import '../../profile/screens/other_user_profile_screen.dart';

class MatchesView extends ConsumerWidget {
  const MatchesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchesProvider);
    final notifier = ref.read(matchesProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText = isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText = isDark ? AppColors.darkSecondaryText : AppColors.lightSecondaryText;
    final backgroundColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F6F8);
    final cardColor = isDark ? const Color(0xFF141414) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.06);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matches',
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (!state.isLoading && !state.isError)
                    IconButton(
                      icon: Icon(Icons.refresh, color: AppColors.neonLime),
                      onPressed: () => notifier.refresh(),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Content Area
              Expanded(
                child: _buildContent(
                  context,
                  state,
                  notifier,
                  primaryText,
                  secondaryText,
                  cardColor,
                  borderColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    MatchesState state,
    MatchesNotifier notifier,
    Color primaryText,
    Color secondaryText,
    Color cardColor,
    Color borderColor,
  ) {
    if (state.isLoading) {
      return _buildSkeletonLoader(cardColor, borderColor);
    }

    if (state.isError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load matches',
                textAlign: TextAlign.center,
                style: AppTypography.getCaption(secondaryText).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => notifier.loadMatches(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                color: secondaryText.withOpacity(0.5),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'No matches yet',
                style: TextStyle(
                  color: primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep exploring and liking creators to find a mutual match!',
                textAlign: TextAlign.center,
                style: AppTypography.getCaption(secondaryText).copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.neonLime,
      backgroundColor: cardColor,
      onRefresh: () => notifier.refresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 120),
        itemCount: state.matches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final match = state.matches[index];
          return _buildMatchItem(context, match, primaryText, secondaryText, cardColor, borderColor);
        },
      ),
    );
  }

  Widget _buildMatchItem(
    BuildContext context,
    MatchUser match,
    Color primaryText,
    Color secondaryText,
    Color cardColor,
    Color borderColor,
  ) {
    final timeString = _getFormattedTime(match.matchedAt);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtherUserProfileScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  // Avatar Stack
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: match.isOnline ? AppColors.neonLime : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: secondaryText.withOpacity(0.1),
                          backgroundImage: match.avatarUrl.isNotEmpty
                              ? NetworkImage(match.avatarUrl)
                              : null,
                          child: match.avatarUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: secondaryText.withOpacity(0.5),
                                  size: 30,
                                )
                              : null,
                        ),
                      ),
                      if (match.isOnline)
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.neonLime,
                              shape: BoxShape.circle,
                              border: Border.all(color: cardColor, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                match.displayName,
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (match.isVerified) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified,
                                color: Colors.blueAccent,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${match.username}',
                          style: TextStyle(
                            color: secondaryText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Matched $timeString',
                          style: TextStyle(
                            color: secondaryText.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat Button Action
          IconButton(
            icon: Icon(
              match.conversationId != null ? Icons.chat_bubble : Icons.chat_bubble_outline,
              color: match.conversationId != null ? AppColors.neonLime : secondaryText,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    match.conversationId != null
                        ? 'Opening chat with ${match.displayName}...'
                        : 'Starting a new conversation...',
                    style: const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: AppColors.neonLime,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(Color cardColor, Color borderColor) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              // Avatar skeleton
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              // Details skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFormattedTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
