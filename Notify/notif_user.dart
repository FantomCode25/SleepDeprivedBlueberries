import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// In a real app, you could use FirebaseAuth for authentication.
// Here we simulate a login process.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

/// Initialize the local notifications plugin.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp();

  // Initialize the local notifications plugin.
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPal',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(),
    );
  }
}

// ------------------------------------------------------------------
// LOGIN PAGE
// ------------------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers for login inputs.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  // Simulated login using a fixed UID.
  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // For a real app, use FirebaseAuth:
      // final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      //    email: _emailController.text.trim(), 
      //    password: _passwordController.text.trim());
      
      // In this simulation, we log in as a fixed user.
      const String fixedUID = "0IAKDcoaflVPeBEm32YvBkvrMug1";

      // Navigate to the MealsPage and pass the fixed UID.
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => MealsPage(userId: fixedUID),
      ));
    } catch (e) {
      setState(() {
        _error = "Login failed: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NutriPal Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: 'Email (or username)'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------
// MEALS PAGE
// ------------------------------------------------------------------
class MealsPage extends StatefulWidget {
  final String userId;
  const MealsPage({required this.userId, super.key});
  @override
  State<MealsPage> createState() => _MealsPageState();
}

class _MealsPageState extends State<MealsPage> {
  final TextEditingController _dateController = TextEditingController(
      text: DateFormat("yyyy-MM-dd").format(DateTime.now()));
  // We keep a list of scheduled meals that matched our criteria.
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _scheduledMeals = [];
  bool _loading = false;
  String? _error;

  // Fetch meals from Firestore for the given date and schedule notifications
  // for breakfast, lunch, and dinner.
  Future<void> _fetchAndScheduleMeals() async {
    setState(() {
      _loading = true;
      _error = null;
      _scheduledMeals = [];
    });
    try {
      String selectedDate = _dateController.text.trim();
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.userId)
          .collection('meals')
          .where('date', isEqualTo: selectedDate)
          .get();

      // Build a map to hold one entry per meal type.
      Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> mealsByType = {};

      // We want to schedule at most one notification per meal type:
      for (final doc in snapshot.docs) {
        final String mealType =
            (doc.data()['mealType'] as String).toLowerCase();
        // Only consider breakfast, lunch, dinner and keep the first one found.
        if ((mealType == 'breakfast' || mealType == 'lunch' || mealType == 'dinner') &&
            !mealsByType.containsKey(mealType)) {
          mealsByType[mealType] = doc;
        }
      }

      // Schedule notifications for each of the three meal types if available.
      for (final type in ['breakfast', 'lunch', 'dinner']) {
        if (mealsByType.containsKey(type)) {
          await _scheduleMealNotification(mealsByType[type]!);
          _scheduledMeals.add(mealsByType[type]!);
        }
      }
    } catch (e) {
      setState(() {
        _error = "Error fetching meals: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  /// Combines the date and time strings and parses them into a DateTime.
  /// Expects date in "yyyy-MM-dd" and time in "HH:mm" (24-hour) format.
  DateTime _parseMealDateTime(String dateStr, String timeStr) {
    final String combined = "$dateStr $timeStr";
    return DateFormat("yyyy-MM-dd HH:mm").parse(combined);
  }

  /// Schedules a local notification for a given meal document.
  Future<void> _scheduleMealNotification(
      QueryDocumentSnapshot<Map<String, dynamic>> mealDoc) async {
    final data = mealDoc.data();
    final String dateStr = data['date'] as String;
    final String timeStr = data['time'] as String; // e.g. "08:00"
    final String mealType = data['mealType'] as String;
    final String title = data['title'] as String;

    // Parse date and time.
    DateTime mealDateTime = _parseMealDateTime(dateStr, timeStr);
    // Convert to a timezone-aware DateTime.
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(mealDateTime, tz.local);

    // Capitalize mealType
    final String capitalizedMealType =
        "${mealType[0].toUpperCase()}${mealType.substring(1)}";

    // Construct the notification message.
    final String notifMessage =
        "$capitalizedMealType time: $title @ $timeStr";

    // Create a unique notification ID based on document id.
    final int notificationId = mealDoc.id.hashCode & 0x7fffffff;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'nutripal_meal_reminders', // Channel ID.
      'NutriPal Meal Reminders', // Channel name.
      channelDescription: 'Reminders for your planned meals',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // Schedule the notification.
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      "$capitalizedMealType Meal", // Notification title.
      notifMessage,               // Notification message.
      scheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // Uncomment the next line if you wish the notification to repeat daily.
      // matchDateTimeComponents: DateTimeComponents.time,
      payload: mealDoc.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Plans & Reminders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date input field.
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                  labelText: 'Enter Date (yyyy-MM-dd)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _fetchAndScheduleMeals,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Fetch Meals & Schedule 3 Reminders'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _scheduledMeals.isEmpty
                  ? const Center(
                      child: Text(
                          'No meals found for breakfast, lunch, or dinner for the selected date.'),
                    )
                  : ListView.builder(
                      itemCount: _scheduledMeals.length,
                      itemBuilder: (context, index) {
                        final meal = _scheduledMeals[index].data();
                        return ListTile(
                          title:
                              Text("${meal['mealType']} - ${meal['title']}"),
                          subtitle: Text("Time: ${meal['time']}\n${meal['notes']}"),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
