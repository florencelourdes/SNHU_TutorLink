import 'package:flutter/material.dart';
import 'package:snhu_tutorlink/ChatScreen.dart';

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MessagesPage(),
    );
  }
}

class Tutors {
  late String name;
  late String photo;
  Tutors(String nameInput, String imageInput) {
    name = nameInput;
    photo = imageInput;
  }
}

class MessagesPage extends StatelessWidget {
  final List<Tutors> chatList = [
    Tutors("Annie Brown", "https://t3.ftcdn.net/jpg/02/65/18/30/360_F_265183061_NkulfPZgRxbNg3rvYSNGGwi0iD7qbmOp.jpg"),
    Tutors("Jeff Hartman", "https://thumbs.dreamstime.com/z/old-male-math-teacher-time-management-concept-senior-211792638.jpg?w=992"),
    // Add more chat names here
  ];

  MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: ListView.builder(
        itemCount: chatList.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              // Display profile picture here, such as initials of the sender
              backgroundImage: NetworkImage(chatList[index].photo),
            ),
            title: Text(chatList[index].name),
            subtitle: Text('Last message goes here'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return ChatScreen(userName: chatList[index].name);
                  },
                ),
              );
              // Handle chat selection here
            },
          );
        },
      ),
    );
  }
}
