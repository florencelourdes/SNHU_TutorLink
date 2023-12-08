import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Availability{
  final DateTime startTime;
  final int duration;
  final DateTime endTime;
  final String location;
  final String tutorReference;
  final String docRef;

  //If session repeats
  final bool isRepeating;
  final DateTime endDate;
  final String? dateAbbreviation;

  Availability({
    required this.startTime,
    required this.duration,
    required this.endTime,
    required this.location,
    required this.tutorReference,
    required this.isRepeating,
    required this.endDate,
    required this.docRef,
    this.dateAbbreviation
  });

  factory Availability.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options
      ){
    final data = snapshot.data();
    return Availability(
      //(firestore)Timestamp is converted to DateTime for displaying readable times
        startTime: (data?['Start_Time'] as Timestamp).toDate(),
        duration: data?['SessionLength'] ?? 30,
        endTime: (data?['Start_Time'] as Timestamp).toDate().add(Duration(minutes: data?['SessionLength'] ?? 30)),
        location: data?['Location'] ?? "",
        tutorReference: data?['Tutor'],

        isRepeating: data?['IsRepeating'] ?? false,
        endDate: (data?['End_Time'] as Timestamp? ?? data?['Start_Time'] as Timestamp).toDate(),
        dateAbbreviation: data?['DateAbbreviation'],
        docRef: snapshot.id

    );
  }

  Map<String, dynamic> toFirestore(){
    return{
      "Start_Time": startTime,
      "End_Time": endDate,
      "Location": location,
      "Tutor": tutorReference
    };
  }

  String getAvailableTimeRange(){
    String start = DateFormat('h:mm').format(startTime);
    String end = DateFormat('h:mm').format(endTime);
    return "$start - $end";
  }

}