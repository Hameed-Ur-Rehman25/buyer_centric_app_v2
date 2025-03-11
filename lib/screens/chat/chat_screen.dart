import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String postId;
  final String carName;

  const ChatScreen({
    super.key,
    required this.postId,
    required this.carName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat - $carName')),
      body: const Center(
        child: Text('Chat screen coming soon...'),
      ),
    );
  }
}
