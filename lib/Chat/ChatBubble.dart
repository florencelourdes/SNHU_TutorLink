import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: (isUser)
            ? Colors.blue
            : Colors.grey,

      ),
      child: Text(message, style: TextStyle(fontSize: 16),),
    );
  }
}