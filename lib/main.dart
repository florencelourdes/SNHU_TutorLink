import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snhu_tutorlink/Message_History.dart';
import 'package:snhu_tutorlink/Ryan_Message_History.dart';
import 'package:snhu_tutorlink/TutorDisplay.dart';
import 'settings.dart';
import 'userData.dart';
import 'Ryan_Chat_Room.dart';
import 'login.dart';
import 'dart:developer';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCRL6F7ScVBrB2cfkKmWYkxsWBcudBGDSM",
      projectId: "tutorlink-9cb99",
      storageBucket: "tutorlink-9cb99.appspot.com",
      messagingSenderId: "785876527710",
      appId: "1:785876527710:android:4cf695408ea6c3139f22cf",
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserData(),
      child: const MyApp(),
    ),
  );
}

class Tutors{ //Basic class for tutors on the home page
  late String name;
  late String classes;
  late String photo;
  late String time;
  late String dayOfWeek;
  Tutors(String nameInput, String classInput, String imageInput, String timeInput, String DOWInput){
    name = nameInput;
    classes = classInput;
    photo = imageInput;
    time = timeInput;
    dayOfWeek = DOWInput;
  }
}

List<Tutors> tutorList = [ //Example list of tutors for testing purposes
  Tutors("Annie Brown", "MAT 255", "https://t3.ftcdn.net/jpg/02/65/18/30/360_F_265183061_NkulfPZgRxbNg3rvYSNGGwi0iD7qbmOp.jpg", "5:00 - 6:00", "MO, WE"),
  Tutors("Jeff Hartman", "IT 204", "https://thumbs.dreamstime.com/z/old-male-math-teacher-time-management-concept-senior-211792638.jpg?w=992", "11:00 - 1:00", "TU, TH"),
  Tutors("Albert Ross", "ENG 143", "https://media.istockphoto.com/id/690191634/photo/angry-teacher.jpg?s=170667a&w=0&k=20&c=6hXsCZOgwkWPDDtysAtvOtPE5lNRrbkHcVQ3wNrlC-I=", "8:00 - 10:00", "MO"),
  Tutors("Non Ame", "CS 201", "https://t3.ftcdn.net/jpg/02/65/18/30/360_F_265183061_NkulfPZgRxbNg3rvYSNGGwi0iD7qbmOp.jpg", "2:00 - 4:00", "TH, FR"),
  Tutors("Sherry Lyn", "ENG 143", "https://as2.ftcdn.net/v2/jpg/01/97/28/03/1000_F_197280335_EnKA1A5tJKci6o1FB5fvtWpMxH7QBOwG.jpg", "8:00 - 10:00", "FR"),
  Tutors("Paul Roberts", "CS 201", "https://thumbs.dreamstime.com/b/young-male-math-teacher-classroom-140745209.jpg", "2:00 - 4:00", "FR"),
  Tutors("Master Chief", "CS 117", "https://static.wikia.nocookie.net/deathbattle/images/a/a6/Portrait.masterchief.png/revision/latest/thumbnail/width/360/height/450?cb=20230415015344", "5:00 - 6:00", "MO, TU, WE"),
  Tutors("Franklin Miles", "MAT 201", "https://previews.123rf.com/images/michaeljung/michaeljung0906/michaeljung090600290/5125275-teacher.jpg", "5:00 - 6:00", "TU"),
  Tutors("Walter White", "SCI 401", "https://static.wikia.nocookie.net/inconsistently-heinous/images/0/06/WaltS4.png/revision/latest?cb=20220915143606", "3:30 - 4:30", "TH, FR"),
  Tutors("Mary Crane", "ENG 103", "https://t3.ftcdn.net/jpg/02/02/52/36/360_F_202523652_NqEMp50IkORLXlCmJXqgqRBLMW8xBHMP.jpg", "5:00 - 6:00", "TH"),
  Tutors("Shelly Greene", "SCI 103", "https://thumbs.dreamstime.com/z/female-teacher-25183858.jpg", "12:00 - 2:00", "FR"),
  Tutors("Jackie Welles", "MAT 255", "https://static.wikia.nocookie.net/cyberpunk/images/0/0f/Jackie_Welles_Infobox_CP2077.png/revision/latest?cb=20220217104153", "9:00 - 10:00", "TU, TH"),
  Tutors("Robert Francis", "SOC 201", "https://www.weareteachers.com/wp-content/uploads/teacher-stock-selfie-800x456.jpg", "6:00 - 8:00", "MO"),
  Tutors("Byleth Eisner", "HIS 205", "https://www.fe3h.com/assets/images/characters/small/byleth.webp", "2:00 - 6:00", "WE"),
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(),

    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  final FirebaseFirestore firestone = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void dropDownCallback(String? selectedValue){
    if(selectedValue is String){
      setState(() {
        dropDownCallback(selectedValue);
      });
    }
  }


  Widget buildList(BuildContext context){
    return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('ryan_chat_room').doc("Aq7HpHo76GZSLBukw30FoAzZmqC3_sWpxSNetwUOaQccJ15fa7ZozTAI3").collection('messages').where('isSeen', isEqualTo: false).where('recieverId', isEqualTo: _auth.currentUser!.uid).limit(3).snapshots(),
        builder: (context, snapshot){
          if (snapshot.hasError){
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading...");
          }
          return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(4),
              children: snapshot.data!.docs.map<Widget>((doc) => buildNotificationListItem(doc)).toList()
          );
        });
  }


  Widget buildNotificationListItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    log(data['senderEmail']);
    if (_auth.currentUser!.uid != data['senderId'] ) {
      return InkWell(
        child: Container(
          child: Column(
            children: [
              Text(data['senderEmail']),
              SizedBox(height: 4,),
              Text(data['message'], style: TextStyle(fontSize: 20), overflow: TextOverflow.ellipsis, maxLines: 1)
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12)
          ),
        ),
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RyanChatRoom(
                  recieverUserEmail: data['senderEmail'],
                  recieverUserID: data['senderId'])));
        },
      );

    } else {
      return Container();
    }
  }


  final String _dropdownValue = "11/7/24"; //WIP Dropdown menu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.bottomLeft,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage(title: "")),
              );
            },
            child: Image(
              image: NetworkImage(
                  "https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png"),
              width: 300,
              height: 100,
            ),
          ),
        ),
        flexibleSpace: Container(decoration: BoxDecoration(color: Color(0xff009DEA))),
      ),

      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Drop in Schedule",
              style: TextStyle(fontSize: 32),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Drop-in sessions are conducted as in-person, group sessions at the designated Peer Educator location",
              style: TextStyle(fontSize: 16),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Your most recent messages:",
              style: TextStyle(fontSize: 32),
            ),
          ),
          buildList(context)
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xffFDB913),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat),label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: ""),
        ],
        onTap: (int index) {
          if (index == 2) { // Index 2 corresponds to the "settings" icon
            // Navigate to the settings page when the "settings" icon is tapped.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }
          if (index == 1) { // Index 1 corresponds to the "Chat" icon
            // Navigate to the ChatScreen when the "Chat" icon is tapped.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RyanMessageState()),
            );
          }
          if(index == 0){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TutorState(title: "")), //change it to your setting page
            );
          }
        },
      ),
    );
  }
}
