class FeedPost {
  final String id;
  final String author;
  final String authorAvatarUrl;
  final String mediaUrl;
  final String? videoUrl;
  final bool isVideo;
  final bool isLive;
  final String viewerCount; // e.g. "29.3K"
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int bookmarkCount;
  final String caption;
  final bool isLiked;
  final bool isBookmarked;
  final double? mediaAlignmentX;
  final double? mediaAlignmentY;

  const FeedPost({
    required this.id,
    required this.author,
    required this.authorAvatarUrl,
    required this.mediaUrl,
    this.videoUrl,
    this.isVideo = false,
    required this.isLive,
    required this.viewerCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.bookmarkCount,
    required this.caption,
    this.isLiked = false,
    this.isBookmarked = false,
    this.mediaAlignmentX,
    this.mediaAlignmentY,
  });

  FeedPost copyWith({
    String? id,
    String? author,
    String? authorAvatarUrl,
    String? mediaUrl,
    String? videoUrl,
    bool? isVideo,
    bool? isLive,
    String? viewerCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? bookmarkCount,
    String? caption,
    bool? isLiked,
    bool? isBookmarked,
    double? mediaAlignmentX,
    double? mediaAlignmentY,
  }) {
    return FeedPost(
      id: id ?? this.id,
      author: author ?? this.author,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      isVideo: isVideo ?? this.isVideo,
      isLive: isLive ?? this.isLive,
      viewerCount: viewerCount ?? this.viewerCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      caption: caption ?? this.caption,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      mediaAlignmentX: mediaAlignmentX ?? this.mediaAlignmentX,
      mediaAlignmentY: mediaAlignmentY ?? this.mediaAlignmentY,
    );
  }
}
