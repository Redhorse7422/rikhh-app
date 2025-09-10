class PhoneVerificationRequest {
  final String phoneNumber;
  final String? deviceId;

  PhoneVerificationRequest({
    required this.phoneNumber,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }
}

class PhoneVerificationResponse {
  final String message;
  final PhoneVerificationData data;
  final int code;

  PhoneVerificationResponse({
    required this.message,
    required this.data,
    required this.code,
  });

  factory PhoneVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationResponse(
      message: json['message'] as String,
      data: PhoneVerificationData.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
    );
  }
}

class PhoneVerificationData {
  final String otpId;
  final String expiresAt;

  PhoneVerificationData({
    required this.otpId,
    required this.expiresAt,
  });

  factory PhoneVerificationData.fromJson(Map<String, dynamic> json) {
    return PhoneVerificationData(
      otpId: json['otpId'] as String,
      expiresAt: json['expiresAt'] as String,
    );
  }
}

class VerifyOtpRequest {
  final String phoneNumber;
  final String otpCode;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'otpCode': otpCode,
    };
  }
}

class VerifyOtpResponse {
  final String message;
  final VerifyOtpData data;
  final int code;

  VerifyOtpResponse({
    required this.message,
    required this.data,
    required this.code,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] as String,
      data: VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
    );
  }
}

class VerifyOtpData {
  final bool isValid;
  final bool phoneVerified;

  VerifyOtpData({
    required this.isValid,
    required this.phoneVerified,
  });

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      isValid: json['isValid'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
    );
  }
}

class ResendOtpRequest {
  final String phoneNumber;
  final String? deviceId;

  ResendOtpRequest({
    required this.phoneNumber,
    this.deviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      if (deviceId != null) 'deviceId': deviceId,
    };
  }
}

class ResendOtpResponse {
  final String message;
  final PhoneVerificationData data;
  final int code;

  ResendOtpResponse({
    required this.message,
    required this.data,
    required this.code,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      message: json['message'] as String,
      data: PhoneVerificationData.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int,
    );
  }
}
