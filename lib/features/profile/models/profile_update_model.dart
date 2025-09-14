class ProfileUpdateRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  ProfileUpdateRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
    };
  }

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateRequest(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}

class ProfileUpdateResponse {
  final String code;
  final String message;
  final String requestId;
  final ProfileUpdateData data;

  ProfileUpdateResponse({
    required this.code,
    required this.message,
    required this.requestId,
    required this.data,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      code: json['code']?.toString() ?? '0',
      message: json['message']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      data: ProfileUpdateData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}

class ProfileUpdateData {
  final UserProfile user;

  ProfileUpdateData({required this.user});

  factory ProfileUpdateData.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateData(
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String type;
  final bool emailVerified;
  final bool phoneVerified;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.type,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      type: json['type']?.toString() ?? 'buyer',
      emailVerified:
          json['emailVerified'] == true || json['emailVerified'] == 1,
      phoneVerified:
          json['phoneVerified'] == true || json['phoneVerified'] == 1,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'type': type,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
