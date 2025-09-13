class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Authentication Endpoints
  static const String login = '/mobile/driver/login';
  static const String forgotPassword = '/mobile/driver/forgot-password';
  static const String resetPassword = '/mobile/driver/reset-password';
  static const String logout = '/mobile/driver/logout';
  
  // Driver Registration Endpoints
  static const String registerDriver = '/mobile/driver/register';
  static const String checkStatus = '/mobile/driver/check-status';
  
  // File Upload Endpoints
  static const String uploadProfilePhoto = '/mobile/driver/upload-profile-photo';
  static const String uploadIdFront = '/mobile/driver/upload-id-front';
  static const String uploadIdBack = '/mobile/driver/upload-id-back';
  static const String uploadLicenseFront = '/mobile/driver/upload-license-front';
  static const String uploadLicenseBack = '/mobile/driver/upload-license-back';
  static const String uploadNoConvictionCertificate = '/mobile/driver/upload-no-conviction-certificate';
  static const String uploadSelfieWithId = '/mobile/driver/upload-selfie-with-id';
  static const String uploadCarImage = '/mobile/driver/upload-car-image';
  static const String uploadCarRegistrationFront = '/mobile/driver/upload-car-registration-front';
  static const String uploadCarRegistrationBack = '/mobile/driver/upload-car-registration-back';
  
  // Profile & Status Endpoints
  static const String profile = '/mobile/driver/profile';
  static const String updateStatus = '/mobile/driver/status';
  static const String updateLocation = '/mobile/driver/location';
  static const String changePassword = '/mobile/driver/change-password';
  
  // Trip Management Endpoints
  static const String availableTrips = '/mobile/driver/available-trips';
  static const String acceptTrip = '/mobile/driver/accept-trip';
  static const String completeTrip = '/mobile/driver/complete-trip';
  static const String updateTripStatus = '/mobile/driver/trip-status';
  static const String rateCustomer = '/mobile/driver/rate-customer';
  static const String tripHistory = '/mobile/driver/trip-history';
  
  // Wallet & Earnings Endpoints
  static const String wallet = '/mobile/driver/wallet';
  static const String earnings = '/mobile/driver/earnings';
  static const String balance = '/mobile/driver/balance';
  
  // Utility Endpoints
  static const String health = '/mobile/health';
  static const String config = '/mobile/config';
  static const String userInfo = '/mobile/user';
}
