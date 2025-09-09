class AppConstants {
  // Firebase Collections
  static const String driversCollection = 'drivers';
  static const String tripsCollection = 'trips';
  static const String usersCollection = 'users';
  
  // Shared Preferences Keys
  static const String driverIdKey = 'driver_id';
  static const String driverTokenKey = 'driver_token';
  static const String isDriverLoggedInKey = 'is_driver_logged_in';
  
  // Map Constants
  static const double defaultZoom = 14.0;
  static const double defaultLatitude = 31.5204;
  static const double defaultLongitude = 74.3587;
  
  // Trip Status
  static const String tripStatusRequested = 'requested';
  static const String tripStatusAccepted = 'accepted';
  static const String tripStatusArrived = 'arrived';
  static const String tripStatusOnTrip = 'ontrip';
  static const String tripStatusCompleted = 'completed';
  static const String tripStatusCancelled = 'cancelled';
  
  // Driver Status
  static const String driverStatusOnline = 'online';
  static const String driverStatusOffline = 'offline';
  static const String driverStatusBusy = 'busy';
}
