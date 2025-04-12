import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calender_event.dart';
import '../services/calender_service.dart';
import 'add_event_screen.dart';
import 'meal_planner_screen.dart';

// Define theme colors based on the guidelines
class NutriPalTheme {
  static const Color primary = Color(0xFF2C9F6B);
  static const Color secondary = Color(0xFF56C596);
  static const Color accent = Color(0xFF9BE8AD);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<CalendarEvent> _events = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Meal Calendar",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: NutriPalTheme.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [NutriPalTheme.accent.withOpacity(0.3), Colors.white],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: _onDaySelected,
                calendarFormat: CalendarFormat.month,
                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: NutriPalTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: NutriPalTheme.secondary.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.grey[700]),
                  outsideTextStyle: TextStyle(color: Colors.grey[400]),
                ),
                headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NutriPalTheme.primary,
                  ),
                  formatButtonTextStyle: TextStyle(
                    fontSize: 14,
                    color: NutriPalTheme.primary,
                  ),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: NutriPalTheme.secondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Events for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: NutriPalTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: NutriPalTheme.secondary.withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No meal events for this day",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _events.length,
                      itemBuilder: (context, index) {
                        final e = _events[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: NutriPalTheme.accent,
                              child: Icon(
                                _getMealIcon(e.mealType),
                                color: NutriPalTheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              e.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "Time: ${e.time}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Type: ${e.mealType}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                                if (e.notes.isNotEmpty)
                                  Text(
                                    "Notes: ${e.notes}",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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
builder: (_) => AddEventScreen(selectedDate: _selectedDay),
                ),
              );
              _loadEventsForSelectedDate();
            },
            backgroundColor: NutriPalTheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Event',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'goToMealPlanner',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
              );
            },
            backgroundColor: NutriPalTheme.secondary,
            child: const Icon(Icons.restaurant_menu, color: Colors.white),
            tooltip: 'Go to Meal Planner',
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.apple;
      default:
        return Icons.restaurant;
    }
  }
}