import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? _dailyData;
  List<Map<String, dynamic>> _recentActivities = [];
  Map<String, dynamic>? _sleepData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dailyDoc =
        await _firestore.collection('dailyTotals').doc('${user.uid}-$today').get();

    if (dailyDoc.exists) {
      setState(() {
        _dailyData = dailyDoc.data();
      });
    }

    // Fetch sleep data for the previous night
    final yesterday = DateFormat('yyyy-MM-dd').format(
        DateTime.now().subtract(const Duration(days: 1)));
    final sleepDoc =
        await _firestore.collection('sleepData').doc('${user.uid}-$yesterday').get();

    if (sleepDoc.exists) {
      setState(() {
        _sleepData = sleepDoc.data();
      });
    }

    final activitiesQuery = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .limit(5)
        .get();

    setState(() {
      _recentActivities =
          activitiesQuery.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('MMM dd, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: const Color(0xFF2C9F6B),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Hello 👋",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "Here's your summary for $today",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _buildDailySummaryCard(),
            const SizedBox(height: 20),
            _buildSleepCard(),
            const SizedBox(height: 20),
            Text("Recent Activities", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            ..._recentActivities.map(_buildActivityTile).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySummaryCard() {
    if (_dailyData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Colors.lightGreen.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow("Calories", _dailyData?['calories']?.toString() ?? "0", "kcal"),
            const SizedBox(height: 10),
            _summaryRow("Steps", _dailyData?['steps']?.toString() ?? "0", "steps"),
            const SizedBox(height: 10),
            _summaryRow("Water", _dailyData?['water']?.toString() ?? "0", "litres"),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepCard() {
    final yesterday = DateFormat('MMM dd').format(
        DateTime.now().subtract(const Duration(days: 1)));
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: const Color(0xFF9BE8AD).withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bedtime, color: Color(0xFF2C9F6B)),
                const SizedBox(width: 8),
                Text(
                  "Last Night's Sleep ($yesterday)",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C9F6B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _sleepData != null
                ? Column(
                    children: [
                      _sleepMetricRow(
                        "Duration",
                        "${_sleepData?['duration'] ?? 0}",
                        "hours",
                        Icons.access_time,
                      ),
                      const SizedBox(height: 12),
                      _sleepMetricRow(
                        "Quality",
                        "${_sleepData?['quality'] ?? 0}",
                        "/10",
                        Icons.star,
                      ),
                      const SizedBox(height: 12),
                      _sleepMetricRow(
                        "Deep Sleep",
                        "${_sleepData?['deepSleep'] ?? 0}",
                        "hours",
                        Icons.waves,
                      ),
                      if (_sleepData?['notes'] != null) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                        Text(
                          "Notes: ${_sleepData?['notes']}",
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ]
                    ],
                  )
                : const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "No sleep data recorded yet",
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // Navigate to sleep tracking screen
                // TODO: Implement navigation to sleep tracking
              },
              icon: const Icon(Icons.add, color: Color(0xFF2C9F6B)),
              label: const Text(
                "Record Sleep",
                style: TextStyle(color: Color(0xFF2C9F6B)),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF2C9F6B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sleepMetricRow(String label, String value, String unit, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF56C596)),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        Text(
          "$value $unit",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        Text("$value $unit",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    final type = activity['type'] ?? 'Unknown';
    final timestamp = (activity['timestamp'] as Timestamp?)?.toDate();
    final formattedTime = timestamp != null
        ? DateFormat('hh:mm a').format(timestamp)
        : 'Unknown';

    IconData activityIcon;
    switch (type) {
      case 'Meal':
        activityIcon = Icons.restaurant;
        break;
      case 'Water':
        activityIcon = Icons.water_drop;
        break;
      case 'Exercise':
        activityIcon = Icons.fitness_center;
        break;
      case 'Sleep':
        activityIcon = Icons.bedtime;
        break;
      default:
        activityIcon = Icons.timeline;
    }

    String detail = '';
    if (type == 'Meal') {
      detail = '${activity['calories']} kcal';
    } else if (type == 'Water') {
      detail = '${activity['amount']} L';
    } else if (type == 'Exercise') {
      detail = '${activity['steps']} steps, ${activity['calories']} kcal';
    } else if (type == 'Sleep') {
      detail = '${activity['duration']} hours, Quality: ${activity['quality']}/10';
    }

    return ListTile(
      leading: Icon(activityIcon, color: const Color(0xFF2C9F6B)),
      title: Text(type),
      subtitle: Text(detail),
      trailing: Text(formattedTime),
    );
  }
}