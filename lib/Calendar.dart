import 'package:flutter/material.dart';
import 'package:snhu_tutorlink/Firestore/FirebaseQueries.dart';
import 'package:snhu_tutorlink/Models/Availability.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/ScheduleAppointment.dart';
import 'package:intl/intl.dart';

import 'Models/TutorAvailabilityCard.dart';

class Schedule {
  late bool isRepeating;
  late DateTime startDate;
  late DateTime endTime;
  late DateTime endDate;
  late String description;
  late String frequency;
  late String location;
  Schedule(bool isRepeating, DateTime startInput, DateTime endInput, DateTime endDate,
      String descInput, String freqInput, String location)
  {
    this.endDate = endDate;
    this.isRepeating = isRepeating;
    startDate = startInput;
    endTime = endInput;
    description = descInput;
    frequency = freqInput;
    this.location = location;
  }
}

List<Schedule> ScheduleList = [];

/*List<Schedule> ScheduleList = [
  //DateTime: year, month, day, hour, minute, second
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 14, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 18, 14, 00, 00), DateTime(2023, 10, 18, 16, 00, 00), "CETA 123", "TU, TH"),
  Schedule(DateTime(2023, 10, 20, 10, 00, 00), DateTime(2023, 10, 16, 20, 00, 00), "CETA 164", "FR"),
  Schedule(DateTime(2023, 10, 18, 11, 00, 00), DateTime(2023, 10, 18, 12, 00, 00), "CETA 315", "WE, FR"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),
  Schedule(DateTime(2023, 10, 16, 12, 00, 00), DateTime(2023, 10, 16, 12, 00, 00), "CETA 213", "MO, WE"),

];*/

int termEndDate = 20240428;
class TutorProfile extends StatelessWidget {
  @override
  //int index;
  late TutorAvailabilityCard tutor;
  //TutorProfile(this.index, {super.key});
  TutorProfile(this.tutor, {super.key});
  Widget build(BuildContext context){
    ScheduleList = [];
    final FirebaseQueries queries = FirebaseQueries();
    final Future<List<Availability>> t = Future(() async => await queries.getTutorAvailabilities(tutor.tutor.tutorReference ?? ""));
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
                  CircleAvatar(foregroundImage: NetworkImage(tutorList[0].photo),
                    radius: 60,),
                  SizedBox(width: 14,),
                  Expanded(child: Align(alignment: Alignment.center,
                      child: Column(
                        children: [
                          Text("${tutor.tutor.firstName} ${tutor.tutor.lastName}", style: TextStyle(fontSize: 18),),
                          Text(tutor.tutor.coursesTutored!.first),
                          Text(tutor.tutor.aboutMe)
                        ],
                      )
                  ))
                ],
              )
          ),
          Expanded(child: FutureBuilder<List<Availability>>(
              future: t,
              builder: (BuildContext context,  AsyncSnapshot<List<Availability>> snapshot){
                List<Availability> tempData = snapshot.data ?? [];
                if(snapshot.hasData){
                  for(Availability item in tempData){
                    ScheduleList.add(Schedule(item.isRepeating, item.startTime, item.endTime, item.endDate, item.location, item.dateAbbreviation ?? "", item.location));
                  }
                  return SfCalendar(
                      showDatePickerButton: true,
                      dataSource: MeetingDataSource(getAppointments()),
                      view: CalendarView.week,
                      onTap: (details) {
                        if (details.targetElement == CalendarElement.appointment){
                          Appointment app = details.appointments![0];
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ScheduleState(title: "", tutor: tutor.tutor, appointment: app, index: 0)));
                        }
                      });
                }else{
                  return const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  );
                }
              }
          )
          )],
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

List<Appointment> getAppointments(){
  List<Appointment> meetings = <Appointment>[];
  for(Schedule appointment in ScheduleList){
    if(appointment.isRepeating){
      meetings.add(Appointment(
          startTime: appointment.startDate,
          endTime: appointment.endTime,
          subject: appointment.description,
          location: appointment.location,
          color: Colors.blue,
          //recurrenceRule: '${'FREQ=WEEKLY;BYDAY=' + appointment.frequency + ';UNTIL=20240428'}',
          recurrenceRule: '${'FREQ=WEEKLY;BYDAY=' + appointment.frequency + ';UNTIL='+DateFormat('yyyyMMdd').format(appointment.endDate)}'

      ));
    }else{
      meetings.add(Appointment(
          startTime: appointment.startDate,
          endTime: appointment.endTime,
          subject: appointment.description,
          location: appointment.location,
          color: Colors.blue
      ));
    }

  }
  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source ){
    appointments = source;
  }
}