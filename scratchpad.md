# Uber Drivers App - Clean Architecture & BLoC Migration

## Task: Restructure to Clean Architecture with BLoC State Management

Migrating from Provider-based state management to Clean Architecture with BLoC pattern for better separation of concerns, testability, and maintainability.

## Migration Strategy: Gradual Approach
- **Phase 1**: Setup BLoC infrastructure alongside existing Provider
- **Phase 2**: Migrate features one by one (Auth → Dashboard → Trips)
- **Phase 3**: Clean up old Provider code
- **Phase 4**: Comprehensive testing and documentation

## Clean Architecture Layers:
1. **Presentation Layer**: BLoC, UI Widgets, Pages
2. **Domain Layer**: Entities, Use Cases, Repository Interfaces
3. **Data Layer**: Repository Implementations, Data Sources (Remote/Local)

## Current Progress:
- [x] Create new branch for clean architecture migration
- [x] Add BLoC dependencies to pubspec.yaml
- [x] Create clean architecture folder structure
- [x] Implement data layer (repositories, data sources)
- [x] Implement domain layer (entities, use cases)
- [x] Migrate authentication feature to BLoC
- [x] Create new AuthCheck widget with BLoC
- [x] Setup dependency injection container
- [x] Create basic unit tests for auth feature
- [ ] Migrate dashboard feature to BLoC
- [ ] Migrate trips feature to BLoC
- [ ] Remove old Provider code and cleanup
- [ ] Update documentation and commit changes

## Previous Compatibility Fixes (Completed):
- [x] Update Gradle wrapper to 8.4 for Java 21 compatibility
- [x] Upgrade Android Gradle Plugin to 8.1.0
- [x] Remove incompatible plugins: flutter_geofire, restart_app, rounded_loading_button
- [x] Comment out Geofire functionality due to namespace compatibility issues
- [x] Remove unused imports and clean up code
- [x] Update README.md with project status

## Lessons Learned

### Clean Architecture Migration
- BLoC pattern provides better separation of concerns than Provider pattern
- Dependency injection with GetIt makes testing much easier
- Either pattern for error handling is more robust than try-catch
- Freezed for immutable data models reduces boilerplate significantly
- Clean Architecture layers (Data/Domain/Presentation) improve maintainability

### Build Configuration
- AGP 8.3.0 requires Java 1.8 compatibility for all modules
- NDK version must be consistent across all plugins (use 27.0.12077973)
- kotlinOptions can cause build failures with some plugins - avoid global enforcement
- minSdkVersion 23 required for Firebase Auth library compatibility

### Plugin Compatibility Issues (Flutter 3.4.4 + AGP 8.3.0)
- assets_audio_player: Compilation errors with Registrar class - removed
- flutter_notification_channel: Compilation errors with Registrar class - removed
- geolocator: Updated from ^12.0.0 to ^14.0.2 to fix Registrar compatibility
- Many plugins have outdated AndroidManifest.xml package attributes (warnings only)
- Always test Android build after dependency changes

## Build Configuration Lessons:
- AGP 8.1.0 causes JVM target compatibility issues with newer Kotlin versions
- Upgrading to AGP 8.3.0+ resolves Flutter compatibility warnings
- Java and Kotlin JVM targets must match (both Java 21 and Kotlin JVM target 21)
- Always run flutter clean after major build configuration changes
- assets_audio_player_web plugin requires consistent JVM targets across all modules
- kotlinOptions() method not available on all Android plugin types (LibraryExtension)
- Global JVM target enforcement can break Firebase and other plugins
- Safer to keep Java 1.8 compatibility for plugin ecosystem stability

## Project Structure Cleanup Task:
- Keep essential files: lib/, assets/, pubspec.yaml, pubspec.lock
- Keep configuration files: .gitignore, README.md, analysis_options.yaml, firebase.json
- Keep custom files: scratchpad.md, themes/
- Remove platform folders: android/, ios/, web/, windows/, linux/, macos/
- Remove generated folders: .dart_tool/, test/
- Remove metadata: .metadata, .flutter-plugins-dependencies
- Recreate minimal Flutter project structure with flutter create
