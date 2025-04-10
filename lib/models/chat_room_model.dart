class ChatRoom {
  final String id;
  final List<String> userIds;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final DateTime lastMessageTimestamp;
  final Map<String, String> userNames; // Map of userId to username

  ChatRoom({
    required this.id,
    required this.userIds,
    required this.lastMessageContent,
    required this.lastMessageSenderId,
    required this.lastMessageTimestamp,
    required this.userNames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userIds': userIds,
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTimestamp': lastMessageTimestamp.toIso8601String(),
      'userNames': userNames,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map, String documentId) {
    return ChatRoom(
      id: documentId,
      userIds: List<String>.from(map['userIds'] ?? []),
      lastMessageContent: map['lastMessageContent'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      lastMessageTimestamp: map['lastMessageTimestamp'] != null
          ? DateTime.parse(map['lastMessageTimestamp'])
          : DateTime.now(),
      userNames: Map<String, String>.from(map['userNames'] ?? {}),
    );
  }
} 