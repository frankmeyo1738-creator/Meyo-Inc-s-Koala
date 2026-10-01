import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/post.dart';
import '../data/sample_data.dart';
import '../data/saved_branches_manager.dart';
import 'post_viewer_screen.dart';
import 'profile_feed_screen.dart';
import 'dart:math';

// Position of tile in the grid row (for dynamic corner styling)
enum TilePosition {
  left,    // Sharp top-right corner
  right,   // Sharp top-left corner
  middle,  // Sharp top-right AND bottom-left corners (full width)
}

class LeafUser {
  final String id;
  final String name;
  final String niche;
  final String avatar;
  final List<Post> posts;
  final List<StaggeredGridTile> layoutTiles;
  final List<TilePosition> tilePositions; // New: Position of each tile

  LeafUser({
    required this.id,
    required this.name,
    required this.niche,
    required this.avatar,
    required this.posts,
    required this.layoutTiles,
    required this.tilePositions,
  });
}

class LeavesScreen extends StatefulWidget {
  const LeavesScreen({Key? key}) : super(key: key);

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  List<LeafUser> _users = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateMockUsers();
  }

  Future<void> _onRefresh() async {
    // Artificial delay to mimic network fetch
    await Future.delayed(const Duration(milliseconds: 1000));
    _generateMockUsers();
  }

  void _generateMockUsers() {
    final sourcePosts = SampleData.samplePosts;
    
    // Helper to generate a random layout
    (List<Post>, List<StaggeredGridTile>, List<TilePosition>) generateUserLayout(String seedName) {
      // 1. Determine "Branch" size: 1 to 5 leaves (reduced max from 10)
      final branchSize = _random.nextBool() ? 1 : (_random.nextInt(5) + 2); // 50% chance of single leaf, else 2-6
      
      // 2. Prepare pool
      final userPosts = List<Post>.from(sourcePosts)..shuffle(_random);
      while (userPosts.length < branchSize) {
        userPosts.addAll(List.from(sourcePosts)..shuffle(_random));
      }
      
      List<Post> selectedPosts = [];
      List<StaggeredGridTile> tiles = [];
      List<TilePosition> positions = []; // Track positions
      int postIndex = 0;
      
      // --- Slab Definitions (Must fill 6 cols width) ---
      
      // A. Full Width Landscape (6x3) -> 1 post
      bool addFullWidthLandscapeSlab() {
        if (postIndex + 1 <= userPosts.length && postIndex + 1 <= branchSize) {
          tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 6, mainAxisCellCount: 3, child: SizedBox()));
          positions.add(TilePosition.middle); // Full width = middle
          selectedPosts.add(userPosts[postIndex++]);
          return true;
        }
        return false;
      }

      // NEW: Big Square Slab (6x6 Full Width) -> 1 post (No gaps)
      bool addBigSquareSlab() {
        if (postIndex + 1 <= userPosts.length && postIndex + 1 <= branchSize) {
          // Full width square (6x6)
          tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 6, mainAxisCellCount: 6, child: SizedBox()));
          positions.add(TilePosition.middle); // Full width = middle
          selectedPosts.add(userPosts[postIndex++]);
          return true;
        }
        return false;
      }

      // B. Big Left Slab (4x4 on left, two 2x2s on right) -> 3 posts
      bool addBigLeftSlab() {
         if (postIndex + 3 <= userPosts.length) {
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 4, mainAxisCellCount: 4, child: SizedBox())); // (2,0)
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox())); // (4,0) right top
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox())); // (4,2) right bottom
           selectedPosts.add(userPosts[postIndex++]);
           return true;
         }
         return false;
      }

      // C. Big Right Slab (two 2x2s on left, 4x4 on right) -> 3 posts
      bool addBigRightSlab() {
        if (postIndex + 3 <= userPosts.length) {
          // To ensure gap-free packing:
          // 1. Add top-left 2x2
          tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox())); // (0,0)
          selectedPosts.add(userPosts[postIndex++]);
          // 2. Add big 4x4 (fits in cols 2-5)
          tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 4, mainAxisCellCount: 4, child: SizedBox())); // (2,0)
          selectedPosts.add(userPosts[postIndex++]);
          // 3. Add bottom-left 2x2
          tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox())); // (0,2)
          selectedPosts.add(userPosts[postIndex++]);
          return true;
        }
        return false;
      }

      // D. Horizontal Pair (Two 3x2s) -> 2 posts
      bool addHorizontalPairSlab() {
        if (postIndex + 2 <= userPosts.length && postIndex + 2 <= branchSize) {
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
           positions.add(TilePosition.left);
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
           positions.add(TilePosition.right);
           selectedPosts.add(userPosts[postIndex++]);
           return true;
        }
        return false;
      }

      // E. Standard Row (Three 2x2s) -> 3 posts
      bool addRowSlab() {
        if (postIndex + 3 <= userPosts.length) {
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()));
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()));
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()));
           selectedPosts.add(userPosts[postIndex++]);
           return true;
        }
        return false;
      }

      // F. Vertical Pair (Two 3x4s) -> 2 posts
      bool addVerticalPairSlab() {
        if (postIndex + 2 <= userPosts.length && postIndex + 2 <= branchSize) {
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()));
           positions.add(TilePosition.left);
           selectedPosts.add(userPosts[postIndex++]);
           tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()));
           positions.add(TilePosition.right);
           selectedPosts.add(userPosts[postIndex++]);
           return true;
        }
        return false;
      }

      // G. Mixed Vertical Slab (One 3x4 + Two 3x2s) -> 3 posts
      bool addVerticalMixedSlab() {
        if (postIndex + 3 <= userPosts.length && postIndex + 3 <= branchSize) {
           // Randomize: Left big vs Right big
           bool leftBig = _random.nextBool();
           
           if (leftBig) {
             // 3x4 on Left
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()));
             positions.add(TilePosition.left);
             selectedPosts.add(userPosts[postIndex++]);
             // Two 3x2s on Right (stacked vertically)
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
             positions.add(TilePosition.right);
             selectedPosts.add(userPosts[postIndex++]);
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
             positions.add(TilePosition.right);
             selectedPosts.add(userPosts[postIndex++]);
           } else {
             // Two 3x2s on Left (stacked), 3x4 on Right
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
             positions.add(TilePosition.left);
             selectedPosts.add(userPosts[postIndex++]);
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()));
             positions.add(TilePosition.right);
             selectedPosts.add(userPosts[postIndex++]);
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 2, child: SizedBox()));
             positions.add(TilePosition.left);
             selectedPosts.add(userPosts[postIndex++]);
           }
           return true;
        }
        return false;
      }

      // --- Loop with Smart Fallback ---
      
      if (branchSize == 1) {
        // Strict restriction for single leaf: Only 4x4 Square or 6x3 Landscape
         if (_random.nextBool()) {
           addBigSquareSlab();
         } else {
           addFullWidthLandscapeSlab();
         }
      } else {
        // Multi-post logic
        final moves = [
          addFullWidthLandscapeSlab,
          addHorizontalPairSlab,
          addVerticalPairSlab,
          addVerticalMixedSlab,
        ];

        while (postIndex < branchSize) {
          moves.shuffle(_random);
          bool moveMade = false;
          
          // Try random moves
          for (final move in moves) {
            if (move()) {
              moveMade = true;
              break;
            }
          }
          
          if (!moveMade && postIndex < branchSize) {
             // Fallback: Fill with Full Width if stuck
             tiles.add(const StaggeredGridTile.count(crossAxisCellCount: 6, mainAxisCellCount: 3, child: SizedBox()));
             positions.add(TilePosition.middle);
             selectedPosts.add(userPosts[postIndex++]);
          }
        }
      }

      // Ensure exact fit - NO TRUNCATION NEEDED IF WE CHECK LIMITS
      // if (selectedPosts.length > branchSize) {
      //   selectedPosts.removeRange(branchSize, selectedPosts.length);
      //   tiles.removeRange(branchSize, tiles.length);
      // }

      return (selectedPosts, tiles, positions);
    }

    final usersData = [
      {'name': 'Guy Hawkins',    'avatar': 'assets/images/kendrick_lamar.jpg',   'niche': 'Studio Day'},
      {'name': 'Esther Howard',  'avatar': 'assets/images/amandla_premiere.jpg', 'niche': 'Nature Vibes'},
      {'name': 'Robert Fox',     'avatar': 'assets/images/makeup_dup.jpg',       'niche': 'Wildlife & Co'},
      {'name': 'Jane Cooper',    'avatar': 'assets/images/ayra_starr-2.jpg',     'niche': 'Aesthetic Life'},
    ];

    List<LeafUser> newUsers = [];
    final shuffledUsers = List.from(usersData)..shuffle(_random);
    
    for (var u in shuffledUsers) {
      final layout = generateUserLayout(u['name']!);
      newUsers.add(LeafUser(
        id: u['name']!,
        name: u['name']!,
        niche: u['niche']!,
        avatar: u['avatar']!,
        posts: layout.$1,
        layoutTiles: layout.$2,
        tilePositions: layout.$3,
      ));
    }

    for (var u in newUsers) {
      if (SavedBranchesManager.instance.isBranchSaved(u.id)) {
        SavedBranchesManager.instance.saveLeaf(u.id, u.name, u.avatar, u.posts);
      }
    }

    setState(() {
      _users = newUsers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Leaves',
          style: AppTypography.headerBrand,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
        child: ListView.separated(
          padding: const EdgeInsets.only(bottom: 40),
          itemCount: _users.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 48),
          itemBuilder: (context, index) {
            return _buildUserSection(_users[index], isDark);
          },
        ),
      ),
    );
  }

  Widget _buildUserSection(LeafUser user, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(user.avatar),
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    user.name,
                    style: AppTypography.h3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.niche,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Follow Button -> "Follow" text in Sage Green
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B9D77), // Sage Green
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Follow'),
              ),
              
              const SizedBox(width: 4),

              // More Option
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  size: 20,
                ),
                color: isDark ? AppColors.darkCardBackground : Colors.white,
                onSelected: (value) {
                  if (value == 'save') {
                    SavedBranchesManager.instance.saveLeaf(
                      user.id,
                      user.name,
                      user.avatar,
                      user.posts,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Leaf saved to ${user.name}\'s Branch'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: AppColors.sageGreen,
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'save',
                    child: Text(
                      'Save Leaf',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // User Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: StaggeredGrid.count(
            crossAxisCount: 6,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: List.generate(user.posts.length, (index) {
              if (index >= user.layoutTiles.length) return const SizedBox();
              
              final post = user.posts[index];
              final tile = user.layoutTiles[index];
              final position = user.tilePositions[index];
              final isBig = tile.mainAxisCellCount! > 2;

              return StaggeredGridTile.count(
                crossAxisCellCount: tile.crossAxisCellCount!,
                mainAxisCellCount: tile.mainAxisCellCount!,
                child: post.type == PostType.spacer 
                  ? const SizedBox() // Render nothing for spacers
                  : GestureDetector(
                  onTap: () {
                     // Calculate aspect ratios from original tile dimensions
                     // This preserves the varied shapes in the expanded view
                     final ratios = user.layoutTiles.map((t) => t.crossAxisCellCount! / t.mainAxisCellCount!).toList();
                     
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileFeedScreen(
                          posts: user.posts,
                          initialIndex: index,
                          title: "${user.name}'s Leaves",
                          aspectRatios: ratios,
                          // Pass the specific "Leaf" border radius based on position
                          imageBorderRadius: _getBorderRadiusForPosition(position),
                        ),
                      ),
                    );
                  },
                  child: _buildTileItem(post, isDark, isBig, position),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // Helper to get border radius based on tile position
  BorderRadius _getBorderRadiusForPosition(TilePosition position) {
    switch (position) {
      case TilePosition.left:
        // Left tiles: Sharp TOP-RIGHT corner
        return const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
          topRight: Radius.zero,
        );
      case TilePosition.right:
        // Right tiles: Sharp TOP-LEFT corner
        return const BorderRadius.only(
          topLeft: Radius.zero,
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
          topRight: Radius.circular(32),
        );
      case TilePosition.middle:
        // Middle/Full-width tiles: Sharp TOP-RIGHT AND BOTTOM-LEFT corners
        return const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.zero,
          bottomRight: Radius.circular(32),
          topRight: Radius.zero,
        );
    }
  }

  Widget _buildTileItem(Post post, bool isDark, bool isBig, TilePosition position) {
    if (post.type == PostType.spacer) return const SizedBox();

    final borderRadius = _getBorderRadiusForPosition(position);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              post.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: isDark ? AppColors.darkCardBackground : Colors.grey[300],
                child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
              ),
            ),
             // Gradient Overlay - reduced since no text/avatar overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
