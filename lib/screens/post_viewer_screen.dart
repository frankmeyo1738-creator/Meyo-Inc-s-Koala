import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/post.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/sample_data.dart';

class PostViewerScreen extends StatefulWidget {
  final Post post;
  final double tileAspectRatio; // Aspect ratio from the tile in discover grid

  const PostViewerScreen({
    Key? key,
    required this.post,
    this.tileAspectRatio = 1.0, // Default to square
  }) : super(key: key);

  @override
  State<PostViewerScreen> createState() => _PostViewerScreenState();
}

class _PostViewerScreenState extends State<PostViewerScreen> {
  // Dynamic Layout state for "More to Discover"
  List<Post> _displayPosts = [];
  List<StaggeredGridTile> _tiles = [];

  @override
  void initState() {
    super.initState();
    _generateLayout();
  }

  /// Generates the same block-based layout as discover tab for "More to Discover"
  void _generateLayout() {
    // Get posts excluding current one
    final sample = SampleData.samplePosts.where((p) => p.id != widget.post.id).toList();
    final pool = [...sample, ...sample];
    pool.shuffle();

    // Block Types (same as discover tab)
    final blockBigLeft = [
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
    ];

    final blockBigRight = [
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
    ];

    final blockRow = [
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
      const StaggeredGridTile.count(crossAxisCellCount: 1, mainAxisCellCount: 1, child: SizedBox()),
    ];

    final blockFull = [
      const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()),
    ];

    List<Post> generatedPosts = [];
    List<StaggeredGridTile> generatedTiles = [];

    int poolIndex = 0;
    List<int> colStacks = [0, 0, 0];

    bool isValid(List<int> currentStacks, String type) {
      if (type == 'Left') {
        return (currentStacks[2] + 2) <= 3;
      } else if (type == 'Right') {
        return (currentStacks[0] + 2) <= 3;
      } else if (type == 'Row') {
        return (currentStacks[0] + 1) <= 3 &&
            (currentStacks[1] + 1) <= 3 &&
            (currentStacks[2] + 1) <= 3;
      } else {
        return true;
      }
    }

    void updateStacks(String type) {
      if (type == 'Left') {
        colStacks[0] = 0;
        colStacks[1] = 0;
        colStacks[2] += 2;
      } else if (type == 'Right') {
        colStacks[0] += 2;
        colStacks[1] = 0;
        colStacks[2] = 0;
      } else if (type == 'Row') {
        colStacks[0] += 1;
        colStacks[1] += 1;
        colStacks[2] += 1;
      } else {
        colStacks = [0, 0, 0];
      }
    }

    // Limit to ~15 posts for "More to Discover"
    while (poolIndex < pool.length && generatedPosts.length < 15) {
      final candidates = [
        {'type': 'Left', 'block': blockBigLeft},
        {'type': 'Right', 'block': blockBigRight},
        {'type': 'Row', 'block': blockRow},
        {'type': 'Full', 'block': blockFull},
        {'type': 'Left', 'block': blockBigLeft},
        {'type': 'Right', 'block': blockBigRight},
      ];

      candidates.shuffle();

      bool added = false;
      for (var candidate in candidates) {
        final type = candidate['type'] as String;
        final block = candidate['block'] as List<StaggeredGridTile>;

        if (isValid(colStacks, type) && (poolIndex + block.length <= pool.length)) {
          for (var tile in block) {
            generatedTiles.add(tile);
            generatedPosts.add(pool[poolIndex]);
            poolIndex++;
          }
          updateStacks(type);
          added = true;
          break;
        }
      }

      if (!added) break;
    }

    setState(() {
      _displayPosts = generatedPosts;
      _tiles = generatedTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(CupertinoIcons.chevron_back, color: textColor, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                  ],
                ),
              ),

              // Post Image with Author Overlay
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Main Image preserving tile aspect ratio
                      AspectRatio(
                        aspectRatio: widget.tileAspectRatio,
                        child: Image.asset(
                          post.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                      ),

                      // Gradient overlay at bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Author Info Overlay (bottom-left)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage(post.authorAvatar),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              post.authorName,
                              style: AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Icons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Left side actions
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(CupertinoIcons.heart, color: textColor, size: 26),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(CupertinoIcons.chat_bubble, color: textColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(CupertinoIcons.square_arrow_up, color: textColor, size: 24),
                    ),
                    const Spacer(),
                    // Right side - Bookmark
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(CupertinoIcons.bookmark, color: textColor, size: 24),
                    ),
                  ],
                ),
              ),

              // Caption & Comments
              if (post.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    post.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  'View all ${post.comments} comments',
                  style: AppTypography.bodySmall.copyWith(
                    color: textSecondary,
                  ),
                ),
              ),

              // More to Discover Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'More to discover',
                  style: AppTypography.h4.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Discover-style Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StaggeredGrid.count(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: List.generate(_displayPosts.length, (index) {
                    final p = _displayPosts[index];
                    final tile = _tiles[index];
                    final isBig = tile.mainAxisCellCount! > 1;

                    return StaggeredGridTile.count(
                      crossAxisCellCount: tile.crossAxisCellCount!,
                      mainAxisCellCount: tile.mainAxisCellCount!,
                      child: GestureDetector(
                        onTap: () {
                          final tileAspectRatio = tile.crossAxisCellCount! / tile.mainAxisCellCount!;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostViewerScreen(
                                post: p,
                                tileAspectRatio: tileAspectRatio,
                              ),
                            ),
                          );
                        },
                        child: _buildTileItem(p, isBig),
                      ),
                    );
                  }),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileItem(Post post, bool isBig) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.darkCardBackground,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.asset(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.darkCardBackground,
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Video Icon
            if (post.isVideo)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),

            // User Avatar only - cleaner look
            Positioned(
              bottom: isBig ? 12 : 6,
              left: isBig ? 12 : 6,
              child: CircleAvatar(
                radius: isBig ? 12 : 10,
                backgroundImage: AssetImage(post.authorAvatar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
