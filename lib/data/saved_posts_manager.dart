import 'package:flutter/foundation.dart';
import '../models/post.dart';

/// Global singleton that tracks which posts the user has saved.
/// Uses ChangeNotifier so any listening widget rebuilds when the list changes.
class SavedPostsManager extends ChangeNotifier {
  // Private constructor (singleton)
  SavedPostsManager._();
  static final SavedPostsManager instance = SavedPostsManager._();

  /// Internal storage: post ID → Post object
  final Map<String, Post> _savedPosts = {};

  /// Whether a post is currently saved.
  bool isSaved(String postId) => _savedPosts.containsKey(postId);

  /// All saved posts, newest-saved first.
  List<Post> get savedPosts => _savedPosts.values.toList().reversed.toList();

  /// Number of saved posts.
  int get count => _savedPosts.length;

  /// Toggle save state. Returns true if post is now saved, false if unsaved.
  bool toggle(Post post) {
    if (_savedPosts.containsKey(post.id)) {
      _savedPosts.remove(post.id);
      notifyListeners();
      return false;
    } else {
      _savedPosts[post.id] = post;
      notifyListeners();
      return true;
    }
  }

  /// Explicitly save a post.
  void save(Post post) {
    if (!_savedPosts.containsKey(post.id)) {
      _savedPosts[post.id] = post;
      notifyListeners();
    }
  }

  /// Explicitly unsave a post.
  void unsave(String postId) {
    if (_savedPosts.containsKey(postId)) {
      _savedPosts.remove(postId);
      notifyListeners();
    }
  }
}
