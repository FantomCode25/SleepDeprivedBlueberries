# SleepDeprivedBlueberries
🚀 Project NutriPal

**Team Name:** SleepDeprivedBlueberries  
**Hackathon:** FantomCode '25  
**Date:** 12/04/2025

# 📖 Table of Contents
- [Introduction](#introduction)
- [Problem Statement](#problem-statement)
- [Solution Overview](#solution-overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Installation & Usage](#installation--usage)
- [Team Members](#team-members)

![image](https://github.com/user-attachments/assets/d2ec13ce-c35c-4ff4-8b99-65b2e95f0c37)

# 🧠 Introduction
Ever picked up a food product and wondered what "Propyl Gallate" is or if "Potassium Bromate" is safe? NutriScan is your personal food detective. Our mobile app uses OCR and AI to instantly analyze meals, explain ingredients in plain English, and tailor suggestions based on your allergies, fitness goals, and medical needs. It's designed for health-conscious users, fitness enthusiasts, and anyone tired of decoding food labels.

# ❗ Problem Statement
Documentation is often overlooked or hastily created, leading to confusion for new users and contributors. A well-structured README is essential for project adoption and collaboration, yet many developers struggle to create one that effectively communicates all necessary information.

# 💡 Solution Overview

- **Snap & Decode**  
  Camera + ML Kit OCR reads labels; Gemini 2.5 explains ingredients and shows a health score.
  
- **AI Meal Planner**  
  Personalized recipes and calendar‑synced reminders based on your dietary profile.
  
- **Real‑Time Alerts**  
  Push notifications for missed meals or risky additives; wearable integration updates your calorie budget.
![WhatsApp Image 2025-04-12 at 10 27 57_655293cf](https://github.com/user-attachments/assets/63d1b975-315a-4e47-abf8-734e24d2ca1e)
![WhatsApp Image 2025-04-12 at 10 27 57_84c8157f](https://github.com/user-attachments/assets/37c72197-6856-45fb-a092-a6fa9deb0056)
![WhatsApp Image 2025-04-12 at 10 27 58_f14bd40a](https://github.com/user-attachments/assets/27e8afa1-8a41-4598-9840-24f1ed685bfd)
![WhatsApp Image 2025-04-12 at 10 27 58_b423e0f6](https://github.com/user-attachments/assets/af9dc649-5ba8-4272-accc-d176e5efda0a)
![WhatsApp Image 2025-04-12 at 10 27 58_b94df0c2](https://github.com/user-attachments/assets/e954ff58-5032-4e9c-bd75-31b532380008)
![WhatsApp Image 2025-04-12 at 10 27 59_7f1561f8](https://github.com/user-attachments/assets/c751955a-6bc0-445b-81be-bd2f47351a38)
![WhatsApp Image 2025-04-12 at 10 27 59_95249e76](https://github.com/user-attachments/assets/8c77be84-bc90-492a-bc96-bc2ee728959c)







# 🛠️ Tech Stack

**Frontend:**
- Flutter (Dart)
- Material Design
- Google Fonts
- Custom UI Components

**Backend:**
- Firebase Authentication
- Cloud Firestore
- Google Cloud Services

**Database:**
- Cloud Firestore (NoSQL)

**APIs / Libraries:**
- Google ML Kit (Text Recognition)
- Google Generative AI (Gemini)
- HTTP Client
- Image Picker
- Table Calendar
- Markdown Support
- Chat Interface (dash_chat_2)

**Tools:**
- Flutter SDK
- Firebase CLI
- Android Studio / Xcode
- VS Code
- Flutter DevTools
- GitHub Actions (for CI/CD)

## 🧩 Architecture

The application follows a modern Flutter architecture with the following components:

![image](https://github.com/user-attachments/assets/92741ef2-c370-4b01-aa55-fb14692ffd1a)
*Architecture Diagram for Our System*


## 🧪 Installation & Usage

### Prerequisites
- Flutter SDK (^3.7.2)
- Dart SDK
- Firebase CLI
- Android Studio / Xcode (for mobile development)
- VS Code / Android Studio (for development)

### Dependencies
All dependencies are listed in `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.7
  google_fonts: ^6.2.1
  percent_indicator: ^4.2.3
  firebase_core: ^2.24.0
  firebase_auth: ^4.11.0
  cloud_firestore: ^4.9.1
  google_mlkit_text_recognition: ^0.11.0
  image_picker: ^1.1.2
  image: ^4.0.12
  path: ^1.9.0
  path_provider: ^2.1.2
  http: ^1.1.0
  flutter_dotenv: ^5.0.2
  table_calendar: ^3.0.9
  flutter_markdown: ^0.7.1
  dash_chat_2: ^0.0.21
  google_generative_ai: ^0.4.6
```

### Steps

1. Clone the repository:
```bash
git clone https://github.com/your-repo-url.git
```

2. Navigate into the project directory:
```bash
cd mockapp
```

3. Install dependencies:
```bash
flutter pub get
```

4. Configure Firebase:
   - Create a Firebase project
   - Add Android/iOS apps to your Firebase project
   - Download and add configuration files:
     - Android: `google-services.json`
     - iOS: `GoogleService-Info.plist`
   - Configure environment variables in `.env` file

5. Start the development server:
```bash
flutter run
```

## 📌 Project Structure
```
mockapp/
├── lib/              # Main application code
│   ├── main.dart     # Application entry point
│   ├── screens/      # UI screens
│   ├── widgets/      # Reusable widgets
│   ├── services/     # Business logic and services
│   ├── models/       # Data models
│   └── utils/        # Utility functions
├── assets/           # Static assets
│   └── launch.gif    # Launch screen animation
├── pubspec.yaml      # Project dependencies
└── README.md         # Project documentation
```

> 📌 **Tip:** For development, you can use the Flutter DevTools for debugging and performance monitoring.

# 👥 Team Members
- Lahari R
- Madhubala M  
- Kushagra Awasthi
- L V S Aditya

---

Made with ❤️ by SleepDeprivedBlueberries
