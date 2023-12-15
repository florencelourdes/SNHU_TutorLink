import 'package:flutter/material.dart';
import 'package:snhu_tutorlink/Firestore/FirebaseQueries.dart';
import 'package:snhu_tutorlink/Models/Availability.dart';
import 'package:snhu_tutorlink/settings.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:snhu_tutorlink/main.dart';
import 'package:snhu_tutorlink/ScheduleAppointment.dart';
import 'package:intl/intl.dart';

import 'Models/TutorAvailabilityCard.dart';
import 'NavAppBar.dart';
import 'Ryan_Message_History.dart';
import 'TutorDisplay.dart';

List<Availability> ScheduleList = [];

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
  late TutorAvailabilityCard tutor;
  TutorProfile(this.tutor, {super.key});

  Widget build(BuildContext context){
    ScheduleList = [];
    final FirebaseQueries queries = FirebaseQueries();
    final Future<List<Availability>> availableTimeslots = Future(() async => await queries.getTutorAvailabilities(tutor.tutor.tutorReference ?? ""));
    return Scaffold(
      appBar: const NavAppBar(),
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
              future: availableTimeslots,
              builder: (BuildContext context,  AsyncSnapshot<List<Availability>> snapshot){
                List<Availability> tempData = snapshot.data ?? [];
                if(snapshot.hasData){
                  for(Availability item in tempData){
                    ScheduleList.add(item);
                  }
                  return SfCalendar(
                      showDatePickerButton: true,
                      dataSource: MeetingDataSource(getAppointments()),
                      view: CalendarView.week,
                      onTap: (details) {
                        if (details.targetElement == CalendarElement.appointment){
                          Appointment app = details.appointments![0];
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> ScheduleState(title: "",
                              tutor: tutor.tutor, appointment: app, index: 0)));
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

}

List<Appointment> getAppointments(){
  List<Appointment> meetings = <Appointment>[];
  for(Availability appointment in ScheduleList){
    if(appointment.isRepeating){
      meetings.add(Appointment(
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          subject: appointment.location,
          location: appointment.location,
          color: Colors.blue,
          notes: appointment.docRef,
          recurrenceRule: '${'FREQ=WEEKLY;BYDAY=' + (appointment.dateAbbreviation ?? "") +
              ';UNTIL='+DateFormat('yyyyMMdd').format(appointment.endDate)}'

      ));
    }else{
      meetings.add(Appointment(
          startTime: appointment.startTime,
          endTime: appointment.endTime,
          subject: appointment.location,
          location: appointment.location,
          color: Colors.blue,
          notes: appointment.docRef
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