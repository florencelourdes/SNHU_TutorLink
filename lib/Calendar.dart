import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/ScheduleAppointment.dart';

class Schedule {
  late DateTime startDate;
  late DateTime endDate;
  late String description;
  late String frequency;
  Schedule(DateTime startInput, DateTime endInput, String descInput, String freqInput)
  {
    startDate = startInput;
    endDate = endInput;
    description = descInput;
    frequency = freqInput;
  }
}

List<Schedule> ScheduleList = [
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 14, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 18, 14, 00, 00), DateTime(2023, 10, 18, 16, 00, 00), "CETA 123", "TU, TH"),
  Schedule(DateTime(2023, 10, 20, 10, 00, 00), DateTime(2023, 10, 16, 20, 00, 00), "CETA 164", "FR"),
  Schedule(DateTime(2023, 10, 18, 11, 00, 00), DateTime(2023, 10, 18, 12, 00, 00), "CETA 315", "WE, FR"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),

];

int termEndDate = 20240428;

class TutorProfile extends StatelessWidget {
  @override
  int index;
  TutorProfile(this.index, {super.key});
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
          Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  CircleAvatar(foregroundImage: NetworkImage(tutorList[index].photo),
                    radius: 60,),
                  SizedBox(width: 14,),
                  Expanded(child: Align(alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text(tutorList[index].name),
                          Text(tutorList[index].classes),
                          Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.")
                        ],
                      )
                  ))
                ],
              )
          ),
          Expanded(child: SfCalendar(
            dataSource: MeetingDataSource(getAppointments(index)),
            view: CalendarView.week,
            onTap: (details) {if (details.targetElement == CalendarElement.appointment)
              {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ScheduleState(title: "", index: index)));
              }},

          ))
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
        ],),
    );
  }

}

List<Appointment> getAppointments(int currentIndex){
  List<Appointment> meetings = <Appointment>[];
  meetings.add(Appointment(
    startTime: ScheduleList[currentIndex].startDate,
    endTime: ScheduleList[currentIndex].endDate,
    subject: ScheduleList[currentIndex].description,
    color: Colors.blue,
    recurrenceRule: '${'FREQ=WEEKLY;BYDAY=' + ScheduleList[currentIndex].frequency + ';UNTIL=20240428'}'
  ));
  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source ){
    appointments = source;
  }
}

