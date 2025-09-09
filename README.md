# ItsPass Drivers App

A Flutter-based taxi/ride-sharing driver application with Clean Architecture and BLoC state management.

## Project Status

✅ **Modern Architecture Implementation**
- Migrated to Clean Architecture with BLoC pattern
- Updated to Gradle 8.4 for Java 21 compatibility
- Upgraded to Android Gradle Plugin 8.1.0
- Resolved dependency compatibility issues

## Architecture Migration (2025-01-09)

### Clean Architecture Implementation
- **Presentation Layer**: BLoC pattern for state management
- **Domain Layer**: Entities, Use Cases, Repository interfaces
- **Data Layer**: Repository implementations, Data sources (Remote/Local)
- **Dependency Injection**: GetIt for service locator pattern

### State Management Migration
- **From**: Provider pattern
- **To**: BLoC (Business Logic Component) pattern
- **Benefits**: Better separation of concerns, improved testability, reactive programming

### Updated Build Configuration
- **Gradle Wrapper**: Updated to 8.4 (`android/gradle/wrapper/gradle-wrapper.properties`)
- **Android Gradle Plugin**: Upgraded to 8.1.0 (`android/settings.gradle`)

### New Dependencies Added
- `flutter_bloc: ^8.1.3` - BLoC state management
- `bloc: ^8.1.2` - Core BLoC library
- `equatable: ^2.0.5` - Value equality
- `get_it: ^7.6.4` - Dependency injection
- `freezed_annotation: ^2.4.1` - Immutable data classes
- `json_annotation: ^4.8.1` - JSON serialization
- `dio: ^5.3.2` - HTTP client
- `bloc_test: ^9.1.5` - BLoC testing utilities
- `mocktail: ^1.0.1` - Mocking for tests

### Dependency Management
- **Removed incompatible dependencies**:
  - `flutter_geofire` - Namespace compatibility issues with AGP 8.1.0+
  - `restart_app` - Compatibility issues with modern Flutter
  - `rounded_loading_button` - Compatibility issues with modern Flutter

### Code Changes
- **Authentication Feature**: Fully migrated to Clean Architecture with BLoC
- **Geofire Functionality**: Temporarily disabled due to compatibility issues
- **Dependency Injection**: Implemented with GetIt service locator
- **Unit Tests**: Added comprehensive tests for auth feature

### Temporarily Disabled Features
⚠️ **Note**: The following features are temporarily disabled due to compatibility issues:
- Real-time driver location sharing via Geofire
- Driver online/offline status updates via Geofire
- Location-based driver matching

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio with Java 21
- Firebase project setup

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (ensure `google-services.json` is in `android/app/`)
4. Run `flutter run` to start the app

### Build Requirements
- **Minimum Android SDK**: 21
- **Target Android SDK**: 34
- **Gradle**: 8.4
- **Android Gradle Plugin**: 8.1.0
- **Java**: 21

## Architecture

### Current Implementation
- **State Management**: BLoC pattern (migrated from Provider)
- **Architecture**: Clean Architecture (3-layer approach)
- **Database**: Firebase Realtime Database & Firestore
- **Authentication**: Firebase Auth with custom BLoC
- **Maps**: Google Maps Flutter
- **Location Services**: Geolocator
- **Dependency Injection**: GetIt service locator
- **Testing**: Unit tests with BLoC test and Mocktail

### Project Structure
```
lib/
├── core/                     # Core utilities and constants
│   ├── constants/           # App constants
│   ├── errors/             # Error handling (failures, exceptions)
│   ├── network/            # Network utilities
│   └── utils/              # Common utilities (Either, UseCase)
├── features/               # Feature-based modules
│   └── auth/              # Authentication feature
│       ├── data/          # Data layer
│       │   ├── datasources/   # Remote & Local data sources
│       │   ├── models/        # Data models with JSON serialization
│       │   └── repositories/  # Repository implementations
│       ├── domain/        # Domain layer
│       │   ├── entities/      # Business entities
│       │   ├── repositories/  # Repository interfaces
│       │   └── usecases/      # Business use cases
│       └── presentation/  # Presentation layer
│           ├── bloc/          # BLoC state management
│           ├── pages/         # UI pages
│           └── widgets/       # UI widgets
├── injection/             # Dependency injection setup
└── main.dart             # App entry point
```

## Migration Status

### ✅ Completed Features
- **Authentication Module**: Fully migrated to Clean Architecture + BLoC
  - Phone authentication with OTP
  - Google Sign-In
  - Driver profile management
  - Authentication state management
  - Comprehensive unit tests

### 🔄 In Progress
- Dashboard feature migration to BLoC
- Trips feature migration to BLoC

### ⏳ Pending
- Remove legacy Provider code
- Complete migration of remaining features
- Integration tests
- Performance optimization

## Known Issues
- Geofire functionality temporarily disabled (compatibility with AGP 8.1.0+)
- Some legacy Provider code still exists during gradual migration
- Minor lint warnings in legacy code

## Future Improvements
- Complete Clean Architecture migration for all features
- Restore Geofire functionality with compatible alternative
- Implement custom location sharing solution
- Add integration and widget tests
- Performance monitoring and optimization
- Code generation optimization with build_runner

## Development Notes
This app is part of a taxi/ride-sharing system and works in conjunction with the user app. The architecture has been modernized with Clean Architecture and BLoC pattern for better maintainability, testability, and scalability.
