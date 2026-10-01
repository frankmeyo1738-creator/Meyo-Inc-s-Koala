/// Story/Highlight model for Instagram-style stories
class Story {
  final String id;
  final String imageUrl;
  final String? overlayImageUrl; // Product overlay (like t-shirt)
  final String timeAgo;
  final bool isViewed;
  final String? backgroundColor; // Hex color for card background

  const Story({
    required this.id,
    required this.imageUrl,
    this.overlayImageUrl,
    required this.timeAgo,
    this.isViewed = false,
    this.backgroundColor,
  });
}
