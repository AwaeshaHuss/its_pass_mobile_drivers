import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/driver_entity.dart';

part 'driver_model.freezed.dart';
part 'driver_model.g.dart';

@freezed
class DriverModel with _$DriverModel {
  const factory DriverModel({
    required String id,
    required String name,
    required String email,
    required String phone,
    String? profileImageUrl,
    VehicleModel? vehicle,
    @Default(false) bool isBlocked,
    @Default(false) bool isApproved,
    @Default(0.0) double rating,
    @Default(0) int totalTrips,
    @Default(0.0) double totalEarnings,
    @Default('offline') String status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}

@freezed
class VehicleModel with _$VehicleModel {
  const factory VehicleModel({
    required String type,
    required String brand,
    required String model,
    required String color,
    required String plateNumber,
    String? imageUrl,
  }) = _VehicleModel;

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);
}

extension DriverModelX on DriverModel {
  DriverEntity toEntity() {
    return DriverEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      vehicle: vehicle?.toEntity(),
      isBlocked: isBlocked,
      isApproved: isApproved,
      rating: rating,
      totalTrips: totalTrips,
      totalEarnings: totalEarnings,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension VehicleModelX on VehicleModel {
  VehicleEntity toEntity() {
    return VehicleEntity(
      type: type,
      brand: brand,
      model: model,
      color: color,
      plateNumber: plateNumber,
      imageUrl: imageUrl,
    );
  }
}

extension DriverEntityX on DriverEntity {
  DriverModel toModel() {
    return DriverModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      vehicle: vehicle?.toModel(),
      isBlocked: isBlocked,
      isApproved: isApproved,
      rating: rating,
      totalTrips: totalTrips,
      totalEarnings: totalEarnings,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension VehicleEntityX on VehicleEntity {
  VehicleModel toModel() {
    return VehicleModel(
      type: type,
      brand: brand,
      model: model,
      color: color,
      plateNumber: plateNumber,
      imageUrl: imageUrl,
    );
  }
}
