import 'package:flutter/material.dart';
import '../models/post.dart';
import 'post_viewer_screen.dart';

/// Screen to view the stack of posts in a Leaf vertically
class LeafViewerScreen extends StatefulWidget {
  final List<Post> posts;
  final int initialIndex;

  const LeafViewerScreen({
    Key? key,
    required this.posts,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<LeafViewerScreen> createState() => _LeafViewerScreenState();
}

class _LeafViewerScreenState extends State<LeafViewerScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        itemBuilder: (context, index) {
          // We wrap PostViewerScreen but might need to adjust it to remove duplicate Scaffolds 
          // or just use it as is since it provides the full UI. 
          // PostViewerScreen is a Scaffold, so nested Scaffolds work in PageView but 
          // it's better if we treat it as a page.
          return PostViewerScreen(post: widget.posts[index]);
        },
      ),
    );
  }
}
