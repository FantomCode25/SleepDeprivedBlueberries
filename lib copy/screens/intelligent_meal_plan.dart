import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calender_event.dart';
import '../services/calender_service.dart';
import '../services/meal_recommendation_service.dart'; // New service
import 'add_event_screen.dart';
import 'meal_planner_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<CalendarEvent> _events = [];
  bool _isGeneratingPlan = false;

  @override
  void initState() {
    super.initState();
    _loadEventsForSelectedDate();
  }

  Future<void> _loadEventsForSelectedDate() async {
    final dateStr = _selectedDay.toIso8601String().split('T').first;
    final fetched = await CalendarService().fetchEventsByDate(dateStr);
    setState(() {
      _events = fetched;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    _loadEventsForSelectedDate();
  }

  Future<void> _generateMealPlan() async {
    setState(() {
      _isGeneratingPlan = true;
    });
    
    try {
      // Generate meal plan for the week starting from selected day
      final startDateStr = _selectedDay.toIso8601String().split('T').first;
      final recommendations = await MealRecommendationService().generateWeeklyPlan(startDateStr);
      
      // Save the generated meals to the calendar
      for (var meal in recommendations) {
        await CalendarService().addEvent(meal);
      }
      
      // Refresh the view
      _loadEventsForSelectedDate();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal plan generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate meal plan: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingPlan = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Calendar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEventsForSelectedDate,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: _onDaySelected,
            calendarFormat: CalendarFormat.month,
            // Highlight days with meal events
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return FutureBuilder<List<CalendarEvent>>(
                  future: CalendarService().fetchEventsByDate(
                    date.toIso8601String().split('T').first,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Container();
                    }
                    
                    // Group by meal type
                    final meals = snapshot.data!;
                    final hasMeals = meals.isNotEmpty;
                    
                    return hasMeals
                        ? Positioned(
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : Container();
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "Meals for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _isGeneratingPlan
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.auto_awesome),
                        onPressed: _generateMealPlan,
                        tooltip: 'Generate meal plan',
                      ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _events.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text("No meals planned for this day"),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text("Add meal"),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEventScreen(
                                  selectedDate: _selectedDay,
                                ),
                              ),
                            );
                            _loadEventsForSelectedDate();
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final e = _events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: _getMealTypeIcon(e.mealType),
                          title: Text("${e.title}"),
                          subtitle: Text("${e.time} • ${e.notes}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              // Edit functionality
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addEvent',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEventScreen(
                    selectedDate: _selectedDay,
                  ),
                ),
              );
              _loadEventsForSelectedDate();
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Meal',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'goToMealPlanner',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MealPlannerScreen(),
                ),
              );
            },
            child: const Icon(Icons.restaurant_menu),
            tooltip: 'Go to Meal Planner',
          ),
        ],
      ),
    );
  }
  
  Widget _getMealTypeIcon(String? mealType) {
    IconData iconData;
    Color iconColor;
    
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
        iconData = Icons.brightness_5;
        iconColor = Colors.orange;
        break;
      case 'lunch':
        iconData = Icons.wb_sunny;
        iconColor = Colors.amber;
        break;
      case 'dinner':
        iconData = Icons.nightlight_round;
        iconColor = Colors.indigo;
        break;
      case 'snack':
        iconData = Icons.cookie;
        iconColor = Colors.brown;
        break;
      default:
        iconData = Icons.restaurant;
        iconColor = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: iconColor.withOpacity(0.2),
      child: Icon(iconData, color: iconColor),
    );
  }
}