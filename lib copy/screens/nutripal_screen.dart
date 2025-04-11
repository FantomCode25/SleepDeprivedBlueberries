import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

// NutriPal Theme Colors - kept for reference
class NutriPalTheme {
  static const Color primaryColor = Color(0xFF2C9F6B); // Deep green
  static const Color secondaryColor = Color(0xFF56C596); // Medium green
  static const Color accentColor = Color(0xFF9BE8AD); // Light mint green
  static const Color backgroundColor = Color(0xFFF5FFF8); // Very light mint
  static const Color textColor = Color(0xFF333333); // Dark gray for text
  static const Color lightTextColor = Color(0xFFFFFFFF); // White text
}

// The main NutriPal screen widget that can be navigated to
class NutriPalScreen extends StatefulWidget {
  final String apiKey;

  const NutriPalScreen({
    Key? key,
    required this.apiKey,
  }) : super(key: key);

  @override
  _NutriPalScreenState createState() => _NutriPalScreenState();
}

class _NutriPalScreenState extends State<NutriPalScreen> {
  late final GenerativeModel model;
  final ChatUser user = ChatUser(id: '1', firstName: 'User');
  final ChatUser bot = ChatUser(id: '2', firstName: 'NutriPal');
  List<ChatMessage> messages = [];
  XFile? _attachedImage;
 
  @override
  void initState() {
    super.initState();
    // Initialize the model using the provided API key
    model = GenerativeModel(model: 'gemini-2.5-pro-exp-03-25', apiKey: widget.apiKey);
    // Add welcome message
    _addBotMessage("👋 Welcome to NutriPal! I'm your nutrition assistant. Ask me anything about healthy eating, meal plans, or upload food photos for analysis.");
  }

  void _addBotMessage(String text) {
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          user: bot,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'NutriPal',
              style: GoogleFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Text(
              'Nutrition with Intuition',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        backgroundColor: NutriPalTheme.primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                NutriPalTheme.primaryColor,
                NutriPalTheme.secondaryColor,
              ],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              NutriPalTheme.accentColor.withOpacity(0.2),
              NutriPalTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // DashChat for sending messages
                  DashChat(
                    currentUser: user,
                    onSend: (ChatMessage message) async {
                      if (_attachedImage != null) {
                        final imageMedia = ChatMedia(
                          url: _attachedImage!.path,
                          fileName: _attachedImage!.name,
                          type: MediaType.image,
                        );
                        message.medias = [imageMedia];
                        setState(() {
                          _attachedImage = null;
                        });
                      }
                      setState(() {
                        messages.insert(0, message);
                      });
                      await _sendMessageToModel(message);
                    },
                    messages: [],
                    messageOptions: MessageOptions(
                      showTime: false,
                      containerColor: Colors.transparent,
                      textColor: NutriPalTheme.textColor,
                    ),
                    inputOptions: InputOptions(
                      inputDecoration: InputDecoration(
                        hintText: "Ask about nutrition or food...",
                        prefixIcon: Icon(
                          Icons.message_outlined,
                          color: NutriPalTheme.secondaryColor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: NutriPalTheme.primaryColor, width: 1),
                        ),
                      ),
                      sendButtonBuilder: (onSend) {
                        return InkWell(
                          onTap: onSend,
                          child: Container(
                            height: 46,
                            width: 46,
                            decoration: BoxDecoration(
                              color: NutriPalTheme.primaryColor,
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                 
                  // Custom chat message list with markdown support
                  Positioned.fill(
                    bottom: 60,
                    child: CustomChatList(
                      messages: messages,
                      currentUser: user,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildAttachButton(),
                  const SizedBox(width: 8),
                  Text(
                    "Upload food photo",
                    style: TextStyle(
                      color: NutriPalTheme.secondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_attachedImage != null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_attachedImage!.path),
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Photo ready for analysis",
                          style: TextStyle(
                            color: NutriPalTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Send a message with your question"),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          _attachedImage = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: NutriPalTheme.accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.camera_alt),
        color: NutriPalTheme.primaryColor,
        onPressed: _pickImage,
        padding: EdgeInsets.zero,
        iconSize: 20,
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
        final response = await model.generateContent(contentParts);
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

    // Show loading message
    setState(() {
      messages.insert(
        0,
        ChatMessage(
          user: bot,
          text: "⌛ Analyzing your request...",
          createdAt: DateTime.now(),
        ),
      );
    });

    try {
      // Use the retry mechanism.
      final response = await sendRequestWithRetry(contentParts);
      final responseText = response.text ?? 'No response from NutriPal';
     
      // Remove the loading message
      setState(() {
        messages.removeAt(0);
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
      // Remove the loading message
      setState(() {
        messages.removeAt(0);
        messages.insert(
          0,
          ChatMessage(
            user: bot,
            text: 'Sorry, I encountered an error. Please try again later.',
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }
}

// Custom chat list widget with markdown support
class CustomChatList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ChatUser currentUser;

  const CustomChatList({
    Key? key,
    required this.messages,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message.user.id == currentUser.id;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NutriPalTheme.primaryColor,
                        NutriPalTheme.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: NutriPalTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              if (!isUser) const SizedBox(width: 10),
             
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: isUser ? NutriPalTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        )
                      : MarkdownBody(
                          data: message.text,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(fontSize: 16.0, color: NutriPalTheme.textColor),
                            strong: TextStyle(fontWeight: FontWeight.bold, color: NutriPalTheme.primaryColor),
                            blockquote: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: NutriPalTheme.textColor.withOpacity(0.7),
                            ),
                            h1: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: NutriPalTheme.primaryColor,
                            ),
                            h2: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: NutriPalTheme.primaryColor,
                            ),
                            h3: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: NutriPalTheme.primaryColor,
                            ),
                            a: TextStyle(
                              color: NutriPalTheme.secondaryColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                ),
              ),
             
              if (isUser) const SizedBox(width: 10),
              if (isUser)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: NutriPalTheme.accentColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      currentUser.firstName![0],
                      style: TextStyle(
                        color: NutriPalTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}