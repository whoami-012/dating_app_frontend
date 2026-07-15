class Story {
  final String id;
  final String username;
  final String avatarUrl;
  final bool isCurrentUser;
  final bool hasUnseenStory;
  final bool isOnline;

  const Story({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.isCurrentUser = false,
    this.hasUnseenStory = false,
    this.isOnline = false,
  });

  Story copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    bool? isCurrentUser,
    bool? hasUnseenStory,
    bool? isOnline,
  }) {
    return Story(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      hasUnseenStory: hasUnseenStory ?? this.hasUnseenStory,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
