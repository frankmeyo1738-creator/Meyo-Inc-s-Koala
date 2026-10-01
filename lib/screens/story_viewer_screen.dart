import 'package:flutter/material.dart';

import '../models/story.dart';

import '../core/theme/app_typography.dart';
import '../data/sample_data.dart'; // For user data (temporary)

class StoryViewerScreen extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Standard story duration
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onStoryFinished();
      }
    });

    _startStory();
  }

  void _startStory() {
    _animController.reset();
    _animController.forward();
  }

  void _onStoryFinished() {
    if (_currentIndex < widget.stories.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop(); // Close viewer when done
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (details.globalPosition.dx < screenWidth / 3) {
      // Tap Left
      if (_currentIndex > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Restart current story if it's the first one
        _startStory(); 
      }
    } else {
      // Tap Right (or center)
      _onStoryFinished();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SampleData.currentUser; // Assuming story belongs to current user for now

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.of(context).pop(); // Swipe down to close
          }
        },
        onTapDown: _handleTapDown,
        child: Stack(
          children: [
            // Story PageView
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Handle taps manually
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _startStory();
                });
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      story.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black45,
                            Colors.transparent,
                            Colors.black26,
                          ],
                          stops: [0.0, 0.2, 0.8],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Top Overlay
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    // Progress Bar
                    Row(
                      children: widget.stories.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Container(
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    if (index == _currentIndex)
                                      AnimatedBuilder(
                                        animation: _animController,
                                        builder: (context, child) {
                                          return Container(
                                            height: 2,
                                            width: constraints.maxWidth * _animController.value,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          );
                                        },
                                      )
                                    else if (index < _currentIndex)
                                      Container(
                                        height: 2,
                                        width: constraints.maxWidth,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage(user.avatarUrl),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.displayName,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.stories[_currentIndex].timeAgo, // Use story-specific time if available
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
