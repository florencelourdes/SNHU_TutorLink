import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Ryan_Chat_Room.dart';

class RyanMessageState extends StatefulWidget
{
  const RyanMessageState({super.key});
  @override
  State<RyanMessageState> createState() => RyanMessageHistory();
}

class RyanMessageHistory extends State<RyanMessageState>
{
  List results = [];
  List searchResults = [];
  String tutorToSearch= "";
  final TextEditingController TutorSearch = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override

  getClientList() async {
    var data = await FirebaseFirestore.instance.collection('users').orderBy('email').get();
    setState(() {
      results = data.docs;
    });
    getSearchedList();
  }

  getSearchedList(){
    var showResults = [];
    if(TutorSearch.text != ""){
      for(var ClientSnapshot in results){
        var email = ClientSnapshot['email'].toString().toLowerCase();
        if (email.contains(TutorSearch.text.toLowerCase()))
          {
            showResults.add(email);
          }
      }
    }
    else(
    showResults = results
    );

    setState(() {
      searchResults = showResults;
    });
  }

@override
void initState() {
    getClientList();
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Align( //Title Bar
            alignment: Alignment.bottomLeft,
            child: Image (image: NetworkImage("https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png"),
              width: 300,
              height: 100,)
        ),
        flexibleSpace: Container(decoration: BoxDecoration(color: Color(0xff009DEA)),),),


      body: Column(
        children: [
          Row(
            children: [
              Expanded(child:
              TextField(
                controller: TutorSearch,
                obscureText: false,
              )
              ),
              IconButton(
                onPressed: () async {
                  setState(() => tutorToSearch = TutorSearch.text);
              },
                icon: const Icon(Icons.arrow_upward, size: 30,))
              ],
          ),
          buildList(),
        ]
      ),


      bottomNavigationBar: BottomNavigationBar( //Navigation bar. Something like this will be on every page
        backgroundColor: Color(0xffFDB913),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "")
        ],),
    );
  }

  Widget buildList(){
    return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('users').where("email", arrayContains: tutorToSearch).snapshots(),
        builder: (context, snapshot){
          if (snapshot.hasError){
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading...");
          }
          return ListView.builder(
            itemCount: searchResults.length,
            shrinkWrap: true,
            itemBuilder: (context, index){
              if (_auth.currentUser!.email != results[index]['email']) {
                return ListTile(
                  title: Text(searchResults[index]['email']),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RyanChatRoom(
                            recieverUserEmail: searchResults[index]['email'],
                            recieverUserID: searchResults[index]['uid'])));
                  },
                );

              } else {
                return Container();
              }
            },
          );
        });
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        title: Text(data['email']),
        onTap: () {
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => RyanChatRoom(
              recieverUserEmail: data['email'],
              recieverUserID: data['uid'])));
        },
      );

    } else {
      return Container();
    }
  }

  
}