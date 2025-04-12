import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/calender_event.dart';

class MealRecommendationService {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final _db = FirebaseFirestore.instance;
  final _random = Random();

  // Sample meal data - in a real app, this would come from a database or API
  final List<Map<String, String>> _breakfastOptions = [
    {'title': 'Oatmeal with Berries', 'notes': 'High fiber, antioxidants'},
    {'title': 'Avocado Toast', 'notes': 'Healthy fats and protein'},
    {'title': 'Greek Yogurt Parfait', 'notes': 'High protein, probiotics'},
    {'title': 'Scrambled Eggs & Veggies', 'notes': 'Protein and vitamins'},
    {'title': 'Smoothie Bowl', 'notes': 'Fruits, nuts and seeds'},
  ];

  final List<Map<String, String>> _lunchOptions = [
    {'title': 'Quinoa Salad', 'notes': 'Complete protein, fiber'},
    {'title': 'Grilled Chicken Wrap', 'notes': 'Lean protein, whole grains'},
    {'title': 'Buddha Bowl', 'notes': 'Balanced nutrients, variety'},
    {'title': 'Lentil Soup & Bread', 'notes': 'Plant protein, filling'},
    {'title': 'Tuna Sandwich', 'notes': 'Omega-3, protein'},
  ];

  final List<Map<String, String>> _dinnerOptions = [
    {'title': 'Baked Salmon & Veggies', 'notes': 'Omega-3, protein, vitamins'},
    {'title': 'Stir-fry with Tofu', 'notes': 'Plant protein, vegetables'},
    {'title': 'Turkey Chili', 'notes': 'Lean protein, beans, fiber'},
    {'title': 'Roasted Chicken & Vegetables', 'notes': 'Protein, nutrients'},
    {'title': 'Vegetable Pasta', 'notes': 'Whole grains, plant-based'},
  ];

  final List<Map<String, String>> _snackOptions = [
    {'title': 'Apple with Almond Butter', 'notes': 'Fiber, healthy fats'},
    {'title': 'Greek Yogurt', 'notes': 'Protein, probiotics'},
    {'title': 'Trail Mix', 'notes': 'Nuts, dried fruit, energy'},
    {'title': 'Hummus & Veggies', 'notes': 'Plant protein, fiber'},
    {'title': 'Protein Smoothie', 'notes': 'Post-workout, recovery'},
  ];

  // Get user preferences for recommendations
  Future<Map<String, dynamic>> _getUserPreferences() async {
    if (uid == null) {
      return {
        'dietary_restrictions': [],
        'disliked_foods': [],
        'calorie_target': 2000,
      };
    }

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('meal_preferences')) {
        return doc.data()!['meal_preferences'];
      }
    } catch (e) {
      print('Error getting user preferences: $e');
    }

    // Default preferences
    return {
      'dietary_restrictions': [],
      'disliked_foods': [],
      'calorie_target': 2000,
    };
  }

  // Generate meal plan for a week
  Future<List<CalendarEvent>> generateWeeklyPlan(String startDateStr) async {
    final List<CalendarEvent> weeklyPlan = [];
    final startDate = DateTime.parse(startDateStr);
    final preferences = await _getUserPreferences();

    // Generate for 7 days
    for (int i = 0; i < 7; i++) {
      final currentDate = startDate.add(Duration(days: i));
      final dateStr = currentDate.toIso8601String().split('T').first;

      // Check if meals already exist for this date
      final existingMeals = await _getExistingMeals(dateStr);
      final mealTypes = {'breakfast', 'lunch', 'dinner', 'snack'};
      
      // Remove meal types that already exist
      for (var meal in existingMeals) {
        if (meal.mealType != null) {
          mealTypes.remove(meal.mealType!.toLowerCase());
        }
      }

      // Generate recommendations for missing meal types
      for (var mealType in mealTypes) {
        final meal = await _recommendMeal(dateStr, mealType, preferences);
        if (meal != null) {
          weeklyPlan.add(meal);
        }
      }
    }

    return weeklyPlan;
  }

  // Get existing meals for a date
  Future<List<CalendarEvent>> _getExistingMeals(String dateStr) async {
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('calendar_events')
        .where('date', isEqualTo: dateStr)
        .get();

    return snapshot.docs
        .map((doc) => CalendarEvent.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Recommend a meal based on user preferences and meal type
  Future<CalendarEvent?> _recommendMeal(
    String dateStr,
    String mealType,
    Map<String, dynamic> preferences,
  ) async {
    List<Map<String, String>> options;
    String time;

    // Select options and time based on meal type
    switch (mealType) {
      case 'breakfast':
        options = _breakfastOptions;
        time = '08:00';
        break;
      case 'lunch':
        options = _lunchOptions;
        time = '13:00';
        break;
      case 'dinner':
        options = _dinnerOptions;
        time = '19:00';
        break;
      case 'snack':
        options = _snackOptions;
        time = '16:00';
        break;
      default:
        return null;
    }

    // Here you would filter options based on preferences
    // For simplicity, we're just taking a random option now
    final option = options[_random.nextInt(options.length)];

    return CalendarEvent(
      id: '', // Will be assigned when saving to Firestore
      title: option['title']!,
      date: dateStr,
      time: time,
      mealType: mealType.substring(0, 1).toUpperCase() + mealType.substring(1), // Capitalize
      notes: option['notes']!,
    );
  }

  // Method to update user meal preferences
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    if (uid == null) return;

    await _db.collection('users').doc(uid).set({
      'meal_preferences': preferences,
    }, SetOptions(merge: true));
  }
}