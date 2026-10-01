import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/post.dart';
import '../widgets/vertical_post_card.dart';
import '../core/theme/app_colors.dart';

/// Instagram-style feed viewer for profile posts
/// Shows a scrollable vertical feed starting from the tapped post
class ProfileFeedScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;
  final String? title; // Optional custom title
  final List<double>? aspectRatios; // Optional aspect ratios to preserve shapes
  final BorderRadius? imageBorderRadius; // Optional custom border for images

  const ProfileFeedScreen({
    Key? key,
    required this.posts,
    required this.initialIndex,
    this.title,
    this.aspectRatios,
    this.imageBorderRadius,
  }) : super(key: key);

  @override
  State<ProfileFeedScreen> createState() => _ProfileFeedScreenState();
}

class _ProfileFeedScreenState extends State<ProfileFeedScreen> {
  ScrollController? _scrollController;
  late List<GlobalKey> _postKeys;

  @override
  void initState() {
    super.initState();
    _postKeys = List.generate(widget.posts.length, (_) => GlobalKey());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scrollController == null) {
      final screenWidth = MediaQuery.of(context).size.width;
      // Estimate height roughly since dynamic aspect ratios make it variable
      final estimatedItemHeight = screenWidth + 120;
      final initialOffset = widget.initialIndex * estimatedItemHeight;
      
      _scrollController = ScrollController(initialScrollOffset: initialOffset);
      
      // Fine-tune with ensureVisible after first layout
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToPost(widget.initialIndex);
      });
    }
  }

  void _scrollToPost(int index) {
    if (index >= 0 && index < _postKeys.length) {
      final context = _postKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          alignment: 0.0,
          duration: const Duration(milliseconds: 50), // ultra fast correction
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.chevron_back,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    widget.title ?? 'Posts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),

            // Scrollable feed of posts
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Column(
                  children: List.generate(widget.posts.length, (index) {
                    final post = widget.posts[index];
                    // Determine aspect ratio if provided
                    final ratio = widget.aspectRatios != null && widget.aspectRatios!.length > index
                        ? widget.aspectRatios![index]
                        : 1.0;

                    return VerticalPostCard(
                      key: _postKeys[index],
                      post: post,
                      showHeader: false, // Cleaner look for own profile
                      aspectRatio: ratio,
                      borderRadius: widget.imageBorderRadius,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
