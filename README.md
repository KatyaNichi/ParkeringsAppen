# ParkeringsAppen (Flutter Client)

The Flutter client application for the Parkeringsapp system. This repository contains the mobile/web client that connects to the [Parkeringsapp server](https://github.com/KatyaNichi/Parkeringsapp).

## Project Overview

The ParkeringsAppen system consists of two repositories:

1. **[Server](https://github.com/KatyaNichi/Parkeringsapp)**: A RESTful API built with Dart and Shelf framework for handling data persistence and business logic
2. **[Client](https://github.com/KatyaNichi/ParkeringsAppen)**: This Flutter application that provides a user-friendly interface for interacting with the server

This repository contains the Flutter client application.

## Features

- User authentication and management
- Vehicle registration and management
- Parking space management
- Active parking session tracking
- Parking history with duration and cost calculation
- Responsive design for both mobile and desktop interfaces

## Getting Started

### Prerequisites

- Dart SDK (2.15.0 or later)
- Flutter SDK (2.10.0 or later)
- A code editor like VS Code or Android Studio

### Server Setup

The server component is in a separate repository. To set up the server:

1. Clone the server repository:
   ```
   git clone https://github.com/KatyaNichi/Parkeringsapp.git
   ```
2. Follow the setup instructions in the server repository's README

The server needs to be running on port 8080 before you can use this client application.

### Client Setup

1. Clone this repository:
   ```
   git clone https://github.com/KatyaNichi/ParkeringsAppen.git
   ```
2. Navigate to the project directory
3. Install dependencies:
   ```
   flutter pub get
   ```
3. **Important**: Update the API URL in the following files to match your server's address:
   - `lib/services/api_service.dart`
   - `lib/screens/login_screen.dart` 
   - `lib/screens/manage_parking_screen.dart`
   - `lib/screens/parking_spaces_screen.dart`
   - `lib/screens/parkings_screen.dart`
   - `lib/screens/vehicles_screen.dart`

   Replace `http://192.168.88.39:8080` with your server's IP address or hostname (e.g., `http://localhost:8080` for local development)

4. Run the Flutter application:
   ```
   flutter run
   ```

## Project Structure

### Server

The server code is located in the [Parkeringsapp repository](https://github.com/KatyaNichi/Parkeringsapp).

### Client

- `lib/main.dart`: Entry point for the Flutter application
- `lib/models/`: Data models
- `lib/screens/`: UI screens
- `lib/services/`: Service classes for API communication and state management

## API Endpoints

### Persons

- `GET /api/persons`: Get all persons
- `GET /api/persons/:id`: Get a specific person
- `POST /api/persons`: Create a new person
- `PUT /api/persons/:id`: Update a person
- `DELETE /api/persons/:id`: Delete a person

### Vehicles

- `GET /api/vehicles`: Get all vehicles
- `GET /api/vehicles/:id`: Get a specific vehicle
- `GET /api/vehicles/owner/:ownerId`: Get vehicles by owner
- `POST /api/vehicles`: Create a new vehicle
- `PUT /api/vehicles/:id`: Update a vehicle
- `DELETE /api/vehicles/:id`: Delete a vehicle

### Parking Spaces

- `GET /api/parkingSpaces`: Get all parking spaces
- `GET /api/parkingSpaces/:id`: Get a specific parking space
- `POST /api/parkingSpaces`: Create a new parking space
- `PUT /api/parkingSpaces/:id`: Update a parking space
- `DELETE /api/parkingSpaces/:id`: Delete a parking space

### Parkings

- `GET /api/parkings`: Get all parkings
- `GET /api/parkings/active`: Get active parkings
- `GET /api/parkings/vehicle/:fordon`: Get parkings by vehicle
- `GET /api/parkings/place/:parkingPlace`: Get parkings by parking place
- `GET /api/parkings/:id`: Get a specific parking
- `POST /api/parkings`: Create a new parking
- `PUT /api/parkings/:id`: Update a parking
- `PUT /api/parkings/:id/end`: End a parking session
- `DELETE /api/parkings/:id`: Delete a parking

## Known Issues and Future Improvements

- The current authentication is simplified without proper password hashing
- Tab controller initialization in the parkings screen may cause errors
- History view shows all parking sessions instead of filtering by user
- Add proper error handling for network connectivity issues
- Implement pagination for large datasets
- Add unit and integration tests

## License

This project is licensed under the MIT License - see the LICENSE file for details.

