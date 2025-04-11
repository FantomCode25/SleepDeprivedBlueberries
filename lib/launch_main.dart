import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'launch_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set app to fullscreen mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [], // Hide all system UI overlays for true fullscreen
  );
  
  // Set preferred orientations to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2C9F6B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C9F6B),
          primary: const Color(0xFF2C9F6B),
          secondary: const Color(0xFF56C596),
        ),
      ),
      home: const LaunchPage(),
    );
  }
}