/// Post types for different layouts
enum PostType {
  single,   // Single image post
  carousel, // Swipeable multiple images
  grid,     // 2x2 grid layout
  video,    // Video post with progress bar
  spacer,   // Empty spacer for layout alignment
}

class Post {
  final String id;
  final String imageUrl;
  final List<String> images; // For carousel/grid posts
  final List<String> captions; // Individual captions for each carousel image
  final String title;
  final String authorName;
  final String authorAvatar;
  final int likes;
  final int comments;
  final int saves;
  final List<String> tags;
  final String description; // Main caption (used if captions list is empty)
  final double aspectRatio;
  final PostType type;
  final bool isPopular;
  final bool isVideo;
  final Duration? videoDuration;
  final bool isLiked;
  final bool isSaved;

  const Post({
    required this.id,
    required this.imageUrl,
    this.images = const [],
    this.captions = const [],
    required this.title,
    required this.authorName,
    required this.authorAvatar,
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.tags = const [],
    this.description = '',
    this.aspectRatio = 1.0,
    this.type = PostType.single,
    this.isPopular = false,
    this.isVideo = false,
    this.videoDuration,
    this.isLiked = false,
    this.isSaved = false,
  });

  // Helper to get all display images
  List<String> get allImages => images.isEmpty ? [imageUrl] : images;

  // Get caption for specific carousel index (or fallback to main description)
  String getCaptionForIndex(int index) {
    if (captions.isNotEmpty && index < captions.length) {
      return captions[index];
    }
    return description;
  }
}

class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String emoji;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.emoji,
  });
}

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final int followers;
  final int following;
  final int posts;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.coverUrl,
    this.bio = '',
    this.followers = 0,
    this.following = 0,
    this.posts = 0,
  });
}
