class PasswordResetRequest {
  final String phoneNumber;
  final String userType;
  final String? deviceId;

  PasswordResetRequest({
    required this.phoneNumber,
    required this.userType,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'userType': userType,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }
}

class PasswordResetResponse {
  final String message;
  final PasswordResetData data;
  final int code;

  PasswordResetResponse({
    required this.message,
    required this.data,
    required this.code,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'] as String,
      data: PasswordResetData.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
    );
  }
}

class PasswordResetData {
  final String otpId;
  final String expiresAt;

  PasswordResetData({
    required this.otpId,
    required this.expiresAt,
  });

  factory PasswordResetData.fromJson(Map<String, dynamic> json) {
    return PasswordResetData(
      otpId: json['otpId'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }
}

class PasswordResetConfirmRequest {
  final String phoneNumber;
  final String otpCode;
  final String newPassword;
  final String userType;

  PasswordResetConfirmRequest({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
    required this.userType,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
      'newPassword': newPassword,
      'userType': userType,
    };
  }
}

class PasswordResetConfirmResponse {
  final String message;
  final int code;

  PasswordResetConfirmResponse({
    required this.message,
    required this.code,
  });

  factory PasswordResetConfirmResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetConfirmResponse(
      message: json['message'] as String,
      code: json['code'] as int,
    );
  }
}
