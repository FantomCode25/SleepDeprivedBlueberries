import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _buttonOpacity;
  late Animation<double> _teamNameOpacity;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Title animation
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Tagline animation
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.8, curve: Curves.easeIn),
      ),
    );

    // Button animation
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    // Team name animation
    _teamNameOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Auto-navigate after 4 seconds if user doesn't press the button
    _navigationTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) {
        navigateToLogin();
      }
    });
  }

  void navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Using MaterialApp.router to enable edge-to-edge display
    return Material(
      // Remove default Material white background
      color: Colors.transparent,
      child: Container(
        // Ensure container fills the entire screen
        width: size.width,
        height: size.height,
        child: Stack(
          fit: StackFit.expand, // Ensure stack fills entire container
          children: [
            // Background color in case GIF fails to load
            Container(
              color: const Color(0xFF2C9F6B),
              width: size.width,
              height: size.height,
            ),

            // Background GIF with improved visibility
            SizedBox(
              width: size.width,
              height: size.height,
              child: Image.asset(
                'assets/launch.gif',
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback gradient if GIF fails to load
                  return Container(
                    width: size.width,
                    height: size.height,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2C9F6B),
                          Color(0xFF56C596),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Subtle color overlay (very light)
            Container(
              width: size.width,
              height: size.height,
              color: const Color(0xFF2C9F6B).withOpacity(0.15),
            ),

            // Main Content - Full width, no padding
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + 60),

                // Title - Top Center
                AnimatedBuilder(
                  animation: _titleOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _titleOpacity.value,
                      child: Text(
                        'NutriPal',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Tagline - Below Title
                AnimatedBuilder(
                  animation: _taglineOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _taglineOpacity.value,
                      child: Text(
                        'nutrition with intuition',
                        style: TextStyle(
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.5,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Get Started Button - Bottom Center
                AnimatedBuilder(
                  animation: _buttonOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _buttonOpacity.value,
                      child: Container(
                        width: size.width * 0.7,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2C9F6B),
                              Color(0xFF56C596),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // Cancel the auto-navigation timer
                            _navigationTimer?.cancel();
                            // Navigate to login screen
                            navigateToLogin();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.zero,
                            minimumSize: Size(size.width * 0.7, 56),
                          ),
                          child: const Text(
                            'GET STARTED',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Team Name - Below Get Started
                AnimatedBuilder(
                  animation: _teamNameOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _teamNameOpacity.value,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15.0, bottom: 60.0),
                        child: Text(
                          'by SleepDeprivedBlueberries',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.5,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}