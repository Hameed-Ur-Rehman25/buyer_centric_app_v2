import 'package:buyer_centric_app_v2/models/message_model.dart';
import 'package:buyer_centric_app_v2/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get all chat rooms for the current user
  Stream<List<ChatRoom>> getChatRooms() {
    if (currentUserId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('chatRooms')
        .where('userIds', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Create or get existing chat room between two users
  Future<String> createOrGetChatRoom(String otherUserId, String otherUserName) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Get current user's name
    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = userDoc.data()?['username'] ?? 'User';

    // Check if chat room already exists
    final querySnapshot = await _firestore
        .collection('chatRooms')
        .where('userIds', arrayContains: currentUserId)
        .get();
    
    for (var doc in querySnapshot.docs) {
      final List<dynamic> userIds = doc.data()['userIds'] ?? [];
      if (userIds.contains(otherUserId)) {
        // Update the userNames map in the existing chat room
        await _firestore.collection('chatRooms').doc(doc.id).update({
          'userNames.$otherUserId': otherUserName,
          'userNames.$currentUserId': currentUserName,
        });
        return doc.id;
      }
    }
    
    // Create new chat room
    final chatRoom = ChatRoom(
      id: '',
      userIds: [currentUserId!, otherUserId],
      lastMessageContent: '',
      lastMessageSenderId: '',
      lastMessageTimestamp: DateTime.now(),
      userNames: {
        currentUserId!: currentUserName,
        otherUserId: otherUserName,
      },
    );
    
    final docRef = await _firestore.collection('chatRooms').add(chatRoom.toMap());
    return docRef.id;
  }

  // Get messages for a specific chat room
  Stream<List<Message>> getMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList());
  }

  // Send message and update chat room's last message
  Future<void> sendMessage(String chatRoomId, String content) async {
    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }
    
    final message = Message(
      senderId: currentUserId!,
      content: content,
      timestamp: DateTime.now(),
    );
    
    // Add message to chat room's messages collection
    await _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toMap());
    
    // Update chat room's last message info
    await _firestore.collection('chatRooms').doc(chatRoomId).update({
      'lastMessageContent': content,
      'lastMessageSenderId': currentUserId,
      'lastMessageTimestamp': message.timestamp.toIso8601String(),
    });
  }
}
