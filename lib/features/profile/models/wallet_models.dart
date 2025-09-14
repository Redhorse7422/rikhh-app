class WalletBalance {
  final double balance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final double availableBalance;

  // Helper function to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  WalletBalance({
    required this.balance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalWithdrawn,
    required this.availableBalance,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: _parseDouble(json['balance']),
      pendingBalance: _parseDouble(json['pendingBalance']),
      totalEarned: _parseDouble(json['totalEarned']),
      totalWithdrawn: _parseDouble(json['totalWithdrawn']),
      availableBalance: _parseDouble(json['availableBalance']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'pendingBalance': pendingBalance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'availableBalance': availableBalance,
    };
  }
}

class WalletBalanceResponse {
  final bool success;
  final WalletBalance data;

  WalletBalanceResponse({
    required this.success,
    required this.data,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      success: json['success'] as bool,
      data: WalletBalance.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class Transaction {
  final String id;
  final String type;
  final double amount;
  final double balance;
  final String description;
  final String status;
  final String? referenceId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Helper function to safely parse double values from JSON
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balance,
    required this.description,
    required this.status,
    this.referenceId,
    required this.metadata,
    required this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: _parseDouble(json['amount']),
      balance: _parseDouble(json['balance']),
      description: json['description'] as String,
      status: json['status'] as String,
      referenceId: json['referenceId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'balance': balance,
      'description': description,
      'status': status,
      if (referenceId != null) 'referenceId': referenceId,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  // Helper function to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: _parseInt(json['page']),
      limit: _parseInt(json['limit']),
      total: _parseInt(json['total']),
      totalPages: _parseInt(json['totalPages']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

class TransactionHistoryResponse {
  final bool success;
  final List<Transaction> transactions;
  final Pagination? pagination;

  // Helper function to safely parse int values from JSON
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  TransactionHistoryResponse({
    required this.success,
    required this.transactions,
    this.pagination,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    // Handle pagination data that might be directly in the data object
    Pagination? pagination;
    if (json['data'] != null && json['data']['pagination'] != null) {
      pagination = Pagination.fromJson(json['data']['pagination'] as Map<String, dynamic>);
    } else if (json['data'] != null && json['data']['total'] != null) {
      // Create pagination from direct fields in data object
      pagination = Pagination(
        page: _parseInt(json['data']['page']),
        limit: _parseInt(json['data']['limit']),
        total: _parseInt(json['data']['total']),
        totalPages: _parseInt(json['data']['totalPages']),
      );
    }

    return TransactionHistoryResponse(
      success: json['success'] as bool,
      transactions: (json['data']['transactions'] as List<dynamic>)
          .map((item) => Transaction.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }
}
