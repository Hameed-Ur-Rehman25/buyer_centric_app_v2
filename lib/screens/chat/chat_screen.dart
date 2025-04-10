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
    Key? key,
    required this.chatRoomId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  // Cache of usernames
  final Map<String, String> _usernameCache = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Pre-cache the other user's name
    _loadUserNames();
  }

  void _loadUserNames() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chatService = Provider.of<ChatService>(context, listen: false);
      if (chatService.currentUserId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(chatService.currentUserId)
            .get();
        
        final currentUsername = userDoc.data()?['username'] ?? 'You';
        _usernameCache[chatService.currentUserId!] = currentUsername;
      }

      try {
        // Get other user ID from chatRoom
        final chatRoomDoc = await FirebaseFirestore.instance
            .collection('chatRooms')
            .doc(widget.chatRoomId)
            .get();

        if (chatRoomDoc.exists && chatRoomDoc.data() != null) {
          final userNames = chatRoomDoc.data()?['userNames'] as Map<String, dynamic>?;
          if (userNames != null) {
            userNames.forEach((userId, username) {
              _usernameCache[userId] = username.toString();
            });
          }
        }
      } catch (e) {
        print('Error loading user names: $e');
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _getUserName(String userId) async {
    // Check cache first
    if (_usernameCache.containsKey(userId)) {
      return _usernameCache[userId]!;
    }

    final chatService = Provider.of<ChatService>(context, listen: false);
    if (userId == chatService.currentUserId) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      String username = 'You';
      if (userDoc.exists && userDoc.data() != null) {
        username = userDoc.data()?['username'] ?? username;
      }
      
      _usernameCache[userId] = username;
      return username;
    }

    try {
      // Try to get from usernames collection first (faster lookup)
      final usernameDoc = await FirebaseFirestore.instance
          .collection('usernames')
          .doc(userId)
          .get();
      
      if (usernameDoc.exists && usernameDoc.data() != null) {
        final username = usernameDoc.data()?['username'] as String?;
        if (username != null && username.isNotEmpty) {
          _usernameCache[userId] = username;
          return username;
        }
      }
      
      // Try to get from Firestore users collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final username = userDoc.data()?['username'] as String?;
        if (username != null && username.isNotEmpty) {
          _usernameCache[userId] = username;
          // Save to usernames collection for faster lookup next time
          await FirebaseFirestore.instance.collection('usernames').doc(userId).set({
            'username': username,
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return username;
        }
      }

      // Try to get from chat room data
      final chatRoomDoc = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(widget.chatRoomId)
          .get();

      if (chatRoomDoc.exists && chatRoomDoc.data() != null) {
        final Map<String, dynamic>? userNames = chatRoomDoc.data()?['userNames'] as Map<String, dynamic>?;
        
        if (userNames != null && userNames.containsKey(userId)) {
          final username = userNames[userId] as String;
          _usernameCache[userId] = username;
          return username;
        }
      }
    } catch (e) {
      print('Error fetching username: $e');
    }

    // Default fallback
    final shortId = userId.length > 5 ? userId.substring(0, 5) : userId;
    final username = 'User $shortId';
    _usernameCache[userId] = username;
    
    // Store this default name in the cache collection
    try {
      await FirebaseFirestore.instance.collection('usernames').doc(userId).set({
        'username': username,
        'isDefault': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving default username: $e');
    }
    
    return username;
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ChatService>(context, listen: false)
          .sendMessage(widget.chatRoomId, messageText);
          
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColor.greenColor,
              radius: 18,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                widget.otherUserName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
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
                  child: StreamBuilder<List<Message>>(
                    stream: chatService.getMessages(widget.chatRoomId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.greenColor),
                        ));
                      }
  
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
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
                                  color: AppColor.greenColor.withOpacity(0.7)
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    color: AppColor.greenColor,
                                    fontWeight: FontWeight.w500
                                  ),
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
                        padding: const EdgeInsets.all(16),
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
                            final isPrevSameSender = prevMessage.senderId == message.senderId;
                            // If same sender and messages are within 5 minutes, group them
                            if (isPrevSameSender && 
                                message.timestamp.difference(prevMessage.timestamp).inMinutes < 5) {
                              showName = false;
                              showAvatar = false;
                              isFirstInGroup = false;
                            }
                          }
                          
                          if (index > 0) {
                            final nextMessage = messages[index - 1];
                            final isNextSameSender = nextMessage.senderId == message.senderId;
                            // If next message is from same sender and within 5 minutes, this isn't last in group
                            if (isNextSameSender && 
                                nextMessage.timestamp.difference(message.timestamp).inMinutes < 5) {
                              isLastInGroup = false;
                            }
                          }
  
                          return FutureBuilder<String>(
                            future: _getUserName(message.senderId),
                            builder: (context, usernameSnapshot) {
                              final username = usernameSnapshot.data ?? 
                                  (isMe ? 'You' : (message.senderId.length > 5 ? 'User ${message.senderId.substring(0, 5)}' : message.senderId));
                              
                              return _buildMessageBubble(
                                message, 
                                isMe, 
                                username, 
                                showName,
                                showAvatar,
                                isFirstInGroup,
                                isLastInGroup
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // Message input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
                      // Attachment button
                      IconButton(
                        icon: Icon(
                          Icons.attach_file, 
                          color: AppColor.greenColor,
                        ),
                        onPressed: () {
                          // Attachment functionality
                        },
                      ),
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
                            color: AppColor.greenColor,
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
        }
      ),
    );
  }

  Widget _buildMessageBubble(
    Message message, 
    bool isMe, 
    String username, 
    bool showName,
    bool showAvatar,
    bool isFirstInGroup,
    bool isLastInGroup
  ) {
    // Calculate bubble style based on position in group
    final bubbleRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe || !isLastInGroup ? 16 : 4),
      bottomRight: Radius.circular(isMe && isLastInGroup ? 4 : 16),
    );
    
    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8.0 : 2.0,
        bottom: isLastInGroup ? 8.0 : 2.0,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Show username if needed
          if (showName)
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 40,
                right: isMe ? 16 : 0,
                bottom: 2,
              ),
              child: Text(
                username,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isMe ? AppColor.greenColor : Colors.grey.shade800,
                ),
              ),
            ),
            
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showAvatar) ...[
                CircleAvatar(
                  backgroundColor: AppColor.greenColor,
                  radius: 16,
                  child: Text(
                    username.isNotEmpty
                        ? username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ] else if (!isMe && !showAvatar) ...[
                // Leave space for avatar alignment
                const SizedBox(width: 40),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe 
                        ? AppColor.greenColor 
                        : Colors.white,
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
              if (isMe && showAvatar) const SizedBox(width: 24),
            ],
          ),
        ],
      ),
    );
  }
}
