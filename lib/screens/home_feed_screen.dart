import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../widgets/vertical_post_card.dart';
import '../models/post.dart';
import '../data/sample_data.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import 'messages_screen.dart';

/// Home Feed - Vertical Instagram-style scroll
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => HomeFeedScreenState();
}

class HomeFeedScreenState extends State<HomeFeedScreen> {
  late List<Post> _posts;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = true;

  // Height of the custom header (matches a typical AppBar height)
  static const double _headerHeight = 56.0;

  @override
  void initState() {
    super.initState();
    _posts = SampleData.samplePosts;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ScrollDirection direction =
        _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isHeaderVisible) {
      setState(() => _isHeaderVisible = false);
    } else if (direction == ScrollDirection.forward && !_isHeaderVisible) {
      setState(() => _isHeaderVisible = true);
    }
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _posts = SampleData.getFreshPosts();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Feed refreshed ✨'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.brandAccent,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  /// Public method to trigger refresh from parent
  void refresh() {
    _handleRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final headerBg = isDark ? AppColors.darkBackground : AppColors.background;

    final useLightStatusIcons = !_isHeaderVisible || isDark;
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: useLightStatusIcons
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: useLightStatusIcons
          ? Brightness.dark
          : Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: headerBg,
        body: Column(
          children: [
            // ── Animated header ──────────────────────────────────────────
            ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                height: topPadding + (_isHeaderVisible ? _headerHeight : 0),
                color: _isHeaderVisible ? headerBg : Colors.black,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: topPadding,
                      left: 0,
                      right: 0,
                      height: _headerHeight,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: _isHeaderVisible ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            // Notification bell
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.notifications_outlined,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                  onPressed: () => _showNotifications(context),
                                ),
                                // Unread badge dot
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.brandAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Centred brand title
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🐨',
                                    style: TextStyle(fontSize: 26),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Koala',
                                    style: AppTypography.headerBrand,
                                  ),
                                ],
                              ),
                            ),

                            // Action icons
                            IconButton(
                              icon: Icon(
                                Icons.add_box_outlined,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                CupertinoIcons.chat_bubble,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const MessagesScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Feed ─────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: AppColors.brandAccent,
                onRefresh: _handleRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    return VerticalPostCard(
                      post: post,
                      aspectRatio: post.aspectRatio,
                      onLike: () {},
                      onComment: () => _showComments(context, post),
                      onShare: () {},
                      onCollect: () {},
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Comments bottom sheet ─────────────────────────────────────────────
  void _showComments(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(post: post),
    );
  }

  // ── Notifications bottom sheet ────────────────────────────────────────
  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationsSheet(),
    );
  }
}

// ── Comments Bottom Sheet ────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final Post post;
  const _CommentsSheet({required this.post});

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Sample comments data
  static const List<Map<String, dynamic>> _sampleComments = [
    {
      'avatar': 'assets/images/ayra_starr.jpg',
      'name': 'Chanda Mwale',
      'text': 'This is absolutely stunning! 😍',
      'time': '2m',
      'likes': 14,
      'liked': false,
    },
    {
      'avatar': 'assets/images/jessica_alba.jpg',
      'name': 'Mutale Banda',
      'text': 'Love the vibe here ✨🔥',
      'time': '5m',
      'likes': 8,
      'liked': false,
    },
    {
      'avatar': 'assets/images/nathalie_emmanuel.jpg',
      'name': 'Lubasi Phiri',
      'text': 'Take me back to this place please 🙏',
      'time': '12m',
      'likes': 23,
      'liked': true,
    },
    {
      'avatar': 'assets/images/selena_gomez.jpg',
      'name': 'Natasha Zimba',
      'text': 'Goals!! Where is this? 📍',
      'time': '18m',
      'likes': 5,
      'liked': false,
    },
    {
      'avatar': 'assets/images/jorja_smith.jpg',
      'name': 'Melody Mbewe',
      'text': 'The aesthetic is immaculate 💫',
      'time': '25m',
      'likes': 31,
      'liked': false,
    },
    {
      'avatar': 'assets/images/tylaa.jpg',
      'name': 'Patrick Ngoma',
      'text': 'Bro this goes hard no cap 🤞',
      'time': '34m',
      'likes': 19,
      'liked': false,
    },
  ];

  late List<Map<String, dynamic>> _comments;
  final List<Map<String, dynamic>> _newComments = [];

  @override
  void initState() {
    super.initState();
    _comments = List<Map<String, dynamic>>.from(_sampleComments);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _postComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _newComments.insert(0, {
        'avatar': SampleData.currentUser.avatarUrl,
        'name': SampleData.currentUser.displayName,
        'text': text,
        'time': 'now',
        'likes': 0,
        'liked': false,
      });
      _inputController.clear();
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final allComments = [..._newComments, ..._comments];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          // ── Drag handle ───────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // ── Title row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.post.comments + _newComments.length}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.brandAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(
            height: 16,
            thickness: 0.5,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          // ── Comment list ──────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: allComments.length,
              itemBuilder: (context, i) {
                final c = allComments[i];
                return _CommentTile(
                  comment: c,
                  isDark: isDark,
                  onLike: () {
                    setState(() {
                      final liked = c['liked'] as bool;
                      allComments[i]['liked'] = !liked;
                      allComments[i]['likes'] =
                          (allComments[i]['likes'] as int) + (liked ? -1 : 1);
                    });
                  },
                );
              },
            ),
          ),

          // ── Input bar ─────────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // Current user avatar
                CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(SampleData.currentUser.avatarUrl),
                ),
                const SizedBox(width: 10),

                // Input field
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: TextField(
                      controller: _inputController,
                      focusNode: _focusNode,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Add a comment…',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _postComment(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                GestureDetector(
                  onTap: _postComment,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Single comment tile ──────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final Map<String, dynamic> comment;
  final bool isDark;
  final VoidCallback onLike;

  const _CommentTile({
    required this.comment,
    required this.isDark,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final liked = comment['liked'] as bool;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(comment['avatar'] as String),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['name'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comment['time'] as String,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text'] as String,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'Reply',
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? Colors.white38 : AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Like button
          GestureDetector(
            onTap: onLike,
            child: Column(
              children: [
                Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  size: 18,
                  color: liked
                      ? AppColors.dustyRose
                      : (isDark ? Colors.white38 : AppColors.textTertiary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${comment['likes']}',
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notifications Bottom Sheet ───────────────────────────────────────────────

enum _NotifType { like, comment, follow, newPost }

class _NotifItem {
  final String avatar;
  final String name;
  final String action;
  final String detail;
  final String time;
  final _NotifType type;
  bool isRead;

  _NotifItem({
    required this.avatar,
    required this.name,
    required this.action,
    required this.detail,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  late List<_NotifItem> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      _NotifItem(
        avatar: 'assets/images/ayra_starr.jpg',
        name: 'Chanda Mwale',
        action: 'liked your post',
        detail: 'Golden Hour',
        time: '2m',
        type: _NotifType.like,
      ),
      _NotifItem(
        avatar: 'assets/images/jessica_alba.jpg',
        name: 'Mutale Banda',
        action: 'commented:',
        detail: '"This is absolutely stunning! 😍"',
        time: '5m',
        type: _NotifType.comment,
      ),
      _NotifItem(
        avatar: 'assets/images/nathalie_emmanuel.jpg',
        name: 'Lubasi Phiri',
        action: 'started following you',
        detail: '',
        time: '12m',
        type: _NotifType.follow,
      ),
      _NotifItem(
        avatar: 'assets/images/selena_gomez.jpg',
        name: 'Natasha Zimba',
        action: 'liked your post',
        detail: 'Dreamscape',
        time: '18m',
        type: _NotifType.like,
      ),
      _NotifItem(
        avatar: 'assets/images/jorja_smith.jpg',
        name: 'Melody Mbewe',
        action: 'posted a new leaf',
        detail: 'Morning Vibes ✨',
        time: '25m',
        type: _NotifType.newPost,
        isRead: true,
      ),
      _NotifItem(
        avatar: 'assets/images/tylaa.jpg',
        name: 'Patrick Ngoma',
        action: 'commented:',
        detail: '"Bro this goes hard 🤞"',
        time: '34m',
        type: _NotifType.comment,
        isRead: true,
      ),
      _NotifItem(
        avatar: 'assets/images/kendrick_lamar.jpg',
        name: 'Guy Hawkins',
        action: 'started following you',
        detail: '',
        time: '1h',
        type: _NotifType.follow,
        isRead: true,
      ),
      _NotifItem(
        avatar: 'assets/images/amandla_premiere.jpg',
        name: 'Esther Howard',
        action: 'liked your post',
        detail: 'City Lights',
        time: '2h',
        type: _NotifType.like,
        isRead: true,
      ),
    ];
  }

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
  }

  IconData _iconFor(_NotifType type) {
    switch (type) {
      case _NotifType.like:
        return Icons.favorite;
      case _NotifType.comment:
        return Icons.chat_bubble;
      case _NotifType.follow:
        return Icons.person_add;
      case _NotifType.newPost:
        return Icons.eco;
    }
  }

  Color _colorFor(_NotifType type) {
    switch (type) {
      case _NotifType.like:
        return AppColors.dustyRose;
      case _NotifType.comment:
        return const Color(0xFF7B9CFF);
      case _NotifType.follow:
        return AppColors.brandAccent;
      case _NotifType.newPost:
        return const Color(0xFF8BC34A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
        children: [
          // ── Drag handle ────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // ── Title row ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount new',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.brandAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (unreadCount > 0)
                  GestureDetector(
                    onTap: _markAllRead,
                    child: Text(
                      'Mark all read',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.brandAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 4),
          Divider(
            height: 16,
            thickness: 0.5,
            color: isDark ? Colors.white12 : Colors.black12,
          ),

          // ── Notification list ──────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _notifications.length,
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return _NotifTile(
                  item: n,
                  isDark: isDark,
                  iconData: _iconFor(n.type),
                  iconColor: _colorFor(n.type),
                  onTap: () {
                    setState(() => n.isRead = true);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  final bool isDark;
  final IconData iconData;
  final Color iconColor;
  final VoidCallback onTap;

  const _NotifTile({
    required this.item,
    required this.isDark,
    required this.iconData,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unreadBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : AppColors.brandAccent.withValues(alpha: 0.04);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: item.isRead ? Colors.transparent : unreadBg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + type icon badge
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(item.avatar),
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1C1C1E)
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(iconData, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.name,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${item.action}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? Colors.white70
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (item.detail.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.detail,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                        fontStyle: item.type == _NotifType.comment
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? Colors.white30 : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Unread dot
            if (!item.isRead)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 8),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.brandAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
