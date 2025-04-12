import 'package:flutter/material.dart';
import '../models/calender_event.dart';
import '../services/calender_service.dart';
import 'package:intl/intl.dart';

class AddEventScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AddEventScreen({super.key, required this.selectedDate});
 
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
  String _mealType = 'Vegetarian';
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;

  // NutriPal theme colors
  final Color primaryColor = const Color(0xFF2C9F6B);
  final Color secondaryColor = const Color(0xFF56C596);
  final Color accentColor = const Color(0xFF9BE8AD);
 
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    // Initialize time with current time to avoid blank field
    _selectedTime = TimeOfDay.now();
    // We need to delay setting text until after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _timeController.text = _selectedTime!.format(context);
        });
      }
    });
  }
 
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
   
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Ensure we have a time value before saving
      if (_timeController.text.isEmpty && _selectedTime != null) {
        _timeController.text = _selectedTime!.format(context);
      }
     
      final event = CalendarEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate a unique ID
        title: _titleController.text,
        date: _selectedDate.toIso8601String().split('T').first,
        time: _timeController.text,
        mealType: _mealType,
        notes: _notesController.text,
      );
     
      await CalendarService().addEvent(event);
     
      if (!mounted) return;
     
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Event saved successfully!'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
     
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Meal Event",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accentColor.withOpacity(0.3), Colors.white],
            stops: const [0.0, 0.3],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Date display card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Event Date",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
               
                const SizedBox(height: 24),
               
                // Form fields
                buildTextField(
                  controller: _titleController,
                  label: "Meal Title",
                  icon: Icons.restaurant_menu,
                  validator: (value) => value == null || value.isEmpty ? "Please enter a title" : null,
                  hintText: "Enter meal name",
                ),
               
                const SizedBox(height: 16),
               
                // Time picker
                InkWell(
                  onTap: _selectTime,
                  child: IgnorePointer(
                    child: buildTextField(
                      controller: _timeController,
                      label: "Meal Time",
                      icon: Icons.access_time,
                      validator: (value) => value == null || value.isEmpty ? "Please select a time" : null,
                      suffix: Icon(Icons.arrow_drop_down, color: primaryColor),
                      hintText: "Select time",
                    ),
                  ),
                ),
               
                const SizedBox(height: 16),
               
                // Meal type dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _mealType,
                    items: const [
                      DropdownMenuItem(value: "Vegetarian", child: Text("Vegetarian")),
                      DropdownMenuItem(value: "Vegan", child: Text("Vegan")),
                      DropdownMenuItem(value: "Keto", child: Text("Keto")),
                      DropdownMenuItem(value: "Any", child: Text("Any")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _mealType = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: "Meal Type",
                      labelStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      icon: Icon(Icons.category, color: primaryColor),
                    ),
                    style: const TextStyle(fontSize: 16),
                    dropdownColor: Colors.white,
                    isExpanded: true,
                  ),
                ),
               
                const SizedBox(height: 16),
               
                // Notes field
                buildTextField(
                  controller: _notesController,
                  label: "Notes (optional)",
                  icon: Icons.notes,
                  maxLines: 3,
                  hintText: "Additional details about this meal...",
                ),
               
                const SizedBox(height: 32),
               
                // Save button
                ElevatedButton(
                  onPressed: _saveEvent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "SAVE EVENT",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
 
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    Widget? suffix,
    String? hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: primaryColor),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: validator,
      ),
    );
  }
 
  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}