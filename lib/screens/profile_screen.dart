// ... (imports)
import 'package:flutter/material.dart';
import 'dart:ui';
import '../data/sample_data.dart';
import '../data/saved_posts_manager.dart';
import '../data/saved_branches_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/post.dart';
import '../models/story.dart';
import '../main.dart'; // For themeProvider
import 'story_viewer_screen.dart';
import 'profile_feed_screen.dart';

/// Creator Profile - With Posts and Boards tabs
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 120);
  double _scrollOffset = 120;

  // Cached data — initialized at declaration so they survive hot reloads
  // and are guaranteed to be populated before the first build.
  List<Post> _posts = SampleData.samplePosts;
  List<Story> _stories = SampleData.sampleStories;

  // Controllers for synchronized horizontal scrolling
  late ScrollController _foregroundScrollController;
  late ScrollController _backgroundScrollController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _foregroundScrollController = ScrollController();
    _backgroundScrollController = ScrollController();
    _foregroundScrollController.addListener(() {
      if (_backgroundScrollController.hasClients) {
        _backgroundScrollController.jumpTo(_foregroundScrollController.offset);
      }
    });
    // Listen for saved posts and branches changes to rebuild the UI
    SavedPostsManager.instance.addListener(_onSavedPostsChanged);
    SavedBranchesManager.instance.addListener(_onSavedBranchesChanged);
  }

  void _onSavedPostsChanged() {
    if (mounted) setState(() {});
  }

  void _onSavedBranchesChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SavedPostsManager.instance.removeListener(_onSavedPostsChanged);
    SavedBranchesManager.instance.removeListener(_onSavedBranchesChanged);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _foregroundScrollController.dispose();
    _backgroundScrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = SampleData.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Background Story Highlights (Layer 0)
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: _buildStoryHighlights(_stories, isDark),
          ),

          // Foreground Content (Layer 1)
          // Foreground blurs when we scroll into the "reveal" space (offset < 120)
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: _scrollOffset < 120 ? ((120 - _scrollOffset) / 120 * 15.0).clamp(0.0, 15.0) : 0,
              sigmaY: _scrollOffset < 120 ? ((120 - _scrollOffset) / 120 * 15.0).clamp(0.0, 15.0) : 0,
            ),
            child: SafeArea(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  // Hidden "Reveal" Space (120px)
                  // Scrolling from 120 -> 0 reveals this space (and focuses highlights)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 120),
                  ),

                  // Transparent INTERACTIVE spacer to reveal highlights
                  // This layer captures taps for the stories behind it
                  SliverToBoxAdapter(
                    child: _buildInteractiveStoriesSpacer(_stories),
                  ),

                  // Profile Header Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Profile picture
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? AppColors.darkShadow : AppColors.shadow,
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
                              backgroundImage: AssetImage(
                                user.avatarUrl,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Text(
                            user.displayName,
                            style: AppTypography.h3.copyWith(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '@${user.username}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Bio
                          Text(
                            user.bio,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stats Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _StatColumn(count: '124', label: 'Posts', isDark: isDark),
                              Container(height: 24, width: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
                              _StatColumn(count: '15.4k', label: 'Followers', isDark: isDark),
                              Container(height: 24, width: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
                              _StatColumn(count: '891', label: 'Following', isDark: isDark),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.sageGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                                  fixedSize: const Size.fromHeight(42),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Edit profile',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2C2C2C) : Colors.black,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? Colors.white24 : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _showSettingsSheet(context);
                                  },
                                  icon: const Icon(Icons.settings_outlined, size: 20),
                                  color: Colors.white,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Pill-style Tab Switcher
                          _buildPillTabSwitcher(isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  // Tab content
                  if (_selectedTab == 0)
                    _buildStaggeredPostsGrid(_posts, isDark)
                  else if (_selectedTab == 1)
                    _buildBoardsList(isDark) // Boards renamed to Branches in UI
                  else
                    _buildSavedGrid(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (helper methods unchanged until Image usage)

  /// Build story highlights with scroll reveal
  Widget _buildStoryHighlights(List<Story> stories, bool isDark) {
    const double initialBlur = 15.0;
    const double revealOffset = 120.0; // The top padding amount
    const double fadeOutThreshold = 100.0;

    double blurAmount = initialBlur;
    double translateY = 0.0;
    double opacity = 1.0;

    if (_scrollOffset < revealOffset) {
      // REVEAL RANGE (0 to 120): User is pulling down to see highlights
      // Blur reduces as we get closer to 0
      final progress = (_scrollOffset / revealOffset).clamp(0.0, 1.0);
      blurAmount = initialBlur * progress; 
      
      // Parallax: Move slightly down as we pull down
      // At 120 (default): y=0. At 0 (revealed): y=36.
      translateY = (revealOffset - _scrollOffset) * 0.3;
      opacity = 1.0;
    } else {
      // SCROLL UP RANGE (> 120): Normal scrolling
      // Blur stays max
      blurAmount = initialBlur;
      
      // Parallax: Move up
      translateY = -(_scrollOffset - revealOffset) * 0.3;
      
      // Fade out
      opacity = (1.0 - ((_scrollOffset - revealOffset) / fadeOutThreshold)).clamp(0.0, 1.0);
    }

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurAmount.clamp(0.0, initialBlur),
            sigmaY: blurAmount.clamp(0.0, initialBlur),
            tileMode: TileMode.decal,
          ),
          child: SizedBox(
            height: 280,
            child: ListView.builder(
              controller: _backgroundScrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 12,
                    right: index == stories.length - 1 ? 0 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StoryViewerScreen(
                            stories: stories,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: _StoryCard(story: story, isDark: isDark),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }


  /// Builds a transparent foreground layer that matches the geometry of the
  /// background highlights. This captures taps and navigates to the story viewer.
  Widget _buildInteractiveStoriesSpacer(List<Story> stories) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        controller: _foregroundScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          // Geometry MUST match _buildStoryHighlights exactly
          // Geometry MUST match _buildStoryHighlights exactly
          // Approximation of _StoryCard width + padding
          // Actually, let's use a container with the same width constraints 
          // as _StoryCard to be safe. Since _StoryCard width is determined by 
          // its AspectRatio(0.7) and height constraints, we should match that.
          
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 12,
              right: index == stories.length - 1 ? 0 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => StoryViewerScreen(
                      stories: stories,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent, // Hit testable but invisible
                child: const AspectRatio(
                  aspectRatio: 0.7,
                  child: SizedBox(), // Matches _StoryCard aspect ratio
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPillTabSwitcher(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPillTab('Posts', 0, isDark),
          _buildPillTab('Branches', 1, isDark),
          _buildPillTab('Saved', 2, isDark),
        ],
      ),
    );
  }

  Widget _buildPillTab(String label, int index, bool isDark) {
    final isSelected = _selectedTab == index;
    final isUnresponsive = false; // All tabs are now active

    return GestureDetector(
      onTap: isUnresponsive ? null : () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isUnresponsive
                ? (isDark ? AppColors.darkTextTertiary.withValues(alpha: 0.5) : AppColors.textTertiary.withValues(alpha: 0.5))
                : (isSelected 
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                    : (isDark ? AppColors.darkTextTertiary : AppColors.textTertiary)),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showSettingsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkCardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkDivider : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Settings',
                    style: AppTypography.h4.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Dark Mode Toggle
                  _SettingsItem(
                    icon: isDark ? Icons.dark_mode : Icons.light_mode,
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch.adaptive(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                        setSheetState(() {});
                      },
                      activeTrackColor: AppColors.brandAccent,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  _SettingsItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  
                  const SizedBox(height: 16),
                  _SettingsItem(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  
                  const SizedBox(height: 16),
                  _SettingsItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    isDark: isDark,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Grid for Posts with white cards and rounded corners
  Widget _buildStaggeredPostsGrid(List posts, bool isDark) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      sliver: SliverGrid.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75,
        children: List.generate(posts.length, (index) {
          final post = posts[index];
          
          return GestureDetector(
            onTap: () {
              // Navigation to Feed View (Instagram style)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFeedScreen(
                    posts: posts as List<Post>, // Safe cast since we know it's List<Post>
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    post.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    ),
                  ),
                  // Video indicator overlay (for video posts)
                  if (post.isVideo)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_filled, color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '0:45',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Carousel indicator (for multi-image posts)
                  if (post.images.length > 1)
                    Positioned(
                      top: 4,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ),
          );
        }),
      ),
    );
  }

  // Grid for Saved posts — reuses the same tile style as Posts
  Widget _buildSavedGrid(bool isDark) {
    final savedPosts = SavedPostsManager.instance.savedPosts;

    if (savedPosts.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: isDark
                    ? AppColors.darkTextTertiary.withValues(alpha: 0.4)
                    : AppColors.textTertiary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No saved posts yet',
                style: AppTypography.h4.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the bookmark icon on any post\nto save it here',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      sliver: SliverGrid.count(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75,
        children: List.generate(savedPosts.length, (index) {
          final post = savedPosts[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFeedScreen(
                    posts: savedPosts,
                    initialIndex: index,
                    title: 'Saved',
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBackground : Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      post.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? AppColors.darkCardBackground : Colors.grey[200],
                        child: const Icon(Icons.error_outline, color: Colors.grey),
                      ),
                    ),
                    // Saved bookmark badge
                    Positioned(
                      top: 4,
                      right: 6,
                      child: Icon(
                        Icons.bookmark,
                        color: AppColors.brandAccent,
                        size: 18,
                      ),
                    ),
                    // Video indicator
                    if (post.isVideo)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_circle_filled, color: Colors.white, size: 18),
                            const SizedBox(width: 3),
                            Text(
                              '0:45',
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Carousel indicator
                    if (post.images.length > 1)
                      Positioned(
                        top: 4,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Icon(
                            Icons.layers_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // Pinterest-style Board cards
  Widget _buildBoardsList(bool isDark) {
    final branches = SavedBranchesManager.instance.branches;
    
    if (branches.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_tree_outlined,
                size: 64,
                color: isDark
                    ? AppColors.darkTextTertiary.withValues(alpha: 0.4)
                    : AppColors.textTertiary.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No branches yet',
                style: AppTypography.h4.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Save a creator\'s leaf to\nstart a new branch',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.textTertiary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "Branches" header
            Text(
              'Your Branches',
              style: AppTypography.h4.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Board cards
            ...branches.map((branch) => GestureDetector(
              onTap: () {
                if (branch.posts.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileFeedScreen(
                        posts: branch.posts,
                        initialIndex: 0,
                        title: branch.name,
                      ),
                    ),
                  );
                }
              },
              child: _BranchCard(
                coverUrl: branch.posts.isNotEmpty ? branch.posts.first.imageUrl : '',
                branchName: branch.name,
                likesCount: '${branch.posts.length} leaves',
                isDark: isDark,
              ),
            )),
          ],
        ),
      ),
    );
  }

// ... (Rest of file including helper classes)
}

/// Individual story card with rounded rectangle design (like IG highlights)
class _StoryCard extends StatelessWidget {
  final Story story;
  final bool isDark;

  const _StoryCard({required this.story, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Open story viewer
      },
      child: Container(
        width: 140,
        height: 250,
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

// Branch card widget (Redesigned Horizontal Layout)
class _BranchCard extends StatelessWidget {
  final String coverUrl;
  final String branchName;
  final String likesCount;
  final bool isDark;

  const _BranchCard({
    required this.coverUrl,
    required this.branchName,
    required this.likesCount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Square Cover Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: isDark ? AppColors.darkDivider : AppColors.divider,
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 20),
          
          // Right: Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branchName,
                  style: AppTypography.h3.copyWith( // Using H3 for bold title
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likesCount likes',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Optional: Arrow or Action
          Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String count;
  final String label;
  final bool isDark;

  const _StatColumn({
    required this.count,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final bool isDark;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.creamWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
