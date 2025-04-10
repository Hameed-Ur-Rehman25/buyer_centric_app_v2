import 'package:buyer_centric_app_v2/models/message_model.dart';
import 'package:buyer_centric_app_v2/services/chat_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
        title: Text(
          widget.otherUserName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          final currentUserId = chatService.currentUserId;
          
          return Column(
            children: [
              // Messages list
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: chatService.getMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Send a message to start the conversation',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;

                        return _buildMessageBubble(message, isMe);
                      },
                    );
                  },
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      InkWell(
                        onTap: _isLoading ? null : _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.black,
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

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundColor: AppColor.black,
              radius: 16,
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColor.black : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
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
                  Text(
                    formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.8)
                          : Colors.black.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 24),
        ],
      ),
    );
  }
}
