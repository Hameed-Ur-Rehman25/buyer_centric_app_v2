import 'package:buyer_centric_app_v2/models/chat_room_model.dart';
import 'package:buyer_centric_app_v2/services/chat_service.dart';
import 'package:buyer_centric_app_v2/theme/colors.dart';
import 'package:buyer_centric_app_v2/utils/date_time_utils.dart';
import 'package:buyer_centric_app_v2/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = context.screenWidth;
    double screenHeight = context.screenHeight;
    double appBarHeight = screenHeight * 0.16; // 16% of screen height
    double searchBarHeight = screenHeight * 0.06; // 6% of screen height
    double searchBarPadding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new chat
        },
        backgroundColor: AppColor.greenColor,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // App bar with curved bottom
          Container(
            height: appBarHeight,
            decoration: const BoxDecoration(
              color: AppColor.greenColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.006),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),

          // Search Bar positioned at bottom of app bar
          Positioned(
            top: appBarHeight - searchBarHeight / 2,
            left: searchBarPadding,
            right: searchBarPadding,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              height: searchBarHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search conversations...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat list
          Padding(
            padding: EdgeInsets.only(top: appBarHeight + searchBarHeight / 2),
            child: Consumer<ChatService>(
              builder: (context, chatService, _) {
                return StreamBuilder<List<ChatRoom>>(
                  stream: chatService.getChatRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColor.greenColor),
                        )
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    
                    final chatRooms = snapshot.data ?? [];
                    
                    if (chatRooms.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline, 
                              size: 80, 
                              color: AppColor.greenColor.withOpacity(0.7)
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18, 
                                color: AppColor.greenColor,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 40),
                              child: Text(
                                'Start chatting with sellers or buyers to see your conversations here',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Start new chat action
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Start a conversation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.greenColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24, 
                                  vertical: 12
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    
                    return ListView.separated(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: chatRooms.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
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
                            backgroundColor: AppColor.greenColor,
                            radius: 24,
                            child: Text(
                              otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  otherUserName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatChatTime(room.lastMessageTimestamp),
                                style: const TextStyle(
                                  color: Colors.grey, 
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          subtitle: room.lastMessageContent.isNotEmpty 
                            ? RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  children: [
                                    if (isLastMessageFromMe)
                                      TextSpan(
                                        text: 'You: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.greenColor,
                                        ),
                                      ),
                                    TextSpan(text: room.lastMessageContent),
                                  ],
                                ),
                              )
                            : const Text(
                                'Start a conversation', 
                                style: TextStyle(
                                  fontStyle: FontStyle.italic, 
                                  color: Colors.grey
                                )
                              ),
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
          ),
        ],
      ),
    );
  }
} 