import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Reels/Short Videos - Vertical scroll like IG/TikTok
/// With aesthetic filters baked in
class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reels = SampleData.samplePosts; // Using posts as reels for demo

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reels',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) {
          // Video playback control would go here
        },
        itemCount: reels.length,
        itemBuilder: (context, index) {
          final reel = reels[index];
          return _ReelItem(reel: reel);
        },
      ),
    );
  }
}

class _ReelItem extends StatelessWidget {
  final dynamic reel;

  const _ReelItem({required this.reel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video/Image content (using image for demo)
        // Video/Image content (using image for demo)
        Image.asset(
          reel.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.black,
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.white),
            ),
          ),
        ),

        // Aesthetic color grading overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColors.dustyRose.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.4),
              ],
            ),
          ),
        ),

        // Right side action buttons
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _ActionButton(
                icon: Icons.favorite_border,
                label: '${reel.likes}',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '234',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.bookmark_border,
                label: 'Save',
                onTap: () {},
              ),
              const SizedBox(height: 24),
              // Moodboard button (Koala-exclusive)
              _ActionButton(
                icon: Icons.dashboard_customize,
                label: 'Board',
                color: AppColors.dustyRose,
                onTap: () {},
              ),
            ],
          ),
        ),

        // Bottom info
        Positioned(
          bottom: 0,
          left: 0,
          right: 80,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(
                          reel.authorAvatar,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        reel.authorName,
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                        ),
                        child: const Text('Follow'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Caption
                  Text(
                    reel.title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tags
                  if (reel.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: reel.tags
                          .take(3)
                          .map((tag) => Text(
                                '#$tag',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.dustyRose,
                                  fontWeight: FontWeight.w500,
                                ),
                              ))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color?.withValues(alpha: 0.3) ?? Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
