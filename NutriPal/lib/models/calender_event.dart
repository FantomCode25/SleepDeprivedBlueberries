class CalendarEvent {
  final String id;
  final String title;
  final String date;
  final String time;
  final String mealType;
  final String notes;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.mealType,
    required this.notes,
  });

  factory CalendarEvent.fromMap(String id, Map<String, dynamic> data) {
    return CalendarEvent(
      id: id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      mealType: data['mealType'] ?? '',
      notes: data['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'time': time,
      'mealType': mealType,
      'notes': notes,
    };
  }
}
