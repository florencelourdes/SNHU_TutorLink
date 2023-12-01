import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/Calendar.dart';

import 'Chat/chat_service.dart';


class ScheduleState extends StatefulWidget {

  const ScheduleState({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  State<ScheduleState> createState() => ScheduleAppointment(index);
}



class ScheduleAppointment extends State<ScheduleState> {
  //The home page where you can look at the available tutors
  final TextEditingController details = TextEditingController();
  final ChatService chatService = ChatService();
  @override
  int index;

  void dropDownCallback(String? selectedValue){
    if(selectedValue is String){
      setState(() {
        dropDownCallback(selectedValue);
      });
    }
  }
  ScheduleAppointment(this.index);


  String timeString = "11:00";
  String locationString = "CETA 230";
  String detailsString = "";

  void sendMessage() async {
    await chatService.sendMessage("UOH7pnFKBzdHqAYyCKpi38nH0FG3",
        "Hello there! My name is Ryan Black, I would like to meet with ${tutorList[index].name} for tutoring at $timeString at $locationString. "
            "Here are some details about my meeting: $detailsString");
  }

  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Align( //Title Bar
            alignment: Alignment.bottomLeft,
            child: Image(image: NetworkImage(
                "https://dlmrue3jobed1.cloudfront.net/uploads/school/SouthernNewHampshireUniversity/snhu_initials_rgb_pos.png"),
              width: 300,
              height: 100,)
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Color(0xff009DEA)),),),


      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  foregroundImage: NetworkImage(tutorList[index].photo),
                  radius: 70,),
                SizedBox(width: 30),
                CircleAvatar(foregroundImage: NetworkImage(
                    "https://static-00.iconduck.com/assets.00/user-icon-2048x2048-ihoxz4vq.png"),
                  radius: 70,)
              ],
            ),
            SizedBox(height: 15),
            Text("Schedule an appointment with " + tutorList[index].name,
              style: TextStyle(fontSize: 20),),
            DropdownButton( //WIP Dropdown button how does this work??
                underline: Container(height: 2, color: Colors.black),
                value: timeString,
                isExpanded: true,
                items: const[
                  DropdownMenuItem(value: "11:00", child: Text("11:00"),),
                  DropdownMenuItem(value: "11:30", child: Text("11:30"),),
                  DropdownMenuItem(value: "12:00", child: Text("12:00"),),
                  DropdownMenuItem(value: "12:30", child: Text("12:30"),),
                ],
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    timeString = value!;
                  });
                },),
            DropdownButton( //WIP Dropdown button how does this work??
                underline: Container(height: 2, color: Colors.black),
                value: locationString,
                isExpanded: true,
                items: const[
                  DropdownMenuItem(value: "CETA 230", child: Text("CETA 230"),),
                  DropdownMenuItem(
                    value: "Frost 110", child: Text("Frost 110"),),
                ],
                onChanged: (String? value) {
                  // This is called when the user selects an item.
                  setState(() {
                    locationString = value!;
                  });
                },),
            TextFormField(decoration: const InputDecoration(
                labelText: 'Details'
            ),
            onChanged: (String? value) {
              setState(() {
                detailsString = value!;
              });
            },),
            ElevatedButton(onPressed: () {
              showDialog(context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("Confirmed!"),
                  content: Text("Your appointment with " + tutorList[index].name + " has been confirmed!"),
                  actions: [
                    ElevatedButton(onPressed: () {
                      sendMessage();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "")));
                    }

                        ,
                        child: Text("Return to home"))
                  ],
                ));
            },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text("SCHEDULE"))
          ],
        ),
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
}