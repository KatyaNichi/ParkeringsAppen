# ParkeringsAppen (Flutter Client)

The Flutter client application for the Parkeringsapp system, featuring enhanced state management with BLoC, improved architectural design, and Firebase integration.

## Project Overview

The ParkeringsAppen system consists of two repositories:

1. **[Server](https://github.com/KatyaNichi/Parkeringsapp)**: A RESTful API built with Dart and Shelf framework
2. **[Client](https://github.com/KatyaNichi/ParkeringsAppen)**: A Flutter application with advanced state management and Firebase integration

## Features and Improvements

- 🚀 State Management with BLoC
- 🔥 Firebase Authentication and Firestore Integration
- 🔒 Enhanced Authentication Flow
- 💻 Cross-Platform Compatibility
- 🎨 Responsive UI Design
- 📱 Dynamic Configuration
- 🔍 Improved Error Handling

## Key Architectural Changes

### State Management
- Implemented BLoC (Business Logic Component) pattern
- Separate state management for:
  - Authentication
  - Vehicles
  - Parking Spaces
  - Parking Sessions

### Firebase Integration
- **Firebase Authentication** for user management
  - Email/password authentication
  - Secure user registration and login
  
- **Cloud Firestore** for data storage
  - User profiles stored in Firestore
  - Vehicle management with Firestore
  - Parking spaces database
  - Parking session tracking

### Dynamic Configuration
- Platform-specific configuration
- Supports Android, iOS, and web platforms
- Automatic detection of development environment

## Getting Started

### Prerequisites

- Dart SDK (3.0.0 or later)
- Flutter SDK (3.10.0 or later)
- Firebase account and project
- Android/iOS development environment

### Setup and Installation

1. Clone the repository
   ```bash
   git clone https://github.com/KatyaNichi/ParkeringsAppen.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication and Firestore
   - Add your application to Firebase project
   - Download and add configuration files
   - Update Firebase configuration in project

4. Run the application
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── blocs/                  # BLoC state management
│   ├── auth/
│   ├── vehicle/
│   ├── parking/
│   └── parking_space/
├── models/                 # Data models
├── repositories/           # Data access layer
│   ├── firebase_auth_repository.dart
│   ├── firestore_person_repository.dart
│   ├── firestore_vehicle_repository.dart
│   ├── firestore_parking_repository.dart
│   └── firestore_parking_space_repository.dart
├── screens/                # UI screens
├── services/               # Service classes
└── main.dart               # Application entry point
```

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web

## Technologies and Libraries

- Flutter
- Firebase (Authentication, Firestore)
- BLoC for State Management
- HTTP for API Communication (fallback)
- JSON Serialization
- Platform-specific configurations

## Firebase Data Structure

The application stores data in the following Firestore collections:

- **persons**: User profiles with name and personal identification number
- **vehicles**: User vehicles with type, registration number, and owner reference
- **parkingSpaces**: Available parking spaces with address and hourly price
- **parkings**: Parking sessions with vehicle reference, parking space reference, start time, and end time

## Configuration

### Firebase Configuration
1. Add your Firebase configuration files:
   - For Android: `android/app/google-services.json`
   - For iOS: `ios/Runner/GoogleService-Info.plist`
   - For Web: Update `web/index.html` with Firebase script

### Base URL Configuration (Legacy/Fallback)
Modify getBaseUrl() in configuration files:
```dart
String getBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080';
  } else if (Platform.isIOS) {
    return 'http://localhost:8080';
  } else {
    return 'http://YOUR_LOCAL_IP:8080';
  }
}
```

## Authentication Flow

1. User enters credentials (register or login)
2. `AuthBloc` processes the request through `FirebaseAuthRepository`
3. Upon successful authentication, user profile is retrieved from Firestore
4. If no profile exists (for new users), one is created
5. User is redirected to the main application interface

## Upcoming Features

- ⏳ Implement real-time updates using Firestore streams
- ⏳ Add third-party authentication options (Google, Apple, etc.)
- ⏳ Create Firebase Cloud Functions for server-side logic
- ⏳ Add push notifications for parking events
- ⏳ Implement comprehensive unit and widget tests
- ⏳ Add advanced caching mechanisms
- ⏳ Implement offline support

## Troubleshooting

- Ensure Firebase project is properly configured
- Check network permissions and Firebase rules
- Verify Firebase configuration files are correctly installed
- Use Flutter DevTools and Firebase Console for debugging

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
MIT License - See LICENSE file for details.

---

This project demonstrates the integration of Firebase services with Flutter applications, utilizing the BLoC pattern for state management.