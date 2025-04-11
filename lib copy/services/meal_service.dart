import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/meal.dart';

class MealService {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String apiKey = 'AIzaSyCDakz0AEeWoKejtiho0liyHyWhBtaRwsw';
  late final GenerativeModel _model;

  MealService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-pro-exp-03-25',
      apiKey: apiKey,
    );
  }

  Future<List<Meal>> getMealsByDate(String date) async {
    if (uid == null) return [];

    final snapshot = await _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .where('date', isEqualTo: date)
        .get();

    return snapshot.docs
        .map((doc) => Meal.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<String?> addMeal(Meal meal) async {
    if (uid == null) return null;

    final docRef = await _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .add(meal.toMap());

    return docRef.id;
  }

  Future<void> updateMeal(Meal meal) async {
    if (uid == null || meal.id == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(meal.id)
        .update(meal.toMap());
  }

  Future<void> toggleMealCompletion(String mealId, bool isCompleted) async {
    if (uid == null) return;

    await _db
        .collection('users')
        .doc(uid)
        .collection('meals')
        .doc(mealId)
        .update({'isCompleted': isCompleted});
  }

  Future<List<Meal>> generateAIMealSuggestions(String date) async {
    if (uid == null) return [];

    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final eventsData = await _getRelevantEvents(date);
      final suggestions = await _generateAISuggestions(date, userData, eventsData);

      for (final meal in suggestions) {
        await addMeal(meal);
      }

      return suggestions;
    } catch (e) {
      print('error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRelevantEvents(String date) async {
    if (uid == null) return [];

    final dateEvents = await _db
        .collection('users')
        .doc(uid)
        .collection('calendar_events')
        .where('date', isEqualTo: date)
        .get();

    final DateTime targetDate = DateTime.parse(date);
    final DateTime endDate = targetDate.add(const Duration(days: 7));
    final String endDateStr = endDate.toIso8601String().split('T')[0];

    final upcomingEvents = await _db
        .collection('users')
        .doc(uid)
        .collection('calendar_events')
        .where('date', isGreaterThan: date)
        .where('date', isLessThanOrEqualTo: endDateStr)
        .get();

    List<Map<String, dynamic>> relevantEvents = [];

    for (var doc in dateEvents.docs) {
      final data = doc.data();
      print('📅 Same-day event found: ${data['title']}'); // ✅ Debug print
      relevantEvents.add({
        'id': doc.id,
        ...data,
        'timeUntil': 0,
      });
    }

    for (var doc in upcomingEvents.docs) {
      final data = doc.data();
      final eventDate = data['date'] as String;
      final daysUntil = DateTime.parse(eventDate).difference(targetDate).inDays;
      print('📅 Upcoming event: ${data['title']} in $daysUntil days'); // ✅ Debug print
      relevantEvents.add({
        'id': doc.id,
        ...data,
        'timeUntil': daysUntil,
      });
    }

    return relevantEvents;
  }

  Future<List<Meal>> _generateAISuggestions(
    String date,
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> events,
  ) async {
    final int age = userData['age'] ?? 30;
    final String gender = userData['gender'] ?? 'Not specified';
    final String allergies = userData['allergies'] ?? 'None';
    final String healthGoals = userData['healthGoals'] ?? 'Balanced diet';
    final String medicalConditions = userData['medicalConditions'] ?? 'None';
    final String mealType = userData['mealType'] ?? 'Regular';

    final prompt = _buildAIPrompt(
      date: date,
      age: age,
      gender: gender,
      allergies: allergies,
      healthGoals: healthGoals,
      medicalConditions: medicalConditions,
      dietType: mealType,
      events: events,
    );

    print("🧠 Generated AI Prompt:\n$prompt"); // ✅ Final prompt check

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      return _parseMealSuggestions(date, responseText);
    } catch (e) {
      print('AI generation error: $e');
      return [];
    }
  }

  String _buildAIPrompt({
    required String date,
    required int age,
    required String gender,
    required String allergies,
    required String healthGoals,
    required String medicalConditions,
    required String dietType,
    required List<Map<String, dynamic>> events,
  }) {
    final basePrompt = '''
Generate 3 personalized meal suggestions (breakfast, lunch, and dinner) for a person with the following profile(Indian cuisine preferred):

- Date: $date
- Age: $age
- Gender: $gender
- Diet Type: $dietType
- Allergies/Restrictions: $allergies
- Health Goals: $healthGoals
- Medical Conditions: $medicalConditions
''';

    final sameDayEvents = events.where((e) => e['timeUntil'] == 0).toList();
    final upcomingEvents = events.where((e) => e['timeUntil'] > 0).toList();

    final sameDayInfo = sameDayEvents.isEmpty
        ? ''
        : '\n- Events on the day: ' +
            sameDayEvents.map((e) => '"${e['title']}"').join(', ');

    final upcomingInfo = upcomingEvents.isEmpty
        ? ''
        : '\n- Upcoming Events: ' +
            upcomingEvents.map((e) => '"${e['title']}" in ${e['timeUntil']} days').join(', ');

    final eventInstructions = '''
When creating meals:
- If there are events today, reference them explicitly in the reasoning. For example: "For your marathon today, this meal provides carbs to fuel your endurance."
- You must include the event title in the reasoning using the phrase: "For your <event>, your meal should..."
- If there are no events today, skip event references.
''';

    final formatInstructions = '''
For each meal, provide:
1. A title
2. A brief description of the meal
3. Suggested time to eat
4. Brief reasoning and health benefits
5. Use this format:

BREAKFAST:::Title:::Time:::Description:::Reasoning
LUNCH:::Title:::Time:::Description:::Reasoning
DINNER:::Title:::Time:::Description:::Reasoning
''';

    return '$basePrompt$sameDayInfo$upcomingInfo\n\n$eventInstructions\n\n$formatInstructions';
  }

  List<Meal> _parseMealSuggestions(String date, String aiResponse) {
    final List<Meal> meals = [];

    try {
      final lines = aiResponse.split('\n');

      for (final line in lines) {
        if (line.isEmpty) continue;

        if (line.startsWith('BREAKFAST:::') ||
            line.startsWith('LUNCH:::') ||
            line.startsWith('DINNER:::')) {
          final parts = line.split(':::');
          if (parts.length >= 5) {
            final mealType = parts[0].toLowerCase();
            final title = parts[1];
            final time = parts[2];
            final description = parts[3];
            final reasoning = parts[4];

            meals.add(Meal(
              date: date,
              mealType: mealType,
              title: title,
              time: time,
              notes: '$description\n\nWhy this meal: $reasoning',
              isAISuggested: true,
            ));
          }
        }
      }

      return meals;
    } catch (e) {
      print('Meal parsing error: $e');
      return [];
    }
  }
}
