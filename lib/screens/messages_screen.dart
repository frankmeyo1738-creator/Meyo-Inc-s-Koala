import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  static const List<_Conversation> _conversations = [
    _Conversation(
      name: 'Chanda Mwale',
      avatar: 'assets/images/ayra_starr.jpg',
      lastMessage: 'You still posting that golden hour set tonight?',
      time: 'Now',
      unreadCount: 2,
      isOnline: true,
      messages: [
        _ChatMessage(text: 'You still posting that golden hour set tonight?', isMine: false),
        _ChatMessage(text: 'Yes, I am just cleaning up the caption first.', isMine: true),
        _ChatMessage(text: 'Perfect. Send it when it is up.', isMine: false),
      ],
    ),
    _Conversation(
      name: 'Mutale Banda',
      avatar: 'assets/images/jessica_alba.jpg',
      lastMessage: 'That moodboard idea is actually hard.',
      time: '8m',
      unreadCount: 0,
      isOnline: true,
      messages: [
        _ChatMessage(text: 'That moodboard idea is actually hard.', isMine: false),
        _ChatMessage(text: 'I want to make the sharing flow smoother next.', isMine: true),
      ],
    ),
    _Conversation(
      name: 'Lubasi Phiri',
      avatar: 'assets/images/nathalie_emmanuel.jpg',
      lastMessage: 'Can you send me the campus-life references?',
      time: '22m',
      unreadCount: 1,
      isOnline: false,
      messages: [
        _ChatMessage(text: 'Can you send me the campus-life references?', isMine: false),
        _ChatMessage(text: 'I will drop them here in a minute.', isMine: true),
      ],
    ),
    _Conversation(
      name: 'Natasha Zimba',
      avatar: 'assets/images/selena_gomez.jpg',
      lastMessage: 'The dark mode header looks clean now.',
      time: '1h',
      unreadCount: 0,
      isOnline: false,
      messages: [
        _ChatMessage(text: 'The dark mode header looks clean now.', isMine: false),
        _ChatMessage(text: 'Thank you. I wanted it to stay simple.', isMine: true),
      ],
    ),
    _Conversation(
      name: 'Melody Mbewe',
      avatar: 'assets/images/jorja_smith.jpg',
      lastMessage: 'Drop the reel cover when you are done.',
      time: '3h',
      unreadCount: 0,
      isOnline: true,
      messages: [
        _ChatMessage(text: 'Drop the reel cover when you are done.', isMine: false),
        _ChatMessage(text: 'Will do. I am exporting a few options.', isMine: true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCardBackground : Colors.white;
    final searchColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      CupertinoIcons.chevron_back,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Messages',
                      style: AppTypography.h4.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.brandAccent.withValues(alpha: isDark ? 0.22 : 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '3 new',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.brandAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: searchColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.search,
                      size: 18,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Search messages',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 92,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _conversations.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return _ActiveThreadChip(
                    conversation: conversation,
                    isDark: isDark,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: _conversations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _ConversationScreen(conversation: conversation),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: AssetImage(conversation.avatar),
                                ),
                                if (conversation.isOnline)
                                  Positioned(
                                    right: 1,
                                    bottom: 1,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.brandAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cardColor, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversation.name,
                                          style: AppTypography.labelLarge.copyWith(
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        conversation.time,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conversation.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.bodyMedium.copyWith(
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      if (conversation.unreadCount > 0) ...[
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandAccent,
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            '${conversation.unreadCount}',
                                            style: AppTypography.labelSmall.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationScreen extends StatefulWidget {
  final _Conversation conversation;

  const _ConversationScreen({
    required this.conversation,
  });

  @override
  State<_ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<_ConversationScreen> {
  final TextEditingController _controller = TextEditingController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List<_ChatMessage>.from(widget.conversation.messages);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isMine: true));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBackground : AppColors.background;
    final bubbleMine = AppColors.brandAccent;
    final bubbleOther = isDark ? AppColors.darkCardBackground : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      CupertinoIcons.chevron_back,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(widget.conversation.avatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conversation.name,
                          style: AppTypography.labelLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.conversation.isOnline ? 'Active now' : 'Away for a bit',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    CupertinoIcons.phone,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final align = message.isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                  final bubbleColor = message.isMine ? bubbleMine : bubbleOther;
                  final textColor = message.isMine
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary);

                  return Column(
                    crossAxisAlignment: align,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message.text,
                          style: AppTypography.bodyMedium.copyWith(color: textColor),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type a message...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.brandAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveThreadChip extends StatelessWidget {
  final _Conversation conversation;
  final bool isDark;

  const _ActiveThreadChip({
    required this.conversation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _ConversationScreen(conversation: conversation),
          ),
        );
      },
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: conversation.isOnline ? AppColors.brandAccent : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(conversation.avatar),
                  ),
                ),
                if (conversation.unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.softTerracotta,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              conversation.name.split(' ').first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Conversation {
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final List<_ChatMessage> messages;

  const _Conversation({
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.messages,
  });
}

class _ChatMessage {
  final String text;
  final bool isMine;

  const _ChatMessage({
    required this.text,
    required this.isMine,
  });
}
