import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calender_event.dart';

class CalendarService {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _db = FirebaseFirestore.instance;

  Future<void> addEvent(CalendarEvent event) async {
    if (uid == null) return;
    await _db
        .collection('users')
        .doc(uid)
        .collection('calendar_events')
        .add(event.toMap());
  }

  Future<List<CalendarEvent>> fetchEventsByDate(String date) async {
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('calendar_events')
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs
        .map((doc) => CalendarEvent.fromMap(doc.id, doc.data()))
        .toList();
  }
}
