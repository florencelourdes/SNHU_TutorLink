import 'package:flutter/material.dart';
import 'package:snhu_tutorlink/Firestore/FirebaseQueries.dart';
import 'package:snhu_tutorlink/Models/Availability.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/Calendar.dart';
import 'package:intl/intl.dart';
import 'Chat/chat_service.dart';
import 'Models/Tutor.dart';


class ScheduleState extends StatefulWidget {
  final Tutor tutor;
  final Appointment appointment;
  const ScheduleState({super.key, required this.tutor, required this.appointment, required this.title, required this.index});
  //const ScheduleState({super.key, required this.title, required this.index});
  final String title;
  final int index;

  @override
  State<ScheduleState> createState() => ScheduleAppointment(index, tutor, appointment);
}



class ScheduleAppointment extends State<ScheduleState> {
  //The home page where you can look at the available tutors
  final TextEditingController details = TextEditingController();
  final ChatService chatService = ChatService();
  final Appointment appointment;
  @override
  int index;
  Tutor tutor;

  void dropDownCallback(String? selectedValue){
    if(selectedValue is String){
      setState(() {
        dropDownCallback(selectedValue);
      });
    }
  }
  ScheduleAppointment(this.index, this.tutor, this.appointment);

  String locationString = "CETA 230";
  String detailsString = "";
  String selectedTimeSlot = "";

  List<String> timeslots = [];

  Future<List<String>> generateTimeSlots() async {
    String startDate = "${appointment.startTime.year}-${appointment.startTime.month}-${appointment.startTime.day}";
    FirebaseQueries queries = FirebaseQueries();
    List<String> unavailableTimeslots = await queries.getUnavailableTimeslots(appointment.notes ?? "", startDate);
    timeslots = [];
    DateTime current = appointment.startTime;
    while(current.isBefore(appointment.endTime)){
      if(!unavailableTimeslots.contains(DateFormat('h:mm').format(current))) {
        timeslots.add(DateFormat('h:mm a').format(current));
      }
      current = current.add(const Duration(minutes: 30));
    }

    if(selectedTimeSlot == ""){
      selectedTimeSlot = timeslots.first;
    }

    return timeslots;
  }

  @override
  void initState(){
    super.initState();
  }

  void sendMessage() async {
    await chatService.sendMessage("${tutor.tutorReference}",
        "Hello there! My name is Ryan Black, I would like to meet with ${tutor.firstName} ${tutor.lastName}"
            " for tutoring at $selectedTimeSlot at $locationString. "
            "Here are some details about my meeting: $detailsString");
  }

  Widget build(BuildContext context) {
    locationString = appointment.location ?? "CETA 230";
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
            Text("Schedule an appointment with ${tutor.firstName} ${tutor.lastName}",
              style: TextStyle(fontSize: 20),),
            FutureBuilder<List<String>>(
                future: generateTimeSlots(),
                builder: (BuildContext context,  AsyncSnapshot<List<String>> snapshot){
                  if(snapshot.hasData){
                    return DropdownButton<String>( //WIP Dropdown button how does this work??
                      underline: Container(height: 2, color: Colors.black),
                      value: selectedTimeSlot /*timeslots.first*/,
                      isExpanded: true,
                      items: timeslots.map<DropdownMenuItem<String>>((timeslot){
                        return(DropdownMenuItem<String>(
                            value: timeslot,
                            child: Text(timeslot)
                        ));
                      }).toList(),
                      onChanged: (String? value) {
                        // This is called when the user selects an item.
                        setState(() {
                          selectedTimeSlot = value!;
                        });
                      },);
                  }else{
                    return DropdownButton( //WIP Dropdown button how does this work??
                        underline: Container(height: 2, color: Colors.black),
                      value: "temp",
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: "temp", child: Text("Timeslots"),),
                      ],
                      onChanged: null
                    );
                  }
                }
            ),
            DropdownButton( //WIP Dropdown button how does this work??
                underline: Container(height: 2, color: Colors.black),
                value: locationString,
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: locationString, child: Text(locationString),),
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
                  content: Text("Your appointment with ${tutor.firstName} ${tutor.lastName} has been confirmed!"),
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