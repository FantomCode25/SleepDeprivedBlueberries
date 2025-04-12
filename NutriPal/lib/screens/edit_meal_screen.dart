import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

// Define NutriPal theme colors
class NutriPalTheme {
  static const Color primaryColor = Color(0xFF2C9F6B);    // Deep green
  static const Color secondaryColor = Color(0xFF56C596);  // Medium green
  static const Color accentColor = Color(0xFF9BE8AD);     // Light mint green
  static const Color textColor = Color(0xFF333333);       // Dark text
  static const Color lightTextColor = Color(0xFFFFFFFF);  // White text
  static const Color backgroundColor = Color(0xFFF5F9F7); // Light background
  
  static const double borderRadius = 12.0;
  static const double cardRadius = 20.0;
  
  // Gradient for backgrounds
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentColor, Color(0xFF78D6A3)], // Light mint to medium green
  );
  
  // Button style
  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: lightTextColor,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
  
  // Input decoration
  static InputDecoration inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: secondaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
    );
  }
}

class EditMealScreen extends StatefulWidget {
  final Meal meal;
  
  const EditMealScreen({Key? key, required this.meal}) : super(key: key);
  
  @override
  _EditMealScreenState createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  String _mealType = '';
  
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.meal.title;
    _timeController.text = widget.meal.time;
    _notesController.text = widget.meal.notes;
    _mealType = widget.meal.mealType;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;
    
    final updatedMeal = widget.meal.copyWith(
      title: _titleController.text,
      time: _timeController.text,
      notes: _notesController.text,
      mealType: _mealType,
      isAISuggested: false, // Mark as user-edited
    );
    
    final service = MealService();
    if (updatedMeal.id != null) {
      await service.updateMeal(updatedMeal);
    } else {
      await service.addMeal(updatedMeal);
    }
    
    Navigator.pop(context, true);
  }
  
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: NutriPalTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: NutriPalTheme.textColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        // Format time as HH:MM
        _timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit ${widget.meal.mealType.capitalize()}',
          style: const TextStyle(
            color: NutriPalTheme.lightTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: NutriPalTheme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: NutriPalTheme.lightTextColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: NutriPalTheme.backgroundGradient,
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NutriPalTheme.cardRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Meal Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: NutriPalTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: NutriPalTheme.inputDecoration('Meal Title'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a meal title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _mealType,
                        decoration: NutriPalTheme.inputDecoration('Meal Type'),
                        items: ['breakfast', 'lunch', 'dinner']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.capitalize()),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _mealType = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a meal type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        decoration: NutriPalTheme.inputDecoration(
                          'Time',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.access_time,
                              color: NutriPalTheme.primaryColor,
                            ),
                            onPressed: _selectTime,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a time';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: NutriPalTheme.inputDecoration('Notes'),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMeal,
                style: NutriPalTheme.elevatedButtonStyle,
                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}