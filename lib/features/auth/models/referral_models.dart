class ReferralCode {
  final String id;
  final String userId;
  final String code;
  final String type;
  final double commissionRate;
  final bool isActive;
  final int usageCount;
  final int maxUsage;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReferralCode({
    required this.id,
    required this.userId,
    required this.code,
    required this.type,
    required this.commissionRate,
    required this.isActive,
    required this.usageCount,
    required this.maxUsage,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      id: json['id'] as String,
      userId: json['userId'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      commissionRate: json['commissionRate'] == null
          ? 0.0
          : (json['commissionRate'] is num)
          ? (json['commissionRate'] as num).toDouble()
          : double.tryParse(json['commissionRate'].toString()) ?? 0.0,

      isActive: json['isActive'] as bool,
      usageCount: json['usageCount'] as int,
      maxUsage: json['maxUsage'] as int,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'code': code,
      'type': type,
      'commissionRate': commissionRate,
      'isActive': isActive,
      'usageCount': usageCount,
      'maxUsage': maxUsage,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class CreateReferralCodeRequest {
  final String type;
  final double commissionRate;
  final int maxUsage;
  final String expiresAt;

  CreateReferralCodeRequest({
    required this.type,
    required this.commissionRate,
    required this.maxUsage,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'commissionRate': commissionRate,
      'maxUsage': maxUsage,
      'expiresAt': expiresAt,
    };
  }
}

class CreateReferralCodeResponse {
  final bool success;
  final String message;
  final ReferralCode data;

  CreateReferralCodeResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateReferralCodeResponse.fromJson(Map<String, dynamic> json) {
    return CreateReferralCodeResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: ReferralCode.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class GetReferralCodesResponse {
  final bool success;
  final List<ReferralCode> data;

  GetReferralCodesResponse({required this.success, required this.data});

  factory GetReferralCodesResponse.fromJson(Map<String, dynamic> json) {
    return GetReferralCodesResponse(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((item) => ReferralCode.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
