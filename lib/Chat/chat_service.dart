import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Message.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestone = FirebaseFirestore.instance;

  Future<void> sendMessage(String recieverID, String message) async {
    final String currentUserId = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        recieverId: recieverID,
        message: message,
        timestamp: timestamp,
        isSeen: false);

    List<String> ids = [currentUserId, recieverID];
    ids.sort();
    String chatRoomId = ids.join("_");
    await firestone.collection('ryan_chat_room')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());


  }
  Stream<QuerySnapshot> getMessages(String userId, String otherUserID){
    List<String> ids = [userId, otherUserID];
    ids.sort();
    String chatRoomId = ids.join("_");

    return firestone.collection('ryan_chat_room')
        .doc(chatRoomId)
        .collection('messages').
    orderBy('timestamp', descending: false)
        .snapshots();
  }
}