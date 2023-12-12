import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:snhu_tutorlink/Models/TutorAvailabilityCard.dart';
import 'package:intl/intl.dart';

import '../Models/Availability.dart';
import '../Models/Tutor.dart';

class FirebaseQueries{
  static int readsCounter = 0;
  final db = FirebaseFirestore.instance;

  final course = <String, String>{
    "courseName": "Intro To Junior Software Engineering"
  };

  void addCourse(){
    db.collection("Courses").doc("CS315").set(course);
  }

  Future<List<Availability>> getTutorAvailabilities(String tutorID) async {
    List<Availability> availabilities = [];
    final ref = db.collection("Availability").where("Tutor", isEqualTo: tutorID).withConverter(
        fromFirestore: Availability.fromFirestore,
        toFirestore: (Availability availibility, _) => availibility.toFirestore());
    final result = await ref.get().then((querySnapshot){
      for(var docsnapshot in querySnapshot.docs){
        final result = docsnapshot.data();
        print(result);
        availabilities.add(result);
      }
    });
    return availabilities;
  }

  Future<List<Map<String, dynamic>>> searchAvailibilitiesOnDate(DateTime time) async {
    DateTime startDate = DateTime(time.year, time.month, time.day);
    DateTime endDate = time.add(const Duration(days:1));
    
    List<Map<String, dynamic>> availableTutors = [];
    await db.collection("Availability").where('Start_Time', isGreaterThanOrEqualTo:startDate)
        .where('Start_Time', isLessThanOrEqualTo:endDate).get().then((querySnapshot){
      if(querySnapshot != null){
        for(var docsnapshot in querySnapshot.docs){
          readsCounter++;
          print("Document:Availability Total Firestore Reads: $readsCounter");
          availableTutors.add(docsnapshot.data());
        }
      }
    });
    return availableTutors;
  }
  Future<List<Availability>> nonRepeatAvailibilitiesOnDate(DateTime time) async {
    DateTime startDate = DateTime(time.year, time.month, time.day);
    DateTime endDate = time.add(const Duration(days:1));

    final ref = db.collection("Availability").where('Start_Time', isGreaterThanOrEqualTo:startDate)
        .where('Start_Time', isLessThanOrEqualTo:endDate).where("IsRepeating", isEqualTo: false).withConverter(
        fromFirestore: Availability.fromFirestore,
        toFirestore: (Availability availibility, _) => availibility.toFirestore());

    List<Availability> availableTutors = [];
    await ref.get().then((querySnapshot){
      if(querySnapshot != null){
        for(var docsnapshot in querySnapshot.docs){
          readsCounter++;
          print("Document:Availability Total Firestore Reads: $readsCounter");
          availableTutors.add(docsnapshot.data());
        }
      }
    });
    return availableTutors;
  }
  Future<List<Availability>> repeatAvailibilitiesOnDate(DateTime time) async {
    String dateAbbr = DateFormat('E').format(time).substring(0,2).toUpperCase();
    DateTime currentDate = DateTime(time.year, time.month, time.day);
    DateTime startDate = DateTime(time.year, time.month, time.day).add(const Duration(days: 1));
    DateTime endDate = time.add(const Duration(days:1));

    final ref = db.collection("Availability").where('Start_Time', isLessThanOrEqualTo:startDate)
        .where('DateAbbreviation', isEqualTo: dateAbbr).withConverter(
        fromFirestore: Availability.fromFirestore,
        toFirestore: (Availability availibility, _) => availibility.toFirestore());

    List<Availability> availableTutors = [];
    await ref.get().then((querySnapshot){
      if(querySnapshot != null){
        for(var docsnapshot in querySnapshot.docs){
          readsCounter++;
          print("Document:Availability Total Firestore Reads: $readsCounter");

          bool isActive = docsnapshot.data().endDate?.isAfter(currentDate) ?? false;
          if(isActive){
            availableTutors.add(docsnapshot.data());
          }
        }
      }
    });
    return availableTutors;
  }

  Future<List<TutorAvailabilityCard>> getTutorInformation(List<Availability> availabilities) async {
    List<TutorAvailabilityCard> availabilityCards = [];
    for(var availability in availabilities){
      final ref = db.collection("Tutor").doc(availability.tutorReference).withConverter(
          fromFirestore: Tutor.fromFirestore,
          toFirestore: (Tutor tutor, _) => tutor.toFirestore());

      await ref.get().then((querySnapshot){
        if(querySnapshot != null){
          print(querySnapshot);

          var tutor = querySnapshot?.data();
          if(tutor != null){
            readsCounter++;
            print("Document:Tutor Total Firestore Reads: $readsCounter");
            availabilityCards.add(TutorAvailabilityCard(tutor: tutor, availibility: availability));
          }
        }
      });
    }
    return availabilityCards;
  }

  Future<List<TutorAvailabilityCard>> getAvailabilitiesOnDate(DateTime date) async {
    List<Availability> availabilitiesOnDate = await nonRepeatAvailibilitiesOnDate(date);
    availabilitiesOnDate = await repeatAvailibilitiesOnDate(date);
    List<TutorAvailabilityCard> tutorAvailabilityCards = await getTutorInformation(availabilitiesOnDate);
    return tutorAvailabilityCards;
  }

  Future<List<String>> getUnavailableTimeslots(String docRef, String date) async{
    List<String> unavailableTimeslots = [];
    final ref = db.collection("Availability").doc(docRef).collection("Appointment").doc(date);
    await ref.get().then((DocumentSnapshot doc) {
      if(doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        List<dynamic> timeslots = data['BookedTimeSlots'];
        for (Map timeslot in timeslots) {
          unavailableTimeslots.add(timeslot["timeslot"]);
        }
      }
    }, onError: (e) => print("Error getting document: $e")
    );
    return unavailableTimeslots;
  }

  Future<bool> BookAppointment(String docRef, String date, String time) async{
    bool isBooked = false;
    List<String> unavailableTimeSlots = await getUnavailableTimeslots(docRef, date);
    //Dont book the appointment if timeslot is taken
    if(unavailableTimeSlots.contains(time)){
      return false;
    }
    final ref = db.collection("Availability").doc(docRef).collection("Appointment").doc(date);
    await ref.get().then((DocumentSnapshot doc) async {
      if(!doc.exists || doc.get('BookedTimeSlots') == null){
        await ref.set({"BookedTimeSlots": []});
      }
      FirebaseAuth auth = FirebaseAuth.instance;
      if(auth.currentUser?.uid != null) {
        await ref.update({
          "BookedTimeSlots": FieldValue.arrayUnion(
              [{"timeslot": time, "userId": auth.currentUser!.uid}])
        });
        isBooked = true;
      }

    }, onError: (e) => print("Error getting document: $e")
    );

    return isBooked;
  }

}