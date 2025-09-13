class Trip {
  final int id;
  final String status;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final double estimatedFare;
  final double? finalFare;
  final double distance;
  final int estimatedDuration;
  final String paymentMethod;
  final Customer customer;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? rating;
  final String? comment;

  Trip({
    required this.id,
    required this.status,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.estimatedFare,
    this.finalFare,
    required this.distance,
    required this.estimatedDuration,
    required this.paymentMethod,
    required this.customer,
    required this.createdAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.rating,
    this.comment,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      pickupAddress: json['pickup_address'] ?? '',
      destinationAddress: json['destination_address'] ?? '',
      pickupLatitude: json['pickup_latitude']?.toDouble() ?? 0.0,
      pickupLongitude: json['pickup_longitude']?.toDouble() ?? 0.0,
      destinationLatitude: json['destination_latitude']?.toDouble() ?? 0.0,
      destinationLongitude: json['destination_longitude']?.toDouble() ?? 0.0,
      estimatedFare: json['estimated_fare']?.toDouble() ?? 0.0,
      finalFare: json['final_fare']?.toDouble(),
      distance: json['distance']?.toDouble() ?? 0.0,
      estimatedDuration: json['estimated_duration'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      customer: Customer.fromJson(json['customer'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      rating: json['rating'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'destination_latitude': destinationLatitude,
      'destination_longitude': destinationLongitude,
      'estimated_fare': estimatedFare,
      'final_fare': finalFare,
      'distance': distance,
      'estimated_duration': estimatedDuration,
      'payment_method': paymentMethod,
      'customer': customer.toJson(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'rating': rating,
      'comment': comment,
    };
  }
}

class Customer {
  final int id;
  final String name;
  final String phoneNumber;
  final double? rating;
  final String? profilePhoto;

  Customer({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.rating,
    this.profilePhoto,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      rating: json['rating']?.toDouble(),
      profilePhoto: json['profile_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'rating': rating,
      'profile_photo': profilePhoto,
    };
  }
}

enum TripStatus {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}

extension TripStatusExtension on TripStatus {
  String get value {
    switch (this) {
      case TripStatus.pending:
        return 'pending';
      case TripStatus.accepted:
        return 'accepted';
      case TripStatus.inProgress:
        return 'in_progress';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  static TripStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TripStatus.pending;
      case 'accepted':
        return TripStatus.accepted;
      case 'in_progress':
        return TripStatus.inProgress;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.pending;
    }
  }
}
