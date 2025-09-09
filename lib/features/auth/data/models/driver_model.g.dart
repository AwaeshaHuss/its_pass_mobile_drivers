// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DriverModelImpl _$$DriverModelImplFromJson(Map<String, dynamic> json) =>
    _$DriverModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      vehicle: json['vehicle'] == null
          ? null
          : VehicleModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      isBlocked: json['isBlocked'] as bool? ?? false,
      isApproved: json['isApproved'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTrips: (json['totalTrips'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'offline',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DriverModelImplToJson(_$DriverModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'profileImageUrl': instance.profileImageUrl,
      'vehicle': instance.vehicle,
      'isBlocked': instance.isBlocked,
      'isApproved': instance.isApproved,
      'rating': instance.rating,
      'totalTrips': instance.totalTrips,
      'totalEarnings': instance.totalEarnings,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$VehicleModelImpl _$$VehicleModelImplFromJson(Map<String, dynamic> json) =>
    _$VehicleModelImpl(
      type: json['type'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      color: json['color'] as String,
      plateNumber: json['plateNumber'] as String,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$$VehicleModelImplToJson(_$VehicleModelImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'brand': instance.brand,
      'model': instance.model,
      'color': instance.color,
      'plateNumber': instance.plateNumber,
      'imageUrl': instance.imageUrl,
    };
