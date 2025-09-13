import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../utils/app_logger.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/api_response.dart';
import 'driver_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final DriverService _driverService = DriverService();
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _locationUpdateTimer;
  Position? _lastKnownPosition;
  bool _isTracking = false;
  
  // Location update callbacks
  final List<Function(Position)> _locationCallbacks = [];
  
  // Location settings
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update every 10 meters
  );

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      AppLogger.info('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _lastKnownPosition = position;
      return position;
    } catch (e) {
      AppLogger.info('Error getting current position: $e');
      return _lastKnownPosition;
    }
  }

  /// Start real-time location tracking
  Future<bool> startTracking() async {
    if (_isTracking) return true;

    final initialized = await initialize();
    if (!initialized) return false;

    try {
      // Start position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(
        (Position position) {
          _lastKnownPosition = position;
          _notifyLocationCallbacks(position);
        },
        onError: (error) {
          AppLogger.info('Location stream error: $error');
        },
      );

      // Start periodic API updates (every 30 seconds)
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) => _updateLocationToServer(),
      );

      _isTracking = true;
      return true;
    } catch (e) {
      AppLogger.info('Error starting location tracking: $e');
      return false;
    }
  }

  /// Stop location tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
    
    _isTracking = false;
  }

  /// Add location update callback
  void addLocationCallback(Function(Position) callback) {
    _locationCallbacks.add(callback);
  }

  /// Remove location update callback
  void removeLocationCallback(Function(Position) callback) {
    _locationCallbacks.remove(callback);
  }

  /// Notify all location callbacks
  void _notifyLocationCallbacks(Position position) {
    for (final callback in _locationCallbacks) {
      try {
        callback(position);
      } catch (e) {
        AppLogger.info('Error in location callback: $e');
      }
    }
  }

  /// Update location to server
  Future<void> _updateLocationToServer() async {
    if (_lastKnownPosition == null) return;

    try {
      await _driverService.updateLocation(
        latitude: _lastKnownPosition!.latitude,
        longitude: _lastKnownPosition!.longitude,
      );
    } catch (e) {
      AppLogger.info('Error updating location to server: $e');
    }
  }

  /// Force update location to server immediately
  Future<ApiResponse<void>> updateLocationNow() async {
    final position = await getCurrentPosition();
    if (position == null) {
      return ApiResponse.error('Unable to get current location');
    }

    return await _driverService.updateLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  /// Calculate distance between two points in meters
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get LatLng from Position
  LatLng positionToLatLng(Position position) {
    return LatLng(position.latitude, position.longitude);
  }

  /// Get last known position
  Position? get lastKnownPosition => _lastKnownPosition;

  /// Check if tracking is active
  bool get isTracking => _isTracking;

  /// Dispose resources
  void dispose() {
    stopTracking();
    _locationCallbacks.clear();
  }
}
