import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snhu_tutorlink/Chat/ChatBubble.dart';
import 'package:snhu_tutorlink/Chat/chat_service.dart';
import 'dart:developer';


class RyanChatRoom extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserID;
  const RyanChatRoom({
    super.key,
    required this.recieverUserEmail,
    required this.recieverUserID,
  });

  @override
  State<RyanChatRoom> createState() => RyanChatState();

}


class RyanChatState extends State<RyanChatRoom>{
  final TextEditingController message = TextEditingController();
  final ChatService chatService = ChatService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestone = FirebaseFirestore.instance;

  void sendMessage() async {
    if (message.text.isNotEmpty){
      await chatService.sendMessage(widget.recieverUserID, message.text);
      message.clear();
    }
  }
  
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Column(
        children: [
          Expanded(
              child: buildMessageList(),
          ),

          buildInput(),
        ],
      )
    );
  }

  Widget buildMessageList() {

    return StreamBuilder(
        stream: chatService.getMessages(
            widget.recieverUserID, auth.currentUser!.uid),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Text('ERROR:${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting)
            {
              return const Text('Loading...');
            }

          return ListView(
            children: snapshot.data!.docs.map((doccument) => buildMessageItem(doccument)).toList(),
          );
        }
        );
  }

  Widget buildMessageItem(DocumentSnapshot documentSnapshot){
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    var alignment  = (data['senderId'] == auth.currentUser!.uid)
    ? Alignment.centerRight
        : Alignment.centerLeft;
    if (data['senderId'] != auth.currentUser!.uid)
      {
        UpdateRead(documentSnapshot.id);
      }
    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: (data['senderId'] == auth.currentUser!.uid)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
          mainAxisAlignment: (data['senderId'] == auth.currentUser!.uid)
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            ChatBubble(message: data['message'],
            isUser: (data['senderId'] == auth.currentUser!.uid)),
            Text(data['senderEmail'])
          ],
        ),
      )
    );
  }
  Future<void> UpdateRead(String messageId) async{
    log(messageId);
    await FirebaseFirestore.instance.collection('ryan_chat_room').doc("UOH7pnFKBzdHqAYyCKpi38nH0FG3_sWpxSNetwUOaQccJ15fa7ZozTAI3").collection('messages').doc(messageId).update({"isSeen": true});
  }
  Widget buildInput()
  {
    return Row(
      children: [
        Expanded(child:
            TextField(
              controller: message,
              obscureText: false,
            )
        ),
        IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.arrow_upward, size: 30,))
      ],
    );
  }
}
