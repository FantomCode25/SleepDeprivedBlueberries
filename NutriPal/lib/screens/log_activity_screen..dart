import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  String _selectedActivity = 'Meal';
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _waterController = TextEditingController(text: '0');
  final TextEditingController _caloriesController = TextEditingController(text: '0');
  final TextEditingController _stepsController = TextEditingController(text: '0');
 
  @override
  void dispose() {
    _notesController.dispose();
    _waterController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
 
  // void _logActivity() async {
  //   try {
  //     final userId = _auth.currentUser?.uid;
  //     if (userId == null) return;
     
  //     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  //     final timestamp = DateTime.now();
     
  //     // Create activity log
  //     final Map<String, dynamic> activityData = {
  //       'type': _selectedActivity,
  //       'notes': _notesController.text,
  //       'timestamp': timestamp,
  //     };
     
  //     // Add specific metrics based on activity type
  //     if (_selectedActivity == 'Meal') {
  //       activityData['calories'] = int.tryParse(_caloriesController.text) ?? 0;
  //     } else if (_selectedActivity == 'Water') {
  //       activityData['amount'] = double.tryParse(_waterController.text) ?? 0;
  //     } else if (_selectedActivity == 'Exercise') {
  //       activityData['steps'] = int.tryParse(_stepsController.text) ?? 0;
  //       activityData['calories'] = int.tryParse(_caloriesController.text) ?? 0;
  //     }
     
  //     // Save to activities collection
  //     await _firestore
  //       .collection('logs')
  //       .doc(userId)
  //       .collection('activities')
  //       .add(activityData);
     
  //     // Update daily totals
  //     final dailyRef = _firestore
  //       .collection('logs')
  //       .doc(userId)
  //       .collection('daily')
  //       .doc(today);
       
  //     final dailyDoc = await dailyRef.get();
     
  //     if (_selectedActivity == 'Meal') {
  //       final currentCalories = dailyDoc.exists ? (dailyDoc.data()?['calories'] ?? 0) : 0;
  //       final additionalCalories = int.tryParse(_caloriesController.text) ?? 0;
       
  //       await dailyRef.set({
  //         'calories': currentCalories + additionalCalories,
  //         'lastUpdated': FieldValue.serverTimestamp(),
  //       }, SetOptions(merge: true));
  //     } else if (_selectedActivity == 'Water') {
  //       final currentWater = dailyDoc.exists ? (dailyDoc.data()?['water'] ?? 0) : 0;
  //       final additionalWater = double.tryParse(_waterController.text) ?? 0;
       
  //       await dailyRef.set({
  //         'water': currentWater + additionalWater,
  //         'lastUpdated': FieldValue.serverTimestamp(),
  //       }, SetOptions(merge: true));
  //     } else if (_selectedActivity == 'Exercise') {
  //       final currentSteps = dailyDoc.exists ? (dailyDoc.data()?['steps'] ?? 0) : 0;
  //       final additionalSteps = int.tryParse(_stepsController.text) ?? 0;
       
  //       await dailyRef.set({
  //         'steps': currentSteps + additionalSteps,
  //         'lastUpdated': FieldValue.serverTimestamp(),
  //       }, SetOptions(merge: true));
  //     }
     
  //     // Success notification
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Activity logged successfully!'),
  //           backgroundColor: Color(0xFF2C9F6B),
  //         ),
  //       );
  //       Navigator.of(context).pop();
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error logging activity: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }

void _logActivity() async {
  try {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final timestamp = DateTime.now();

    final Map<String, dynamic> activityData = {
      'userId': userId,
      'type': _selectedActivity,
      'notes': _notesController.text,
      'timestamp': timestamp,
    };

    if (_selectedActivity == 'Meal') {
      activityData['calories'] = int.tryParse(_caloriesController.text) ?? 0;
    } else if (_selectedActivity == 'Water') {
      activityData['amount'] = double.tryParse(_waterController.text) ?? 0;
    } else if (_selectedActivity == 'Exercise') {
      activityData['steps'] = int.tryParse(_stepsController.text) ?? 0;
      activityData['calories'] = int.tryParse(_caloriesController.text) ?? 0;
    }

    await _firestore.collection('activities').add(activityData); // unified collection

    final dailyRef = _firestore.collection('dailyTotals').doc('$userId-$today');
    final dailyDoc = await dailyRef.get();

    if (_selectedActivity == 'Meal') {
      final currentCalories = dailyDoc.exists ? (dailyDoc.data()?['calories'] ?? 0) : 0;
      final additionalCalories = int.tryParse(_caloriesController.text) ?? 0;

      await dailyRef.set({
        'userId': userId,
        'calories': currentCalories + additionalCalories,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else if (_selectedActivity == 'Water') {
      final currentWater = dailyDoc.exists ? (dailyDoc.data()?['water'] ?? 0) : 0;
      final additionalWater = double.tryParse(_waterController.text) ?? 0;

      await dailyRef.set({
        'userId': userId,
        'water': currentWater + additionalWater,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else if (_selectedActivity == 'Exercise') {
      final currentSteps = dailyDoc.exists ? (dailyDoc.data()?['steps'] ?? 0) : 0;
      final additionalSteps = int.tryParse(_stepsController.text) ?? 0;

      await dailyRef.set({
        'userId': userId,
        'steps': currentSteps + additionalSteps,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity logged successfully!'),
          backgroundColor: Color(0xFF2C9F6B),
        ),
      );
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging activity: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Log Activity'),
        backgroundColor: const Color(0xFF2C9F6B),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF9FFFC),
              Color(0xFFEBF7F1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Activity Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
               
                // Activity selection cards
                Row(
                  children: [
                    _buildActivityCard('Meal', Icons.restaurant_menu_outlined),
                    const SizedBox(width: 12),
                    _buildActivityCard('Water', Icons.water_drop_outlined),
                    const SizedBox(width: 12),
                    _buildActivityCard('Exercise', Icons.fitness_center_outlined),
                    const SizedBox(width: 12),
                    _buildActivityCard('Sleep', Icons.bedtime_outlined),
                  ],
                ),
               
                const SizedBox(height: 32),
               
                // Input fields based on selected activity
                if (_selectedActivity == 'Meal') ...[
                  _buildInputField(
                    'Calories',
                    'Enter calories',
                    _caloriesController,
                    TextInputType.number,
                    Icons.local_fire_department_outlined,
                  ),
                ] else if (_selectedActivity == 'Water') ...[
                  _buildInputField(
                    'Amount (L)',
                    'Enter water intake in liters',
                    _waterController,
                    TextInputType.number,
                    Icons.water_drop_outlined,
                  ),
                ] else if (_selectedActivity == 'Exercise') ...[
                  _buildInputField(
                    'Steps',
                    'Enter steps',
                    _stepsController,
                    TextInputType.number,
                    Icons.directions_walk_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(
                    'Calories Burned',
                    'Enter calories burned',
                    _caloriesController,
                    TextInputType.number,
                    Icons.local_fire_department_outlined,
                  ),
                ] else if (_selectedActivity == 'Sleep') ...[
                  _buildInputField(
                    'Duration (hours)',
                    'Enter sleep duration',
                    TextEditingController(),
                    TextInputType.number,
                    Icons.bedtime_outlined,
                  ),
                ],
               
                const SizedBox(height: 16),
               
                // Notes field for all activity types
                _buildInputField(
                  'Notes',
                  'Add notes (optional)',
                  _notesController,
                  TextInputType.multiline,
                  Icons.note_outlined,
                  maxLines: 3,
                ),
               
                const SizedBox(height: 32),
               
                // Log button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _logActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C9F6B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Log Activity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget _buildActivityCard(String activity, IconData icon) {
    final bool isSelected = _selectedActivity == activity;
   
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedActivity = activity),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2C9F6B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF2C9F6B),
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                activity,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
    TextInputType keyboardType,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: const Color(0xFF2C9F6B)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}