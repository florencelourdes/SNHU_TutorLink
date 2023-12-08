import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:snhu_tutorlink/Models/Availability.dart';

import 'Tutor.dart';

class TutorAvailabilityCard{
  final Tutor tutor;
  final Availability availibility;

  TutorAvailabilityCard({
    required this.tutor,
    required this.availibility
  });

}