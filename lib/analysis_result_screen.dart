import 'package:flutter/material.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown_selectionarea.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String result;
  const AnalysisResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Insights")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectionArea(
            child: MarkdownBody(
              data: result,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16),
                h1: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                em: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
                code: const TextStyle(
                  backgroundColor: Color(0xFFEFEFEF),
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                codeblockPadding: const EdgeInsets.all(8),
                codeblockDecoration: BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquote: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
