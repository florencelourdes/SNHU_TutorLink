import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/Calendar.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'Firestore/FirebaseQueries.dart';
import 'Models/TutorAvailabilityCard.dart';
import 'Ryan_Message_History.dart';
import 'settings.dart';
import 'main.dart';
import 'TutorDisplay.dart';


class FilterResults{
  final String NameFilter;
  final String ClassFilter;

  FilterResults(this.NameFilter, this.ClassFilter);
}

List<bool> dayOfTheWeek = [false, false, false, false, false];

class TutorState extends StatefulWidget {
  const TutorState({super.key, required this.title});
  final String title;

  @override
  TutorDisplay createState() => TutorDisplay();
}

class TutorDisplay extends State<TutorState> { //The home page where you can look at the available tutors
  @override

  late TextEditingController filterControl;
  late TextEditingController nameFilterControl;
  FirebaseQueries firebaseQueries = FirebaseQueries();
  late Future<List<TutorAvailabilityCard>> _getAvailabilities;
  DateTime date = DateTime(2024, 11, 7);

  @override
  void initState(){
    super.initState();
    nameFilterControl = TextEditingController();
    filterControl = TextEditingController();
    FirebaseQueries firestoreQuieries = FirebaseQueries();
    _getAvailabilities = Future(() async => await firestoreQuieries.getAvailabilitiesOnDate(date));
  }

  @override
  void dispose()
  {
    nameFilterControl.dispose();
    filterControl.dispose();
    super.dispose();
  }
  late FilterResults results;
  String nameFilterString = '';
  String classFilterString = '';
  List<String> dateStrings = [];
  late List<Tutors> filteredList = tutorList.where((i) =>
        (i.classes.contains(classFilterString)) &&
        (i.name.contains(nameFilterString)))
      .toList();

  void dropDownCallback(String? selectedValue){
    if(selectedValue is String){
      setState(() {
        if(_dropdownValue != selectedValue) {
          {
            _dropdownValue = selectedValue;
            date = DateFormat('MM/dd/yy').parse(selectedValue);
            _getAvailabilities = Future(() async => await firebaseQueries.getAvailabilitiesOnDate(date));
          }
        }
      });
    }
  }
  String _dropdownValue = "11/7/24"; //WIP Dropdown menu
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


      body: Column(children: [ //Body code
        const Align(alignment: Alignment.topLeft, child: Text("Drop in Schedule", style: TextStyle(fontSize: 32),),),
        const Align(alignment: Alignment.topLeft, child: Text("Drop-in sessions are conducted as in-person, group sessions at the designated Peer Educator location", style: TextStyle(fontSize: 16),),),
        Row(children: [
          DropdownButton( //WIP Dropdown button how does this work??
            underline: Container(height: 2, color: Colors.black),
            value: _dropdownValue,
            items: const[
              DropdownMenuItem(value: "11/7/24",child: Text("11/7/24"),),
              DropdownMenuItem(value: "11/14/24",child: Text("11/14/24"),),
              DropdownMenuItem(value: "11/21/24",child: Text("11/21/24"),),
              DropdownMenuItem(value: "11/28/24",child: Text("11/28/24"),),
            ], onChanged: dropDownCallback,),
          const Spacer(),
          FloatingActionButton(
            onPressed: () async {
              results = await openFilterMenu();
              String DateText = determineDate();
              setState(() => filteredList = tutorList.where((i) =>
              (i.classes.contains(results.ClassFilter)) &&
                  (i.name.contains(results.NameFilter)) &&
                  (i.dayOfWeek.contains(DateText)))
                  .toList());
            },
            backgroundColor: Color(0xffFDB913),
            child: Icon(Icons.tune, size: 40, color: Colors.black,),),
          const SizedBox(width: 20,)
        ],),

        const SizedBox(height: 20),

        Flexible(child: FutureBuilder<List<TutorAvailabilityCard>>(
          future: _getAvailabilities,
          builder: (BuildContext context,  AsyncSnapshot<List<TutorAvailabilityCard>> snapshot){
            if(snapshot.hasData){
              List<TutorAvailabilityCard>? availabilities = snapshot.data;
              return GridView.builder( //Flexible gridview that can take any number of inputs
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, //Two spaces per row
                    mainAxisSpacing: 15, //This keeps the grid from being right next to each other
                    crossAxisSpacing: 15,
                    childAspectRatio: 2.5 //Maintain an aspect ratio so there's roughly four visible at all times
                ),
                itemCount: availabilities?.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TutorProfile(availabilities![index]))),
                    child: Container(
                      decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.grey),
                      child: Row(
                          children: [
                            const SizedBox(width: 10), //Size box for spacing
                            CircleAvatar(foregroundImage: NetworkImage(tutorList[index].photo),
                              backgroundColor: Colors.white,), //Avatar
                            const SizedBox(width: 20,), //More spacing
                            Align(alignment: Alignment.center, //Text box for the Name, classes, and times
                                child: Column(children: [const SizedBox(height: 10,),
                                  Text("${availabilities![index].tutor.firstName} ${availabilities[index].tutor.lastName}", style: TextStyle(fontSize: 15),),
                                  Text(availabilities![index].tutor.coursesTutored!.first),
                                  Text(availabilities![index].availibility.getAvailableTimeRange())]
                                  //Text(availabilities![index].getAvailableTimeRange())]
                                )
                            )
                          ]
                      ),
                    ),
                  );
                },
              );
            }else {
              return const SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(),
              );
            }
          },
        )
        ),


      ],
      ),


      bottomNavigationBar: BottomNavigationBar( //Navigation bar. Something like this will be on every page
        backgroundColor: Color(0xffFDB913),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "")
        ],
        onTap: (int index) {
          if (index == 2) { // Index 2 corresponds to the "settings" icon
            // Navigate to the settings page when the "settings" icon is tapped.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
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
  Future openFilterMenu() => showDialog(context: context, builder: (BuildContext context) => AlertDialog(
    title: Text("Filters"),
    content: Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: "Filter by Class"),
          controller: filterControl,
        ),
        TextFormField(
          decoration: const InputDecoration(labelText: "Filter by Name"),
          controller: nameFilterControl,
        ),
        CheckboxListTile(value: dayOfTheWeek[0], onChanged: (bool? newValue){
          setState(() {
            if (newValue != null){
              dayOfTheWeek[0] = newValue;
            }
          });
        },title: Text("Monday")),
        CheckboxListTile(value: dayOfTheWeek[1], onChanged: (bool? newValue){
          setState(() {
            if (newValue != null){
              dayOfTheWeek[1] = newValue;
            }
          });
        }, title: Text("Tuesday")),
        CheckboxListTile(value: dayOfTheWeek[2], onChanged: (bool? newValue){
          setState(() {
            if (newValue != null){
              dayOfTheWeek[2] = newValue;

            }
          });
        }, title: Text("Wednesday")),
        CheckboxListTile(value: dayOfTheWeek[3], onChanged: (bool? newValue){
          setState(() {
            if (newValue != null){
              dayOfTheWeek[3] = newValue;
            }
          });
        }, title: Text("Thursday")),
        CheckboxListTile(value: dayOfTheWeek[4], onChanged: (bool? newValue){
          setState(() {
            if (newValue != null){
              dayOfTheWeek[4] = newValue;
            }
          });
        }, title: Text("Friday")),
      ],
    ),
    actions: [
      FloatingActionButton(onPressed: () => Navigator.of(context).pop(FilterResults(nameFilterControl.text, filterControl.text)))
    ]
  )
  );

}

class AppointmentDataSource extends CalendarDataSource{
  AppointmentDataSource(List<Appointment> source){
    appointments = source;
  }
}

String determineDate(){
  String DateFilter = "";
  bool isFirstDay = true;
  if (dayOfTheWeek[0] == true){
    DateFilter += "MO";
    isFirstDay = false;
  }
  if (dayOfTheWeek[1] == true){
    if (!isFirstDay)
    {
      DateFilter += ", ";
    }
    DateFilter += "TU";
    isFirstDay = false;

  }
  if (dayOfTheWeek[2] == true){
    if (!isFirstDay)
    {
      DateFilter += ", ";
    }
    DateFilter += "WE";
    isFirstDay = false;

  }
  if (dayOfTheWeek[3] == true){
    if (!isFirstDay)
    {
      DateFilter += ", ";
    }
    DateFilter += "TH";
    isFirstDay = false;

  }
  if (dayOfTheWeek[4] == true){
    if (!isFirstDay)
    {
      DateFilter += ", ";
    }
    DateFilter += "FR";
  }

  log(DateFilter);
  return DateFilter;
}