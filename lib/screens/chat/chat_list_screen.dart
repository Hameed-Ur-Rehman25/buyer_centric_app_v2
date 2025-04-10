import 'package:buyer_centric_app_v2/models/chat_room_model.dart';
import 'package:buyer_centric_app_v2/services/chat_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ChatService>(
        builder: (context, chatService, _) {
          return StreamBuilder<List<ChatRoom>>(
            stream: chatService.getChatRooms(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final chatRooms = snapshot.data ?? [];
              
              if (chatRooms.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start chatting with sellers or buyers',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: chatRooms.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final room = chatRooms[index];
                  final currentUserId = chatService.currentUserId;
                  
                  // Find the other user's ID and name
                  final otherUserId = room.userIds.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => 'Unknown',
                  );
                  
                  final otherUserName = room.userNames[otherUserId] ?? 'Unknown User';
                  final isLastMessageFromMe = room.lastMessageSenderId == currentUserId;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: AppColor.black,
                      child: Text(
                        otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      otherUserName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: room.lastMessageContent.isNotEmpty
                        ? RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.grey),
                              children: [
                                if (isLastMessageFromMe)
                                  const TextSpan(
                                    text: 'You: ',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                TextSpan(text: room.lastMessageContent),
                              ],
                            ),
                          )
                        : const Text('Start a conversation', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                    trailing: room.lastMessageContent.isNotEmpty
                        ? Text(
                            formatChatTime(room.lastMessageTimestamp),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          )
                        : null,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat-detail',
                        arguments: {
                          'chatRoomId': room.id,
                          'otherUserName': otherUserName,
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 