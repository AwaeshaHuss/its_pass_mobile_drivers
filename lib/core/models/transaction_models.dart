class Transaction {
  final String id;
  final String type; // 'earning', 'withdrawal', 'bonus', 'refund'
  final double amount;
  final String description;
  final String status; // 'completed', 'pending', 'failed'
  final DateTime createdAt;
  final String? tripId;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.tripId,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'earning',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'completed',
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      tripId: json['trip_id']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'trip_id': tripId,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class WithdrawalRequest {
  final String id;
  final double amount;
  final String status; // 'pending', 'approved', 'rejected', 'completed'
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? bankAccount;
  final String? notes;

  WithdrawalRequest({
    required this.id,
    required this.amount,
    required this.status,
    required this.requestedAt,
    this.processedAt,
    this.bankAccount,
    this.notes,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      requestedAt: json['requested_at'] != null 
          ? DateTime.tryParse(json['requested_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      processedAt: json['processed_at'] != null 
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
      bankAccount: json['bank_account']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'status': status,
      'requested_at': requestedAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'bank_account': bankAccount,
      'notes': notes,
    };
  }
}

class WalletBalance {
  final double totalBalance;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double totalWithdrawals;
  final DateTime lastUpdated;

  WalletBalance({
    required this.totalBalance,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.lastUpdated,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      totalBalance: (json['total_balance'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pending_balance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawals: (json['total_withdrawals'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.tryParse(json['last_updated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'available_balance': availableBalance,
      'pending_balance': pendingBalance,
      'total_earnings': totalEarnings,
      'total_withdrawals': totalWithdrawals,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
