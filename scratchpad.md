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

## Lessons:
- Modern Android tooling requires Gradle 8.4+ and AGP 8.1.0+
- Some Flutter plugins are incompatible with newer AGP versions
- Geofire has namespace compatibility issues with AGP 8.1.0+
- flutter_geofire, restart_app, and rounded_loading_button are incompatible with AGP 8.1.0+
- Always comment out functionality rather than removing it completely for easier restoration
- Update README.md to document compatibility changes and temporarily disabled features

## Clean Architecture Migration Lessons:
- BLoC pattern provides better separation of concerns than Provider
- Dependency injection with GetIt simplifies testing and maintainability
- Clean architecture layers (data, domain, presentation) improve code organization
- Either type for error handling provides better type safety than exceptions
- Use cases encapsulate business logic and make it testable
- Gradual migration approach reduces risk and allows for incremental testing
- Freezed and json_annotation help with immutable data models
- Register fallback values in mocktail tests to avoid NoParams issues

## Build Configuration Lessons:
- AGP 8.1.0 causes JVM target compatibility issues with newer Kotlin versions
- Upgrading to AGP 8.3.0+ resolves Flutter compatibility warnings
- Java and Kotlin JVM targets must match (both Java 21 and Kotlin JVM target 21)
- Always run flutter clean after major build configuration changes
- assets_audio_player_web plugin requires consistent JVM targets across all modules
- kotlinOptions() method not available on all Android plugin types (LibraryExtension)
- Global JVM target enforcement can break Firebase and other plugins
- Safer to keep Java 1.8 compatibility for plugin ecosystem stability
