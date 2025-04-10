import 'package:buyer_centric_app_v2/models/message_model.dart';
import 'package:buyer_centric_app_v2/services/chat_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.otherUserName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  // Cache of usernames
  final Map<String, String> _usernameCache = {};
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  Stream<List<Message>>? _messagesStream;

  //* Keep this state alive when navigating away temporarily
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Initialize message stream only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized && mounted) {
        final chatService = Provider.of<ChatService>(context, listen: false);
        _messagesStream = chatService.getMessages(widget.chatRoomId);
        // Pre-cache the other user's name
        _loadUserNames();
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  void _loadUserNames() async {
    // Avoid unnecessary rebuilds by not using setState for each username
    Map<String, String> newUsernames = {};

    final chatService = Provider.of<ChatService>(context, listen: false);
    if (chatService.currentUserId != null) {
      try {
        // Get all usernames from chat room data first (most efficient)
        final chatRoomDoc = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .get();

        if (chatRoomDoc.exists && chatRoomDoc.data() != null) {
          final userNames =
              chatRoomDoc.data()?['userNames'] as Map<String, dynamic>?;
          if (userNames != null) {
            userNames.forEach((userId, username) {
              newUsernames[userId] = username.toString();
            });
          }
        }

        // If current user's name is still missing, try to get it
        if (!newUsernames.containsKey(chatService.currentUserId)) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(chatService.currentUserId)
              .get();

          final currentUsername = userDoc.data()?['username'] ?? 'Unknown User';
          newUsernames[chatService.currentUserId!] = currentUsername;
        }

        // Update state only once with all collected usernames
        if (mounted) {
          setState(() {
            _usernameCache.addAll(newUsernames);
          });
        }
      } catch (e) {
        print('Error loading user names: $e');
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Optimized to fetch username without triggering rebuilds
  Future<String> _getUserName(String userId) async {
    // Check cache first
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    try {
      String? username;

      // Try to get from chat room data first (most efficient)
      final chatRoomDoc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .get();

      if (chatRoomDoc.exists && chatRoomDoc.data() != null) {
        final Map<String, dynamic>? userNames =
            chatRoomDoc.data()?['userNames'] as Map<String, dynamic>?;

        if (userNames != null && userNames.containsKey(userId)) {
          username = userNames[userId] as String;
        }
      }

      // If not found, try usernames collection
      if (username == null) {
        final usernameDoc = await FirebaseFirestore.instance
            .collection('usernames')
            .doc(userId)
            .get();

        if (usernameDoc.exists && usernameDoc.data() != null) {
          username = usernameDoc.data()?['username'] as String?;
        }
      }

      // If still not found, try users collection
      if (username == null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          username = userDoc.data()?['username'] as String?;

          // Save to usernames collection for faster lookup next time
          if (username != null && username.isNotEmpty) {
            await FirebaseFirestore.instance
                .collection('usernames')
                .doc(userId)
                .set({
              'username': username,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        }
      }

      if (username != null && username.isNotEmpty) {
        // Update cache without triggering rebuild
        _usernameCache[userId] = username;
        return username;
      }
    } catch (e) {
      print('Error fetching username: $e');
    }

    // Default fallback
    final shortId = userId.length > 5 ? userId.substring(0, 5) : userId;
    final username = 'User $shortId';

    // Update cache without triggering rebuild
    _usernameCache[userId] = username;
    return username;
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Update only the loading state, without triggering full rebuild
    setState(() {
      _isLoading = true;
    });

    try {
      // Don't use context within async gap to avoid context issues
      final chatService = Provider.of<ChatService>(context, listen: false);
      await chatService.sendMessage(widget.chatRoomId, messageText);

      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      // Only update loading state if widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Get username without triggering rebuilds
  String _getNameFromCache(String userId) {
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    // Start async fetch but don't wait for it
    _fetchAndUpdateUsernameInBackground(userId);

    // Return a temporary name
    return userId.length > 5 ? 'User ${userId.substring(0, 5)}' : userId;
  }

  // Fetch username in background without triggering rebuild
  void _fetchAndUpdateUsernameInBackground(String userId) {
    _getUserName(userId).then((name) {
      // We don't call setState here to avoid rebuilding
      // The next time this username is needed, it will be in the cache
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          final currentUserId = chatService.currentUserId;

          return Column(
            children: [
              // Messages list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    image: DecorationImage(
                      image: AssetImage('assets/images/chat_bg.png'),
                      opacity: 0.05,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: _messagesStream == null
                      ? const Center(
                          child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ))
                      : StreamBuilder<List<Message>>(
                          stream: _messagesStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ));
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final messages = snapshot.data ?? [];

                            if (messages.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.chat_bubble_outline,
                                          size: 64,
                                          color: Colors.black.withOpacity(0.7)),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No messages yet',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Send a message to start the conversation',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              reverse: true,
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                final isMe = message.senderId == currentUserId;

                                // Group messages by sender and time
                                bool showName = true;
                                bool showAvatar = true;
                                bool isFirstInGroup = true;
                                bool isLastInGroup = true;

                                if (index < messages.length - 1) {
                                  final prevMessage = messages[index + 1];
                                  final isPrevSameSender =
                                      prevMessage.senderId == message.senderId;
                                  // If same sender and messages are within 5 minutes, group them
                                  if (isPrevSameSender &&
                                      message.timestamp
                                              .difference(prevMessage.timestamp)
                                              .inMinutes <
                                          5) {
                                    showName = false;
                                    showAvatar = false;
                                    isFirstInGroup = false;
                                  }
                                }

                                if (index > 0) {
                                  final nextMessage = messages[index - 1];
                                  final isNextSameSender =
                                      nextMessage.senderId == message.senderId;
                                  // If next message is from same sender and within 5 minutes, this isn't last in group
                                  if (isNextSameSender &&
                                      nextMessage.timestamp
                                              .difference(message.timestamp)
                                              .inMinutes <
                                          5) {
                                    isLastInGroup = false;
                                  }
                                }

                                // Get username from cache without triggering rebuild
                                String username =
                                    _getNameFromCache(message.senderId);

                                return _buildMessageBubble(
                                    message,
                                    isMe,
                                    username,
                                    showName,
                                    showAvatar,
                                    isFirstInGroup,
                                    isLastInGroup);
                              },
                            );
                          },
                        ),
                ),
              ),

              // Message input
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -1),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      //! Attachment button
                      // IconButton(
                      //   icon: Icon(
                      //     Icons.attach_file,
                      //     color: Colors.black,
                      //   ),
                      //   onPressed: () {
                      //     // Attachment functionality
                      //   },
                      // ),
                      // Message input field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: null,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      InkWell(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      leadingWidth: 40,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Row(
        children: [
          Hero(
            tag: 'profile_${widget.chatRoomId}',
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade700,
              radius: 20,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        //!call icon
        // IconButton(
        //   icon: const Icon(
        //     Icons.call,
        //     color: Colors.white,
        //   ),
        //   onPressed: () {
        //     // Phone call functionality
        //   },
        // ),
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {
            // Show chat options
            _showChatOptions(context);
          },
        ),
      ],
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search, color: Colors.black),
                title: const Text('Search in conversation'),
                onTap: () {
                  Navigator.pop(context);
                  // Search functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined,
                    color: Colors.black),
                title: const Text('Mute notifications'),
                onTap: () {
                  Navigator.pop(context);
                  // Mute functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text(
                  'Block user',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Block functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe, String username,
      bool showName, bool showAvatar, bool isFirstInGroup, bool isLastInGroup) {
    // Calculate bubble style based on position in group
    final bubbleRadius = BorderRadius.only(
      topLeft: Radius.circular(isFirstInGroup ? 16 : 4),
      topRight: Radius.circular(isFirstInGroup ? 16 : 4),
      bottomLeft: Radius.circular(isLastInGroup ? 16 : 4),
      bottomRight: Radius.circular(isLastInGroup ? 16 : 4),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8.0 : 2.0,
        bottom: isLastInGroup ? 8.0 : 2.0,
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showAvatar) ...[
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 16,
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (!isMe && !showAvatar) ...[
                // Leave space for avatar alignment while ensuring consistent width
                const SizedBox(width: 40),
              ],
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(
                    // Consistent alignment for messages - exactly 30 points from edge
                    left: !isMe ? 0 : 30,
                    right: isMe ? 0 : 30,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.black : Colors.white,
                    borderRadius: bubbleRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatMessageTime(message.timestamp),
                            style: TextStyle(
                              color: isMe
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.white.withOpacity(0.8),
                            )
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 0),
            ],
          ),
        ],
      ),
    );
  }
}
