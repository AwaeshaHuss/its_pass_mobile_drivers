# Uber Drivers App

A Flutter-based taxi/ride-sharing driver application with modern Android/Flutter compatibility.

## Project Status

✅ **Compatible with Modern Android/Flutter Tooling**
- Updated to Gradle 8.4 for Java 21 compatibility
- Upgraded to Android Gradle Plugin 8.1.0
- Resolved dependency compatibility issues

## Recent Compatibility Fixes (2025-01-09)

### Updated Build Configuration
- **Gradle Wrapper**: Updated to 8.4 (`android/gradle/wrapper/gradle-wrapper.properties`)
- **Android Gradle Plugin**: Upgraded to 8.1.0 (`android/settings.gradle`)

### Dependency Management
- **Removed incompatible dependencies**:
  - `flutter_geofire` - Namespace compatibility issues with AGP 8.1.0+
  - `restart_app` - Compatibility issues with modern Flutter
  - `rounded_loading_button` - Compatibility issues with modern Flutter

### Code Changes
- **Geofire Functionality**: Temporarily disabled due to compatibility issues
  - Commented out Geofire imports and usage in:
    - `lib/methods/common_method.dart`
    - `lib/pages/home/home_page.dart`
  - Added informative print statements for debugging

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
- **State Management**: Provider pattern
- **Database**: Firebase Realtime Database
- **Authentication**: Firebase Auth
- **Maps**: Google Maps Flutter
- **Location Services**: Geolocator

## Known Issues
- Geofire functionality temporarily disabled (compatibility with AGP 8.1.0+)
- Some unused imports cleaned up during compatibility fixes

## Future Improvements
- Restore Geofire functionality with compatible alternative
- Implement custom location sharing solution
- Add comprehensive unit tests
- Update to latest Flutter/Firebase versions

## Development Notes
This app is part of a taxi/ride-sharing system and works in conjunction with the user app. Both apps have been updated with the same compatibility fixes for modern Android development.
# its_pass_mobile_drivers
# its_pass_mobile_drivers
