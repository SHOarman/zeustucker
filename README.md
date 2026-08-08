# Zeustucker - Fitness & Workout Tracker

A comprehensive Flutter application for managing fitness routines, meal planning, workout tracking, and personal health statistics. Zeustucker features both user and admin interfaces for personalized fitness management.

## ✨ Features

### 👤 User Features
* **Authentication System**: Secure registration, login, and password recovery.
* **Home Dashboard**: Quick overview of daily fitness activities and macro targets.
* **Workout Management**: Track routines with detailed exercise logs.
* **Meal Planning**: Schedule and monitor nutritional intake.
* **Statistics**: View comprehensive progress via charts and analytics.

### 🛡️ Admin Features
* **Client Management**: Add, edit, and monitor user progress.
* **Routine Management**: Create and assign workout routines to clients.
* **Content Control**: Generate and manage fitness articles or "stories."
* **Bulk Operations**: Manage multiple clients and regenerate content efficiently.

## 🛠 Tech Stack
* **Framework**: Flutter
* **State Management & Routing**: GetX
* **Networking**: http package
* **Local Storage**: shared_preferences
* **UI/UX & Assets**: flutter_svg, google_fonts, lottie, device_preview
* **Utilities**: image_picker, url_launcher

## 📁 Folder Structure
The project follows a clean, feature-driven folder structure inside the `lib/` directory:

```text
lib/
│
├── core/                 # Core configurations and data layers
│   ├── dependency_injection/ # GetX lazy bindings and DI setup
│   ├── route/            # Route definitions and AppPages configuration
│   └── services/         # API services for external HTTP calls
│
├── services/             # Business logic and GetX Controllers
│   ├── controllers/      # Controllers (e.g., auth_controller, homecontroller)
│   └── ...
│
├── presentation/         # UI Screens and Views
│   ├── admininterface/   # Admin specific screens (Client Details, Manage Clients)
│   ├── userinterface/    # User specific screens (Home, Stats, Library)
│   └── widgets/          # Reusable UI components
│
└── main.dart             # Entry point of the application
```

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (stable channel)
* Dart SDK
* Android Studio / VS Code

### Installation
1. Clone the repository:
   ```bash
   git clone <your-repo-url>
   cd zeustucker03003
   ```
2. Get all dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## 🧪 Running Tests
To verify the core logic of the application (Models and Controllers), run:
```bash
flutter test
```

## 🔌 APIs Used
This project uses custom backend APIs for data synchronization. Ensure your backend server is running and the endpoints in `lib/core/services/` are correctly configured.

## 📦 Build for Release (Android)
To generate a release APK for Android:
```bash
flutter build apk --release
```
*Note: Internet permissions are explicitly configured in `AndroidManifest.xml` to ensure API calls succeed in the release build.*




