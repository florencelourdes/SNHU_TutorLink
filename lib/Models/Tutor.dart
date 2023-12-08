import 'package:cloud_firestore/cloud_firestore.dart';

class Tutor{
  final String firstName;
  final String lastName;
  final String? tutorReference;
  final List<String>? coursesTutored;
  final String aboutMe;

  Tutor({
    required this.firstName,
    required this.lastName,
    required this.aboutMe,
    this.coursesTutored,
    this.tutorReference
  });

  factory Tutor.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options
      ){
      final data = snapshot.data();
      return Tutor(
        firstName: data?['First_Name'],
        lastName: data?['Last_Name'],
        aboutMe: data?['About_Me'] ?? "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.",
        coursesTutored: (data?['Tutors'] as List)?.map((course) => (course as String))?.toList(),
        tutorReference: data?['userId']
    );
  }

  Map<String, dynamic> toFirestore(){
    return{
      "Tutor": tutorReference
    };
  }

}