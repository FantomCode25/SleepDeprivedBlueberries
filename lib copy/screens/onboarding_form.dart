import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

// Define NutriPal theme colors
class NutriPalTheme {
  static const Color primaryColor = Color(0xFF2C9F6B); // Deep green
  static const Color secondaryColor = Color(0xFF56C596); // Medium green
  static const Color accentColor = Color(0xFF9BE8AD); // Light mint green
 
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentColor, secondaryColor],
  );
 
  // Text styles based on guidelines
  static const TextStyle appNameStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(1, 1))],
  );
 
  static const TextStyle taglineStyle = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Colors.white,
  );
 
  static const TextStyle headerStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );
 
  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 15,
    color: Colors.black87,
  );
 
  // UI Element themes
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: const EdgeInsets.symmetric(vertical: 15),
  );
 
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: accentColor.withOpacity(0.3), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
    ),
    labelStyle: const TextStyle(color: Colors.black54),
    floatingLabelStyle: const TextStyle(color: primaryColor),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );
 
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({Key? key}) : super(key: key);

  @override
  _OnboardingFormState createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _healthGoalsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();

  String _selectedGender = 'Prefer not to say';
  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _healthGoalsController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        final result = await FirebaseAuth.instance.signInAnonymously();
        user = result.user;
      }

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'gender': _selectedGender,
          'allergies': _allergiesController.text.trim(),
          'healthGoals': _healthGoalsController.text.trim(),
          'medicalConditions': _medicalConditionsController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile saved successfully!'),
            backgroundColor: NutriPalTheme.primaryColor,
          ),
        );

        // Navigate to HomeScreen after onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        backgroundColor: NutriPalTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: NutriPalTheme.backgroundGradient,
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: NutriPalTheme.primaryColor,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // App branding
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        children: [
                          const Text(
                            'NutriPal',
                            style: NutriPalTheme.appNameStyle,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Nutrition with Intuition',
                            style: NutriPalTheme.taglineStyle,
                          ),
                        ],
                      ),
                    ),
                   
                    // Form container with card design
                    Container(
                      decoration: NutriPalTheme.cardDecoration,
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Your Health Information',
                              style: NutriPalTheme.headerStyle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                           
                            // Name field
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person, color: NutriPalTheme.secondaryColor),
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                              validator: (value) => value == null || value.isEmpty ? 'Enter your name' : null,
                            ),
                            const SizedBox(height: 16),
                           
                            // Age field
                            TextFormField(
                              controller: _ageController,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                prefixIcon: Icon(Icons.calendar_today, color: NutriPalTheme.secondaryColor),
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  value == null || int.tryParse(value) == null ? 'Enter a valid age' : null,
                            ),
                            const SizedBox(height: 16),
                           
                            // Gender dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.people, color: NutriPalTheme.secondaryColor),
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                              dropdownColor: Colors.white,
                              items: _genderOptions.map((gender) {
                                return DropdownMenuItem(value: gender, child: Text(gender));
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedGender = value);
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                           
                            // Allergies field
                            TextFormField(
                              controller: _allergiesController,
                              decoration: const InputDecoration(
                                labelText: 'Allergies',
                                prefixIcon: Icon(Icons.warning_rounded, color: NutriPalTheme.secondaryColor),
                                hintText: 'List any food allergies',
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                            ),
                            const SizedBox(height: 16),
                           
                            // Health goals field
                            TextFormField(
                              controller: _healthGoalsController,
                              decoration: const InputDecoration(
                                labelText: 'Health Goals',
                                prefixIcon: Icon(Icons.flag, color: NutriPalTheme.secondaryColor),
                                hintText: 'What are you looking to achieve?',
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                              validator: (value) =>
                                  value == null || value.isEmpty ? 'Enter at least one goal' : null,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 16),
                           
                            // Medical conditions field
                            TextFormField(
                              controller: _medicalConditionsController,
                              decoration: const InputDecoration(
                                labelText: 'Medical Conditions',
                                prefixIcon: Icon(Icons.medical_services, color: NutriPalTheme.secondaryColor),
                                hintText: 'Any conditions we should know about?',
                              ),
                              style: NutriPalTheme.bodyTextStyle,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 24),
                           
                            // Save button
                            ElevatedButton(
                              onPressed: _saveUserData,
                              style: NutriPalTheme.elevatedButtonStyle,
                              child: const Text(
                                'SAVE PROFILE',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// Create a theme for the entire app
ThemeData nutriPalTheme() {
  return ThemeData(
    primaryColor: NutriPalTheme.primaryColor,
    scaffoldBackgroundColor: NutriPalTheme.accentColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NutriPalTheme.primaryColor,
      primary: NutriPalTheme.primaryColor,
      secondary: NutriPalTheme.secondaryColor,
    ),
    textTheme: const TextTheme(
      displayLarge: NutriPalTheme.appNameStyle,
      headlineMedium: NutriPalTheme.headerStyle,
      bodyMedium: NutriPalTheme.bodyTextStyle,
    ),
    inputDecorationTheme: NutriPalTheme.inputDecorationTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: NutriPalTheme.elevatedButtonStyle,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: NutriPalTheme.primaryColor,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NutriPalTheme.primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),
  );
}