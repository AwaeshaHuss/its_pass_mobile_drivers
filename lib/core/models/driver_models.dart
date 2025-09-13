class DriverRegistrationData {
  final String name;
  final String email;
  final String phoneNumber;
  final String password;
  final String passwordConfirmation;
  final String vehicleType;
  final String carName;
  final String carModel;
  final String carNumber;
  final String carColor;
  final String deviceToken;

  DriverRegistrationData({
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.passwordConfirmation,
    required this.vehicleType,
    required this.carName,
    required this.carModel,
    required this.carNumber,
    required this.carColor,
    required this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'vehicle_type': vehicleType,
      'car_name': carName,
      'car_model': carModel,
      'car_number': carNumber,
      'car_color': carColor,
      'device_token': deviceToken,
    };
  }
}

class RegistrationStatus {
  final String status;
  final String message;
  final bool isApproved;
  final bool isPending;
  final bool isRejected;
  final List<String>? missingDocuments;
  final String? rejectionReason;

  RegistrationStatus({
    required this.status,
    required this.message,
    required this.isApproved,
    required this.isPending,
    required this.isRejected,
    this.missingDocuments,
    this.rejectionReason,
  });

  factory RegistrationStatus.fromJson(Map<String, dynamic> json) {
    return RegistrationStatus(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      isApproved: json['is_approved'] ?? false,
      isPending: json['is_pending'] ?? false,
      isRejected: json['is_rejected'] ?? false,
      missingDocuments: json['missing_documents'] != null
          ? List<String>.from(json['missing_documents'])
          : null,
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'is_approved': isApproved,
      'is_pending': isPending,
      'is_rejected': isRejected,
      'missing_documents': missingDocuments,
      'rejection_reason': rejectionReason,
    };
  }
}

class WalletInfo {
  final double balance;
  final double totalEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final int totalTrips;
  final String currency;

  WalletInfo({
    required this.balance,
    required this.totalEarnings,
    required this.weeklyEarnings,
    required this.monthlyEarnings,
    required this.totalTrips,
    required this.currency,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      balance: json['balance']?.toDouble() ?? 0.0,
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      weeklyEarnings: json['weekly_earnings']?.toDouble() ?? 0.0,
      monthlyEarnings: json['monthly_earnings']?.toDouble() ?? 0.0,
      totalTrips: json['total_trips'] ?? 0,
      currency: json['currency'] ?? 'JOD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'total_earnings': totalEarnings,
      'weekly_earnings': weeklyEarnings,
      'monthly_earnings': monthlyEarnings,
      'total_trips': totalTrips,
      'currency': currency,
    };
  }
}

class EarningsInfo {
  final double totalEarnings;
  final double periodEarnings;
  final String period;
  final int tripsCount;
  final double averageEarningsPerTrip;
  final List<DailyEarning> dailyBreakdown;

  EarningsInfo({
    required this.totalEarnings,
    required this.periodEarnings,
    required this.period,
    required this.tripsCount,
    required this.averageEarningsPerTrip,
    required this.dailyBreakdown,
  });

  factory EarningsInfo.fromJson(Map<String, dynamic> json) {
    return EarningsInfo(
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      periodEarnings: json['period_earnings']?.toDouble() ?? 0.0,
      period: json['period'] ?? '',
      tripsCount: json['trips_count'] ?? 0,
      averageEarningsPerTrip: json['average_earnings_per_trip']?.toDouble() ?? 0.0,
      dailyBreakdown: json['daily_breakdown'] != null
          ? (json['daily_breakdown'] as List)
              .map((e) => DailyEarning.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings': totalEarnings,
      'period_earnings': periodEarnings,
      'period': period,
      'trips_count': tripsCount,
      'average_earnings_per_trip': averageEarningsPerTrip,
      'daily_breakdown': dailyBreakdown.map((e) => e.toJson()).toList(),
    };
  }
}

class DailyEarning {
  final String date;
  final double earnings;
  final int trips;

  DailyEarning({
    required this.date,
    required this.earnings,
    required this.trips,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: json['date'] ?? '',
      earnings: json['earnings']?.toDouble() ?? 0.0,
      trips: json['trips'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'earnings': earnings,
      'trips': trips,
    };
  }
}
