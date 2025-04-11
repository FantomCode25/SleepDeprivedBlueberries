import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const _apiKey = 'AIzaSyCDakz0AEeWoKejtiho0liyHyWhBtaRwsw'; // 🔐 Replace with your actual Gemini API key

  static Future<String> getInsightFromAI(String scannedText) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "User not logged in.";

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final userData = userDoc.data();

    final goal = userData?['goal'] ?? 'general health';
    final age = userData?['age'] ?? 'unknown age';
    final allergies = userData?['allergies'] ?? 'no allergies';

    final prompt = '''
You are a certified nutritionist.

The user is $age years old and allergic to $allergies.
Their health goal is "$goal".

Analyze the following scanned food label and return your response in the following format using markdown:

## Risk Ingredients
- List risky or harmful ingredients based on age, allergies, or health goal

## Analysis
Write a short paragraph summarizing the health impact

## Other Suggestions
- Suggest healthier alternatives or lifestyle tips

Food Label:
$scannedText
''';

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _apiKey,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? 'No response from Gemini.';
    } catch (e) {
      return "Gemini Error: $e";
    }
  }
}
