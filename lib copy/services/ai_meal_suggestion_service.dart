import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/meal.dart';
import '../models/calender_event.dart';

class AIMealSuggestionService {
  // Add your API key here
  static const String apiKey = 'AIzaSyCDakz0AEeWoKejtiho0liyHyWhBtaRwsw';
  late final GenerativeModel model;

  AIMealSuggestionService() {
    model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  // Generate suggestions for specific events
  Future<List<Meal>> generateEventSpecificMeals({
    required String date,
    required Map<String, dynamic> userData,
    required CalendarEvent event,
    required int daysUntilEvent,
  }) async {
    try {
      final prompt = _buildEventSpecificPrompt(
        date: date,
        userData: userData,
        event: event,
        daysUntilEvent: daysUntilEvent,
      );
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';
      return _parseMealSuggestions(date, responseText);
    } catch (e) {
      print('Error generating event-specific meal suggestions: $e');
      return [];
    }
  }

  // Build prompt for event-specific meal suggestions
  String _buildEventSpecificPrompt({
    required String date,
    required Map<String, dynamic> userData,
    required CalendarEvent event,
    required int daysUntilEvent,
  }) {
    // Extract user data
    final age = userData['age'] ?? 30;
    final gender = userData['gender'] ?? 'Not specified';
    final allergies = userData['allergies'] ?? 'None';
    final healthGoals = userData['healthGoals'] ?? 'Balanced diet';
    final medicalConditions = userData['medicalConditions'] ?? 'None';
    final dietType = userData['mealType'] ?? 'Regular';

    return '''
Generate 3 meals (breakfast, lunch, and dinner) specifically designed for someone preparing for ${event.title} which is happening in $daysUntilEvent days from now.

User Profile:
- Age: $age
- Gender: $gender
- Diet Type: $dietType
- Allergies/Restrictions: $allergies
- Health Goals: $healthGoals
- Medical Conditions: $medicalConditions

Event Details:
- Event Type: ${event.title}
- Days Until Event: $daysUntilEvent
- Event Time: ${event.time}
- Event Notes: ${event.notes}

Provide meal suggestions that will help the person prepare optimally for this event. For each meal, include:
1. A descriptive title
2. A recommended time to eat
3. A brief description of what the meal consists of
4. Clear reasoning explaining why this meal is beneficial for the upcoming event
5. If possible, include a citation or source supporting your recommendation

Format your response as follows:
BREAKFAST:::Title:::Time:::Description:::Reasoning:::Citation
LUNCH:::Title:::Time:::Description:::Reasoning:::Citation
DINNER:::Title:::Time:::Description:::Reasoning:::Citation
''';
  }

  // Generate regular daily meal suggestions
  Future<List<Meal>> generateDailyMealSuggestions({
    required String date,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final prompt = _buildDailyMealPrompt(date, userData);
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '';
      return _parseMealSuggestions(date, responseText);
    } catch (e) {
      print('Error generating daily meal suggestions: $e');
      return _getDefaultMealSuggestions(date);
    }
  }

  // Build prompt for daily meal suggestions
  String _buildDailyMealPrompt(String date, Map<String, dynamic> userData) {
    // Extract user data
    final age = userData['age'] ?? 30;
    final gender = userData['gender'] ?? 'Not specified';
    final allergies = userData['allergies'] ?? 'None';
    final healthGoals = userData['healthGoals'] ?? 'Balanced diet';
    
    // Method implementation would continue here...
    return '';
  }
  
  // These methods would need to be implemented
  List<Meal> _parseMealSuggestions(String date, String responseText) {
    // Implementation needed
    return [];
  }
  
  List<Meal> _getDefaultMealSuggestions(String date) {
    // Implementation needed
    return [];
  }
}