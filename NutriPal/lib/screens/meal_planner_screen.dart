import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import '../services/calender_service.dart';
import 'edit_meal_screen.dart';
import 'package:intl/intl.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final MealService _mealService = MealService();
  final CalendarService _calendarService = CalendarService();
  DateTime _selectedDate = DateTime.now();
  List<Meal> _meals = [];
  bool _isLoading = false;
  bool _isGeneratingAI = false;

  // Define theme colors based on NutriPal guidelines
  final Color primaryColor = const Color(0xFF2C9F6B);
  final Color secondaryColor = const Color(0xFF56C596);
  final Color accentColor = const Color(0xFF9BE8AD);
  final Color lightBackground = const Color(0xFFF5F9F7);
  final Color darkTextColor = const Color(0xFF333333);
  final Color mediumTextColor = const Color(0xFF666666);
  final Color lightTextColor = const Color(0xFF999999);

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
   
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    final meals = await _mealService.getMealsByDate(dateStr);
   
    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: lightBackground,
              onSurface: darkTextColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
   
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadMeals();
    }
  }

  Future<void> _generateAISuggestions() async {
    setState(() => _isGeneratingAI = true);
   
    final dateStr = _selectedDate.toIso8601String().split('T').first;
    await _mealService.generateAIMealSuggestions(dateStr);
   
    // Reload meals after generating suggestions
    await _loadMeals();
   
    setState(() => _isGeneratingAI = false);
   
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('AI meal suggestions generated!'),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _toggleMealCompletion(Meal meal) async {
    if (meal.id == null) return;
   
    final newStatus = !meal.isCompleted;
    await _mealService.toggleMealCompletion(meal.id!, newStatus);
   
    setState(() {
      _meals = _meals.map((m) =>
          m.id == meal.id ? m.copyWith(isCompleted: newStatus) : m
      ).toList();
    });
   
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? 'Meal marked as completed!' : 'Meal marked as not completed'),
        backgroundColor: newStatus ? primaryColor : Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _editMeal(Meal meal) async {
    // Navigate to edit screen and refresh on return
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMealScreen(meal: meal),
      ),
    );
   
    if (result == true) {
      _loadMeals();
    }
  }

  void _showMealDetails(Meal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getMealTypeColor(meal.mealType),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          meal.mealType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: mediumTextColor),
                      const SizedBox(width: 4),
                      Text(
                        meal.time,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: mediumTextColor,
                        ),
                      ),
                      const Spacer(),
                      if (meal.isAISuggested)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.purple[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: Colors.purple[700]),
                              const SizedBox(width: 4),
                              Text(
                                'AI Suggested',
                                style: TextStyle(
                                  color: Colors.purple[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    meal.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accentColor.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDescriptionPart(meal.notes),
                          style: TextStyle(
                            fontSize: 16,
                            color: darkTextColor,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_hasReasoning(meal.notes)) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Colors.purple[700], size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Why This Meal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.purple[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getReasoningPart(meal.notes),
                            style: TextStyle(
                              fontSize: 16,
                              color: darkTextColor,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleMealCompletion(meal),
                          icon: Icon(
                            meal.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                          ),
                          label: Text(meal.isCompleted ? 'Completed' : 'Mark as Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: meal.isCompleted ? primaryColor : Colors.white,
                            foregroundColor: meal.isCompleted ? Colors.white : primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            elevation: meal.isCompleted ? 2 : 0,
                            side: BorderSide(color: meal.isCompleted ? Colors.transparent : primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _editMeal(meal);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit Meal'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                            side: BorderSide(color: secondaryColor),
                            foregroundColor: secondaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDescriptionPart(String notes) {
    if (notes.contains('Why this meal:')) {
      return notes.split('Why this meal:')[0].trim();
    }
    return notes;
  }

  String _getReasoningPart(String notes) {
    if (notes.contains('Why this meal:')) {
      return notes.split('Why this meal:')[1].trim();
    }
    return '';
  }

  bool _hasReasoning(String notes) {
    return notes.contains('Why this meal:');
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showMealDetails(meal),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getMealTypeColor(meal.mealType),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        meal.mealType.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.schedule, size: 16, color: mediumTextColor),
                    const SizedBox(width: 4),
                    Text(
                      meal.time,
                      style: TextStyle(
                        color: mediumTextColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (meal.isAISuggested)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: Colors.purple[700]),
                            const SizedBox(width: 4),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: Colors.purple[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  meal.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getDescriptionPart(meal.notes),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumTextColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleMealCompletion(meal),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: meal.isCompleted ? primaryColor.withOpacity(0.1) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: meal.isCompleted ? primaryColor : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              meal.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                              color: meal.isCompleted ? primaryColor : Colors.grey[400],
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              meal.isCompleted ? 'Completed' : 'Mark complete',
                              style: TextStyle(
                                color: meal.isCompleted ? primaryColor : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: secondaryColor),
                      onPressed: () => _editMeal(meal),
                      tooltip: 'Edit meal',
                      style: IconButton.styleFrom(
                        backgroundColor: secondaryColor.withOpacity(0.1),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFFB347); // Warm orange
      case 'lunch':
        return const Color(0xFF56C596); // Medium green (our secondary color)
      case 'dinner':
        return const Color(0xFF5D75DE); // Soft blue
      case 'snack':
        return const Color(0xFFBA68C8); // Purple
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
   
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day + 1) {
      return 'Tomorrow';
    } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primaryColor.withOpacity(0.9),
                secondaryColor.withOpacity(0.9),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'NutriPal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              ),
              onPressed: () => _selectDate(context),
              tooltip: 'Select date',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 110, bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.9),
                  secondaryColor.withOpacity(0.9),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Meal Plan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateHeader(_selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _isGeneratingAI ? null : _generateAISuggestions,
                  icon: _isGeneratingAI
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.auto_awesome, size: 20),
                  label: Text(_isGeneratingAI
                      ? 'Generating meals...'
                      : 'Generate AI Meal Suggestions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                )
              : _meals.isEmpty
                ? _buildEmptyView()
                : ListView(
                    padding: const EdgeInsets.only(top: 16, bottom: 100),
                    physics: const BouncingScrollPhysics(),
                    children: _meals
                      .map((meal) => _buildMealCard(meal))
                      .toList(),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final dateStr = _selectedDate.toIso8601String().split('T').first;
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditMealScreen(
                meal: Meal(
                  date: dateStr,
                  mealType: 'lunch',
                  title: '',
                  time: '12:00',
                  notes: '',
                ),
              ),
            ),
          );
         
          if (result == true) {
            _loadMeals();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Custom Meal'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_menu,
              size: 60,
              color: primaryColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No meals planned yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkTextColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first meal or use our AI to suggest meals tailored to your preferences.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: mediumTextColor,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _generateAISuggestions,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate AI Suggestions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}