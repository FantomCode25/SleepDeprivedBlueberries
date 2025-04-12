import 'package:flutter/foundation.dart';

class Meal {
  final String? id;
  final String date;
  final String mealType; // breakfast, lunch, dinner
  final String title;
  final String time;
  final String notes;
  final bool isCompleted;
  final bool isAISuggested;

  Meal({
    this.id,
    required this.date,
    required this.mealType,
    required this.title,
    required this.time,
    required this.notes,
    this.isCompleted = false,
    this.isAISuggested = false,
  });

  factory Meal.fromMap(String id, Map<String, dynamic> data) {
    return Meal(
      id: id,
      date: data['date'] ?? '',
      mealType: data['mealType'] ?? '',
      title: data['title'] ?? '',
      time: data['time'] ?? '',
      notes: data['notes'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      isAISuggested: data['isAISuggested'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mealType': mealType,
      'title': title,
      'time': time,
      'notes': notes,
      'isCompleted': isCompleted,
      'isAISuggested': isAISuggested,
    };
  }

  Meal copyWith({
    String? date,
    String? mealType,
    String? title,
    String? time,
    String? notes,
    bool? isCompleted,
    bool? isAISuggested,
  }) {
    return Meal(
      id: this.id,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      title: title ?? this.title,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      isAISuggested: isAISuggested ?? this.isAISuggested,
    );
  }
}
