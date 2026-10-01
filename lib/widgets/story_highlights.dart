import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/story.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Instagram-style story highlights with scroll-to-fade effect
/// 
/// When [scrollOffset] increases, the highlights fade and blur into the background
class StoryHighlights extends StatelessWidget {
  final List<Story> stories;
  final double scrollOffset;
  final double fadeStartOffset;
  final double fadeEndOffset;
  final ScrollController? scrollController;

  const StoryHighlights({
    super.key,
    required this.stories,
    required this.scrollOffset,
    this.fadeStartOffset = 0,
    this.fadeEndOffset = 150,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate fade progress (0 = fully visible, 1 = fully faded)
    final fadeProgress = ((scrollOffset - fadeStartOffset) / (fadeEndOffset - fadeStartOffset))
        .clamp(0.0, 1.0);
    
    // Opacity decreases as we scroll
    final opacity = 1.0 - fadeProgress;
    
    // Blur increases as we scroll (0 to 10)
    final blurAmount = fadeProgress * 10.0;
    
    // Scale down slightly as we scroll (1.0 to 0.95)
    final scale = 1.0 - (fadeProgress * 0.05);
    
    // Translate up as we scroll
    final translateY = -fadeProgress * 30.0;

    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 50),
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurAmount,
                sigmaY: blurAmount,
              ),
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: stories.length,
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : 8,
                        right: index == stories.length - 1 ? 0 : 0,
                      ),
                      child: _StoryCard(story: story),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual story card with rounded rectangle design
class _StoryCard extends StatelessWidget {
  final Story story;

  const _StoryCard({required this.story});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        // TODO: Open story viewer
      },
      child: Container(
        width: 130,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              Image.asset(
                story.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: isDark ? AppColors.darkTextTertiary : Colors.grey,
                  ),
                ),
              ),
              
              // Gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              
              // Time indicator
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    story.timeAgo,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              
              // Viewed indicator (dimmed overlay)
              if (story.isViewed)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget to be used with scroll controllers
/// Listens to scroll and updates the highlights accordingly
class ScrollableStoryHighlights extends StatefulWidget {
  final List<Story> stories;
  final ScrollController scrollController;
  final double fadeStartOffset;
  final double fadeEndOffset;

  const ScrollableStoryHighlights({
    super.key,
    required this.stories,
    required this.scrollController,
    this.fadeStartOffset = 0,
    this.fadeEndOffset = 150,
  });

  @override
  State<ScrollableStoryHighlights> createState() => _ScrollableStoryHighlightsState();
}

class _ScrollableStoryHighlightsState extends State<ScrollableStoryHighlights> {
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = widget.scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoryHighlights(
      stories: widget.stories,
      scrollOffset: _scrollOffset,
      fadeStartOffset: widget.fadeStartOffset,
      fadeEndOffset: widget.fadeEndOffset,
    );
  }
}
