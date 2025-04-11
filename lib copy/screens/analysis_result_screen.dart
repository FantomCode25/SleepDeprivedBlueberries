import 'package:flutter/material.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String result;
  const AnalysisResultScreen({required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AI Insights")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            result,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
