class AuthResponse {
  final String token;
  final String tokenType;
  final int expiresIn;
  final DriverProfile? driver;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    this.driver,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['access_token'] ?? json['token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
      driver: json['driver'] != null 
          ? DriverProfile.fromJson(json['driver']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': token,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'driver': driver?.toJson(),
    };
  }
}

class DriverProfile {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePhoto;
  final String status;
  final String? vehicleType;
  final String? carName;
  final String? carModel;
  final String? carNumber;
  final String? carColor;
  final double? rating;
  final int? totalTrips;
  final double? totalEarnings;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DriverProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePhoto,
    required this.status,
    this.vehicleType,
    this.carName,
    this.carModel,
    this.carNumber,
    this.carColor,
    this.rating,
    this.totalTrips,
    this.totalEarnings,
    this.createdAt,
    this.updatedAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePhoto: json['profile_photo'],
      status: json['status'] ?? 'offline',
      vehicleType: json['vehicle_type'],
      carName: json['car_name'],
      carModel: json['car_model'],
      carNumber: json['car_number'],
      carColor: json['car_color'],
      rating: json['rating']?.toDouble(),
      totalTrips: json['total_trips'],
      totalEarnings: json['total_earnings']?.toDouble(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_photo': profilePhoto,
      'status': status,
      'vehicle_type': vehicleType,
      'car_name': carName,
      'car_model': carModel,
      'car_number': carNumber,
      'car_color': carColor,
      'rating': rating,
      'total_trips': totalTrips,
      'total_earnings': totalEarnings,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DriverProfileUpdate {
  final String? name;
  final String? email;
  final String? carName;
  final String? carModel;
  final String? carColor;

  DriverProfileUpdate({
    this.name,
    this.email,
    this.carName,
    this.carModel,
    this.carColor,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (carName != null) data['car_name'] = carName;
    if (carModel != null) data['car_model'] = carModel;
    if (carColor != null) data['car_color'] = carColor;
    return data;
  }
}
