import 'package:flutter/foundation.dart';
import '../models/post.dart';

class UserBranch {
  final String userId;
  final String name;
  final String avatar;
  final List<Post> posts;

  UserBranch({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.posts,
  });
}

/// Global singleton that tracks which branches the user has saved.
class SavedBranchesManager extends ChangeNotifier {
  SavedBranchesManager._();
  static final SavedBranchesManager instance = SavedBranchesManager._();

  final Map<String, UserBranch> _branches = {};

  List<UserBranch> get branches => _branches.values.toList();

  bool isBranchSaved(String userId) => _branches.containsKey(userId);

  void saveLeaf(String userId, String name, String avatar, List<Post> posts) {
    if (_branches.containsKey(userId)) {
      // Append new unique posts to existing branch
      final branch = _branches[userId]!;
      final existingIds = branch.posts.map((p) => p.id).toSet();
      bool addedNew = false;
      for (var p in posts) {
        if (!existingIds.contains(p.id)) {
          branch.posts.add(p);
          addedNew = true;
        }
      }
      if (addedNew) {
        notifyListeners();
      }
    } else {
      // Create new branch
      _branches[userId] = UserBranch(
        userId: userId,
        name: name,
        avatar: avatar,
        posts: List.from(posts),
      );
      notifyListeners();
    }
  }

  void removeBranch(String userId) {
    if (_branches.containsKey(userId)) {
      _branches.remove(userId);
      notifyListeners();
    }
  }
}
