import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dashboard_screen.dart';
import 'scan_screen.dart';
import 'planner_screen.dart';
import 'chat_screen.dart';
import 'onboarding_form.dart';
import 'calender_screen.dart'; // ✅ added
import 'log_activity_screen..dart';
import 'dashboard.dart'; // ✅ added
import 'nutripal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const HomeGrid(),
    const ScanScreen(),
    const DashboardScreen(),
    const CalendarScreen(),
     // ✅ changed from placeholder
    // const ChatScreen(),     // ✅ changed from placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF9FFFC), // Very light mint
                  Color(0xFFEBF7F1), // Light background
                ],
              ),
            ),
          ),
          
          // Custom app bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2C9F6B),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: Color(0xFF2C9F6B),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NutriPal',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Nutrition with Intuition',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person_outline, color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OnboardingForm()),
                          );
                        },
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_outlined, color: Colors.white),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + 80, // Adjust based on app bar height
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(1, Icons.camera_alt_outlined, Icons.camera_alt, 'Scan'),
                _buildNavItem(2, Icons.analytics_outlined, Icons.analytics, 'Stats'),
                _buildNavItem(3, Icons.calendar_today_outlined, Icons.calendar_today, 'Plan'),
                _buildNavItem(4, Icons.chat_outlined, Icons.chat, 'Chat'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C9F6B).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlinedIcon,
              color: isSelected ? const Color(0xFF2C9F6B) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF2C9F6B) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeGrid extends StatelessWidget {
  const HomeGrid({super.key});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF56C596), Color(0xFF2C9F6B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C9F6B).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hey there!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your nutrition journey with NutriPal today',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogActivityScreen()),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: const Color(0xFF2C9F6B),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
  child: const Text(
    'Log todays details',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
                    ],
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.spa_outlined,
                    size: 40,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Daily stats
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Stats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C9F6B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(context, Icons.local_fire_department_outlined, '1,200', 'Calories'),
                    _buildStatItem(context, Icons.water_drop_outlined, '2.5L', 'Water'),
                    _buildStatItem(context, Icons.directions_walk_outlined, '3,500', 'Steps'),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          
          // Features grid title
          const Text(
            'Features',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Features grid
          // GridView.count(
          //   physics: const NeverScrollableScrollPhysics(),
          //   shrinkWrap: true,
          //   crossAxisCount: 2,
          //   mainAxisSpacing: 15,
          //   crossAxisSpacing: 15,
          //   childAspectRatio: 1.1,
          //   children: [
          //     _buildFeatureTile(
          //       context,
          //       'Scan Label',
          //       'Analyze food nutrition',
          //       Icons.camera_alt_outlined,
          //       const Color(0xFF9BE8AD),
          //       const Color(0xFF2C9F6B),
          //       const ScanScreen(),
          //     ),
          //     _buildFeatureTile(
          //       context,
          //       'Dashboard',
          //       'Track your progress',
          //       Icons.analytics_outlined,
          //       const Color(0xFF56C596),
          //       const Color(0xFF2C9F6B),
          //       const DashboardScreen(),
          //     ),
          //     _buildFeatureTile(
          //       context,
          //       'Meal Planner',
          //       'Plan healthy meals',
          //       Icons.calendar_today_outlined,
          //       const Color(0xFF9BE8AD),
          //       const Color(0xFF2C9F6B),
          //       const CalendarScreen(),
          //     ),
          //     _buildFeatureTile(
          //       context,
          //       'AI Chatbot',
          //       'Get nutrition advice',
          //       Icons.chat_bubble_outline,
          //       const Color(0xFF56C596),
          //       const Color(0xFF2C9F6B),
          //       const HomeScreen(),
          //     ),
          //   ],
          // ),
          GridView.count(
  physics: const NeverScrollableScrollPhysics(),
  shrinkWrap: true,
  crossAxisCount: 2,
  mainAxisSpacing: 15,
  crossAxisSpacing: 15,
  childAspectRatio: 1.1,
  children: [
    _buildFeatureTile(
      context,
      'Scan Label',
      'Analyze food nutrition',
      Icons.camera_alt_outlined,
      const Color(0xFF9BE8AD),
      const Color(0xFF2C9F6B),
      const ScanScreen(),
    ),
    _buildFeatureTile(
      context,
      'Dashboard',
      'Track your progress',
      Icons.analytics_outlined,
      const Color(0xFF56C596),
      const Color(0xFF2C9F6B),
      const DashboardScreen(),
    ),
    _buildFeatureTile(
      context,
      'Meal Planner',
      'Plan healthy meals',
      Icons.calendar_today_outlined,
      const Color(0xFF9BE8AD),
      const Color(0xFF2C9F6B),
      const CalendarScreen(),
    ),
    _buildFeatureTile(
      context,
      'AI Chatbot',
      'Get nutrition advice',
      Icons.chat_bubble_outline,
      const Color(0xFF56C596),
      const Color(0xFF2C9F6B),
      const NutriPalScreen(apiKey: "AIzaSyAVVrCEk0IwV3cFHtmnbRCIfxVm3xscyUY"),
    ),
  ],
),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2C9F6B).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF2C9F6B),
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color startColor,
    Color endColor,
    Widget route,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => route),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: endColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}