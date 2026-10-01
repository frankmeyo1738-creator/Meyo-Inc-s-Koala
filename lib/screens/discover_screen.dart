import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/sample_data.dart';
import '../models/post.dart';
import 'post_viewer_screen.dart';
import '../widgets/post_search_delegate.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => DiscoverScreenState();
}

class DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Popular', 'Newest'];
  
  // Dynamic Layout state
  List<Post> _displayPosts = [];
  List<StaggeredGridTile> _tiles = [];

  @override
  void initState() {
    super.initState();
    _generateLayout();
  }

  void _onTabSelected(int index) {
    if (_selectedTab != index) {
      setState(() {
        _selectedTab = index;
      });
      _generateLayout();
    }
  }

  /// Generates a random layout using predefined "Slabs" that always fill the 6-column width.
  /// Grid System Update: 6 columns (previously 3) to allow for 1.5 width tiles.
  /// Base Unit: 2x2 (equivalent to old 1x1).
  /// New 1.5x2 tile -> 3x4 in this grid.
  Future<void> _generateLayout() async {
    // 1. Get base posts
    List<Post> poolBase;
    if (_selectedTab == 0) {
      // Popular: Sort by highest likes, take top half for a "curated" feel
      poolBase = List.from(SampleData.samplePosts);
      poolBase.sort((a, b) => b.likes.compareTo(a.likes));
    } else {
      // Newest: Get fresh randomized posts to simulate fresh feed
      poolBase = SampleData.getFreshPosts();
    }
    
    final pool = [...poolBase, ...poolBase, ...poolBase]; // Triple to ensure enough content
    // Always shuffle so refresh actually reorders the content
    pool.shuffle();

    List<Post> generatedPosts = [];
    List<StaggeredGridTile> generatedTiles = [];
    int poolIndex = 0;

    // Slab Definitions
    // Each slab MUST fill 6 columns width.
    final slabBigLeft = [
      const StaggeredGridTile.count(crossAxisCellCount: 4, mainAxisCellCount: 4, child: SizedBox()), // 4x4
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
    ];

    final slabBigRight = [
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
      const StaggeredGridTile.count(crossAxisCellCount: 4, mainAxisCellCount: 4, child: SizedBox()), // 4x4
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
    ];

    final slabRow = [
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
      const StaggeredGridTile.count(crossAxisCellCount: 2, mainAxisCellCount: 2, child: SizedBox()), // 2x2
    ];

    final slabFull = [
      const StaggeredGridTile.count(crossAxisCellCount: 6, mainAxisCellCount: 4, child: SizedBox()), // 6x4 (Old 3x2)
    ];

    final slabSplit = [
      const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()), // 3x4 (New 1.5x2)
      const StaggeredGridTile.count(crossAxisCellCount: 3, mainAxisCellCount: 4, child: SizedBox()), // 3x4 (New 1.5x2)
    ];

    final slabTypes = [slabBigLeft, slabBigRight, slabRow, slabFull, slabSplit];

    // Track consecutive small squares on each side to prevent > 4 vertically
    int leftSmallCount = 0;
    int rightSmallCount = 0;
    bool wasLastSlabRow = false; // New constraint: No consecutive rows of small squares

    while (poolIndex < pool.length) {
      slabTypes.shuffle();
      
      List<StaggeredGridTile>? selectedSlab;
      
      for (final slab in slabTypes) {
        // Enforce constraints
        bool constraintsMet = true;
        
        // 1. Prevent consecutive rows of small squares
        if (wasLastSlabRow && slab == slabRow) {
          constraintsMet = false;
        }
        
        if (constraintsMet) {
          if (slab == slabBigRight) {
            // Adds 2 small squares to Left
            if (leftSmallCount + 2 > 4) constraintsMet = false;
          } else if (slab == slabBigLeft) {
            // Adds 2 small squares to Right
            if (rightSmallCount + 2 > 4) constraintsMet = false;
          } else if (slab == slabRow) {
            // Adds 1 small square to both Left and Right (and Middle)
            if (leftSmallCount + 1 > 4 || rightSmallCount + 1 > 4) constraintsMet = false;
          }
        }
        // slabFull and slabSplit are big tiles (height 4) so they reset counters -> always allowed constraint-wise
        
        // If constraints met, check if we have enough posts
        if (constraintsMet && poolIndex + slab.length <= pool.length) {
          selectedSlab = slab;
          break;
        }
      }

      // Fallback: If nothing fits constraints (rare), try to find ANY slab that fits pool size
      if (selectedSlab == null) {
         for (final slab in slabTypes) {
            if (poolIndex + slab.length <= pool.length) {
               selectedSlab = slab;
               break;
            }
         }
      }

      if (selectedSlab != null) {
        for (var tile in selectedSlab) {
          generatedTiles.add(tile);
          generatedPosts.add(pool[poolIndex]);
          poolIndex++;
        }
        
        // Update counters
        wasLastSlabRow = (selectedSlab == slabRow); // Update flag

        if (selectedSlab == slabBigRight) {
          leftSmallCount += 2;
          rightSmallCount = 0; // Big tile on right resets
        } else if (selectedSlab == slabBigLeft) {
          rightSmallCount += 2;
          leftSmallCount = 0; // Big tile on left resets
        } else if (selectedSlab == slabRow) {
          leftSmallCount += 1;
          rightSmallCount += 1;
        } else {
          // Full or Split (Big tiles) reset the counters
          leftSmallCount = 0;
          rightSmallCount = 0;
        }
      } else {
        break;
      }
    }

    setState(() {
      _displayPosts = generatedPosts;
      _tiles = generatedTiles;
    });
  }

  Future<void> _onRefresh() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    // Invalidate the cached posts so samplePosts regenerates with
    // new random likes, titles, and shuffle order
    SampleData.invalidateCache();
    // Regenerate layout with the fresh data
    _generateLayout();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Discover feed refreshed ✨'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandAccent,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: StaggeredGrid.count(
                    crossAxisCount: 6, // Updated to 6 columns
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    children: List.generate(_displayPosts.length, (index) {
                      final post = _displayPosts[index];
                      final tile = _tiles[index];
                      // New logic: Base unit is 2x2. Anything with MainAxis > 2 is "Big" (4x4, 6x4, 3x4)
                      final isBig = tile.mainAxisCellCount! > 2;

                      return StaggeredGridTile.count(
                        crossAxisCellCount: tile.crossAxisCellCount!,
                        mainAxisCellCount: tile.mainAxisCellCount!,
                        child: GestureDetector(
                          onTap: () {
                            // Calculate aspect ratio from tile dimensions
                            final tileAspectRatio = tile.crossAxisCellCount! / tile.mainAxisCellCount!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostViewerScreen(
                                  post: post,
                                  tileAspectRatio: tileAspectRatio,
                                ),
                              ),
                            );
                          },
                          child: _buildTileItem(post, isDark, isBig),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Discover',
            style: AppTypography.headerBrand,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = _selectedTab == index;
                  return GestureDetector(
                    onTap: () => _onTabSelected(index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tabs[index],
                            style: AppTypography.h4.copyWith(
                              fontSize: 16,
                              color: isSelected
                                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                                  : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              height: 2,
                              width: 4,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      size: 26,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: PostSearchDelegate(),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      size: 28,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTileItem(Post post, bool isDark, bool isBig) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), // More rounded corners as requested
        color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
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
                color: isDark ? AppColors.darkCardBackground : Colors.grey[300],
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


          ],
        ),
      ),
    );
  }
}
