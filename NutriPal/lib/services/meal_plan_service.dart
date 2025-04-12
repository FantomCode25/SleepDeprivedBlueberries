import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MealPlanService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMealPlan({
    required String day,
    required String meal,
  }) async {
    User? user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('mealPlans')
          .add({
            'day': day,
            'meal': meal,
            'timestamp': FieldValue.serverTimestamp(),
          });
    } else {
      throw Exception("No user logged in.");
    }
  }
}
