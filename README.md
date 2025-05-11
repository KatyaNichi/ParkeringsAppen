# ParkeringsAppen (Flutter Client)

The Flutter client application for the Parkeringsapp system, now featuring enhanced state management with BLoC and improved architectural design.

## Project Overview

The ParkeringsAppen system consists of two repositories:

1. **[Server](https://github.com/KatyaNichi/Parkeringsapp)**: A RESTful API built with Dart and Shelf framework
2. **[Client](https://github.com/KatyaNichi/ParkeringsAppen)**: A Flutter application with advanced state management

## New Features and Improvements

- 🚀 State Management with BLoC
- 🔒 Enhanced Authentication Flow
- 💻 Cross-Platform Compatibility
- 🎨 Responsive UI Design
- 📱 Dynamic Base URL Configuration
- 🔍 Improved Error Handling

## Key Architectural Changes

### State Management
- Implemented BLoC (Business Logic Component) pattern
- Separate state management for:
  - Authentication
  - Vehicles
  - Parking Spaces
  - Parking Sessions

### Dynamic Configuration
- Platform-specific base URL configuration
- Supports Android, iOS, and web platforms
- Automatic network endpoint selection

### Authentication
- Improved login and signup processes
- User state management
- Secure user session handling

## Getting Started

### Prerequisites

- Dart SDK (3.0.0 or later)
- Flutter SDK (3.10.0 or later)
- Android/iOS development environment

### Setup and Installation

1. Clone the repository
   ```bash
   git clone https://github.com/KatyaNichi/ParkeringsAppen.git

Install dependencies
bashflutter pub get

Configure Base URL

Update base URL in lib/config/app_config.dart
Supports dynamic configuration for different platforms


Run the application
bashflutter run


Project Structure
lib/
├── blocs/                  # BLoC state management
│   ├── auth/
│   ├── vehicle/
│   ├── parking/
│   └── parking_space/
├── config/                 # Configuration files
├── models/                 # Data models
├── repositories/           # Data access layer
├── screens/                # UI screens
├── services/               # Service classes
└── main.dart               # Application entry point
Platform Support

 Android
 iOS
 Web
 Desktop (Planned)

Technologies and Libraries

Flutter
BLoC for State Management
HTTP for API Communication
JSON Serialization
Platform-specific configurations

Configuration
Base URL Configuration
Modify getBaseUrl() in configuration files:
dartString getBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8080';
  } else if (Platform.isIOS) {
    return 'http://localhost:8080';
  } else {
    return 'http://YOUR_LOCAL_IP:8080';
  }
}
Upcoming Features

 Implement comprehensive unit and widget tests
 Add advanced caching mechanisms
 Enhance error handling
 Implement refresh tokens
 Add offline support

Troubleshooting

Ensure server is running on the correct port
Check network permissions
Verify base URL configuration
Use Flutter DevTools for debugging

Contributing

Fork the repository
Create your feature branch
Commit your changes
Push to the branch
Create a Pull Request

License
MIT License - See LICENSE file for details.