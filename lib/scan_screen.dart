import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../services/ai_service.dart';
import 'analysis_result_screen.dart';

// NutriPal Theme Colors
class NutriPalTheme {
  static const Color primaryColor = Color(0xFF2C9F6B); // Deep green
  static const Color secondaryColor = Color(0xFF56C596); // Medium green
  static const Color accentColor = Color(0xFF9BE8AD); // Light mint green
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, secondaryColor],
  );

  static const TextStyle appNameStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
  );

  static const TextStyle taglineStyle = TextStyle(
    fontSize: 16,
    fontStyle: FontStyle.italic,
    color: Colors.white,
  );

  static const TextStyle headerStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 15,
    color: Colors.black87,
  );

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static final CardTheme cardTheme = CardTheme(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: Colors.white,
  );
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  String _recognizedText = '';
  bool _isProcessing = false;

  Future<void> pickImage(bool fromCamera) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _recognizedText = 'Processing...';
        _isProcessing = true;
      });
      await processImage(_image!);
    }
  }

  Future<void> processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    textRecognizer.close();

    final scannedText = recognizedText.text;
    setState(() {
      _recognizedText = scannedText;
      _isProcessing = false;
    });

    await analyzeWithAI(scannedText);
  }

  Future<void> analyzeWithAI(String scannedText) async {
    try {
      setState(() {
        _isProcessing = true;
      });
      final result = await AIService.getInsightFromAI(scannedText);

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("AI analysis failed: $e"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan & Analyze", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: NutriPalTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF0F9F4)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                "Nutrition with Intuition",
                style: NutriPalTheme.taglineStyle.copyWith(color: NutriPalTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : () => pickImage(true),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Camera"),
                      style: NutriPalTheme.primaryButtonStyle,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : () => pickImage(false),
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Gallery"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NutriPalTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _image != null
                  ? Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _image!,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_search,
                              size: 80,
                              color: NutriPalTheme.secondaryColor.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No image selected",
                              style: NutriPalTheme.bodyStyle.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              if (_isProcessing)
                Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(NutriPalTheme.primaryColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Analyzing nutrition information...",
                        style: NutriPalTheme.bodyStyle.copyWith(
                          color: NutriPalTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_recognizedText.isNotEmpty && !_isProcessing)
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Recognized Text",
                            style: NutriPalTheme.headerStyle.copyWith(fontSize: 18),
                          ),
                          const Divider(color: NutriPalTheme.secondaryColor),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _recognizedText,
                                style: NutriPalTheme.bodyStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
