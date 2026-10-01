import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/post.dart';
import '../core/theme/app_colors.dart';
import '../screens/post_viewer_screen.dart';

class PostSearchDelegate extends SearchDelegate<Post?> {
  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        iconTheme: IconThemeData(color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionsOrResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsOrResults(context);
  }

  Widget _buildSuggestionsOrResults(BuildContext context) {
    final allPosts = SampleData.samplePosts;
    final results = query.isEmpty
        ? allPosts.take(10).toList()
        : allPosts.where((post) {
            final titleLower = post.title.toLowerCase();
            final authorLower = post.authorName.toLowerCase();
            final searchLower = query.toLowerCase();
            return titleLower.contains(searchLower) || authorLower.contains(searchLower);
          }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No posts found for "$query"',
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
        ),
      );
    }

    return Container(
      color: isDark ? AppColors.darkBackground : AppColors.background,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final post = results[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                post.imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: isDark ? AppColors.darkCardBackground : Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              post.title,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              post.authorName,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostViewerScreen(
                    post: post,
                    tileAspectRatio: post.aspectRatio,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
