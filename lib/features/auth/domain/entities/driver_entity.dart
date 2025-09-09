import 'package:equatable/equatable.dart';

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final VehicleEntity? vehicle;
  final bool isBlocked;
  final bool isApproved;
  final double rating;
  final int totalTrips;
  final double totalEarnings;
  final String status; // online, offline, busy
  final DateTime createdAt;
  final DateTime updatedAt;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.vehicle,
    required this.isBlocked,
    required this.isApproved,
    required this.rating,
    required this.totalTrips,
    required this.totalEarnings,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        profileImageUrl,
        vehicle,
        isBlocked,
        isApproved,
        rating,
        totalTrips,
        totalEarnings,
        status,
        createdAt,
        updatedAt,
      ];
}

class VehicleEntity extends Equatable {
  final String type;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final String? imageUrl;

  const VehicleEntity({
    required this.type,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [type, brand, model, color, plateNumber, imageUrl];
}
