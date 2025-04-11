import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

// For local testing only: bypass certificate verification
HttpClient createHttpClient() {
  HttpClient httpClient = HttpClient()
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  return httpClient;
}

void main() {
  // Use your API key here.
  final apiKey = "AIzaSyAVVrCEk0IwV3cFHtmnbRCIfxVm3xscyUY";
  final model = GenerativeModel(model: 'gemini-2.5-pro-exp-03-25', apiKey: apiKey);
  runApp(MyApp(model: model));
}

class MyApp extends StatelessWidget {
  final GenerativeModel model;

  const MyApp({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatPage(model: model),
    );
  }
}

class ChatPage extends StatefulWidget {
  final GenerativeModel model;

  const ChatPage({super.key, required this.model});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatUser user = ChatUser(id: '1', firstName: 'User');
  final ChatUser bot = ChatUser(id: '2', firstName: 'Gemini');
  List<ChatMessage> messages = [];
  XFile? _attachedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: user,
              // When a message is sent, combine text and any attached image before sending.
              onSend: (ChatMessage message) async {
                // If an image was attached, add it to the message.
                if (_attachedImage != null) {
                  final imageMedia = ChatMedia(
                    url: _attachedImage!.path, // raw file path
                    fileName: _attachedImage!.name,
                    type: MediaType.image,
                  );
                  // Attach the image to the message.
                  message.medias = [imageMedia];
                  // Clear the attached image after use.
                  setState(() {
                    _attachedImage = null;
                  });
                }
                // Add the message to the conversation and send it to Gemini.
                setState(() {
                  messages.insert(0, message);
                });
                await _sendMessageToModel(message);
              },
              messages: messages,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                const Text("Attach an image"),
              ],
            ),
          ),
          // Optionally, display a preview of the attached image.
          if (_attachedImage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Image.file(
                    File(_attachedImage!.path),
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(width: 8),
                  const Text("Image attached"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Allows the user to pick an image from the gallery.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _attachedImage = pickedFile;
      });
    }
  }

  // Compresses the image using the 'image' package.
  Future<List<int>> compressImage(File file, {int targetWidth = 800, int quality = 85}) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      // Resize while maintaining aspect ratio.
      img.Image resized = img.copyResize(image, width: targetWidth);
      return img.encodeJpg(resized, quality: quality);
    }
    return bytes;
  }

  // Implements retry logic with exponential backoff for 503 errors.
  Future<dynamic> sendRequestWithRetry(List<Content> contentParts, {int maxRetries = 3}) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await widget.model.generateContent(contentParts);
        return response;
      } catch (e) {
        if (e.toString().contains("503")) {
          // Wait an increasing delay for each attempt.
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        } else {
          rethrow;
        }
      }
    }
    throw Exception("The model is overloaded. Please try again later.");
  }

  // Builds the content parts for Gemini from both text and image.
  Future<void> _sendMessageToModel(ChatMessage message) async {
    List<Content> contentParts = [];

    // Add text content if provided.
    if (message.text.isNotEmpty) {
      contentParts.add(Content.text(message.text));
    }

    // Add image content for each attached media.
    for (var media in message.medias ?? []) {
      if (media.type == MediaType.image) {
        final file = File(media.url); // media.url holds the file path
        // Compress the image to reduce the size.
        final compressedBytes = await compressImage(file);
        // Use Uint8List.fromList to convert the bytes list to Uint8List.
        contentParts.add(Content.data('image/jpeg', Uint8List.fromList(compressedBytes)));
      }
    }

    if (contentParts.isEmpty) return;

    try {
      // Use the retry mechanism.
      final response = await sendRequestWithRetry(contentParts);
      final responseText = response.text ?? 'No response from Gemini';
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            user: bot,
            text: responseText,
            createdAt: DateTime.now(),
          ),
        );
      });
    } catch (e) {
      setState(() {
        messages.insert(
          0,
          ChatMessage(
            user: bot,
            text: 'Error: $e',
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }
}