import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/saved_posts_manager.dart';

/// Vertical Instagram-style post card
class VerticalPostCard extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onCollect;
  final VoidCallback? onTap;
  final bool showHeader; // Toggle for profile view (no header needed)
  final double aspectRatio; // Dynamic aspect ratio for the media
  final BorderRadius? borderRadius; // Optional custom border radius

  const VerticalPostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onCollect,
    this.onTap,
    this.showHeader = true,
    this.aspectRatio = 1.0, // Default to square
    this.borderRadius,
  });

  @override
  State<VerticalPostCard> createState() => _VerticalPostCardState();
}

class _VerticalPostCardState extends State<VerticalPostCard> {
  int _currentImageIndex = 0;
  bool _isLiked = false;
  bool _isSaved = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _isSaved = SavedPostsManager.instance.isSaved(widget.post.id);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          if (widget.showHeader) ...[
            _buildAuthorHeader(),
            const SizedBox(height: 12),
          ],
          
          // Image content (single, carousel, or grid)
          _buildImageContent(),
          
          // Progress/carousel indicator
          if (widget.post.type == PostType.carousel || widget.post.type == PostType.video)
            _buildIndicator(),
          
          const SizedBox(height: 12),
          
          // Action buttons
          _buildActionBar(context),
          
          const SizedBox(height: 12),
          
          const SizedBox(height: 6),
          
          // Caption (just the description, no username)
          if (widget.post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.post.type == PostType.carousel 
                    ? widget.post.getCaptionForIndex(_currentImageIndex)
                    : widget.post.description,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(widget.post.authorAvatar),
          ),
          const SizedBox(width: 12),
          
          // Name and title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: AppTypography.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (widget.post.title.isNotEmpty)
                  Text(
                    widget.post.title,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          
          // Follow button
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            ),
            child: const Text('Follow'),
          ),
          
          // More options (now includes Share)
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {
              _showMoreOptions(context);
            },
            iconSize: 24,
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.darkTextSecondary 
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.ios_share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onShare?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageContent() {
    switch (widget.post.type) {
      case PostType.grid:
        return _buildGridLayout();
      case PostType.carousel:
        return _buildCarouselLayout();
      case PostType.video:
        return _buildVideoLayout();
      case PostType.single:
        return _buildSingleImage();
      case PostType.spacer:
        return const SizedBox();
    }
  }

  Widget _buildSingleImage() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() => _isLiked = true);
        widget.onLike?.call();
      },
      onTap: widget.onTap,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                child: Image.asset(
                  widget.post.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Popular badge
          if (widget.post.isPopular)
            Positioned(
              top: 12,
              left: 28,
              child: _buildPopularBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildGridLayout() {
    final images = widget.post.allImages.take(4).toList();
    
    return GestureDetector(
      onDoubleTap: () {
        setState(() => _isLiked = true);
        widget.onLike?.call();
      },
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            
            // Grid indicator icon
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            
            // Popular badge
            if (widget.post.isPopular)
              Positioned(
                top: 12,
                left: 12,
                child: _buildPopularBadge(),
              ),
            
            // Heart overlay
            Positioned(
              top: 12,
              right: 12,
              child: _buildHeartOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselLayout() {
    final images = widget.post.allImages;
    
    return GestureDetector(
      onDoubleTap: () {
        setState(() => _isLiked = true);
        widget.onLike?.call();
      },
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Carousel indicator icon
          Positioned(
            top: 12,
            right: 28,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.layers_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          
          // Popular badge
          if (widget.post.isPopular)
            Positioned(
              top: 12,
              left: 28,
              child: _buildPopularBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoLayout() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() => _isLiked = true);
        widget.onLike?.call();
      },
      onTap: widget.onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      widget.post.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    
                    // Play button overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Duration badge
          if (widget.post.videoDuration != null)
            Positioned(
              bottom: 12,
              right: 28,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _formatDuration(widget.post.videoDuration!),
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicator() {
    if (widget.post.type == PostType.video) {
      // Video progress bar
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: 0.0, // Would be controlled by video controller
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandAccent),
          ),
        ),
      );
    } else if (widget.post.type == PostType.carousel) {
      // Carousel dots
      final images = widget.post.allImages;
      return Container(
        margin: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(images.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentImageIndex == index ? 8 : 6,
              height: _currentImageIndex == index ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentImageIndex == index
                    ? AppColors.brandAccent
                    : AppColors.divider,
              ),
            );
          }),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildActionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48), // Increased padding to keep buttons from edges
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push buttons apart
        children: [
          // Comment button with count
          _ActionButton(
            icon: CupertinoIcons.chat_bubble,
            label: _formatCount(widget.post.comments),
            onTap: widget.onComment,
          ),
          
          // Like button with count
          _ActionButton(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            color: _isLiked ? AppColors.dustyRose : null,
            label: _formatCount(widget.post.likes + (_isLiked ? 1 : 0)),
            onTap: () {
              setState(() => _isLiked = !_isLiked);
              widget.onLike?.call();
            },
          ),
          
          // Collect/Save button (no count requested)
          _ActionButton(
            icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved ? AppColors.brandAccent : null,
            onTap: () {
              final nowSaved = SavedPostsManager.instance.toggle(widget.post);
              setState(() => _isSaved = nowSaved);
              widget.onCollect?.call();
              // Show feedback
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(nowSaved ? 'Post saved ✨' : 'Post unsaved'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.brandAccent,
                  margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'Popular',
        style: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeartOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() => _isLiked = !_isLiked);
        widget.onLike?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? AppColors.dustyRose : AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String? label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    this.color,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
          if (label != null) ...[
            const SizedBox(width: 6),
            Text(
              label!,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
