import 'package:equatable/equatable.dart';

class Seller extends Equatable {
  final String id;
  final String? businessName;
  // final String? businessDescription;
  // final String? businessEmail;
  // final String? businessPhone;
  // final String? businessWebsite;
  // final String? status;
  final String? verificationStatus;
  // final double? rating;
  // final int? reviewCount;

  const Seller({
    required this.id,
    this.businessName,
    // this.businessDescription,
    // this.businessEmail,
    // this.businessPhone,
    // this.businessWebsite,
    // this.status,
    this.verificationStatus,
    // this.rating,
    // this.reviewCount,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    final seller = Seller(
      id: json['id'] ?? '',
      businessName: json['businessName'] ?? '',
      // businessDescription: json['businessDescription'] ?? '',
      // businessEmail: json['businessEmail'] ?? '',
      // businessPhone: json['businessPhone'] ?? '',
      // businessWebsite: json['businessWebsite'] ?? '',
      // status: json['status'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
      // rating: (json['rating'] ?? 0.0).toDouble(),
      // reviewCount: json['reviewCount'] ?? 0,
    );
    return seller;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      // 'businessDescription': businessDescription,
      // 'businessEmail': businessEmail,
      // 'businessPhone': businessPhone,
      // 'businessWebsite': businessWebsite,
      // 'status': status,
      'verificationStatus': verificationStatus,
      // 'rating': rating,
      // 'reviewCount': reviewCount,
    };
  }

  // Check if seller is verified
  bool get isVerified => verificationStatus?.toLowerCase() == 'verified';

  // Check if seller is active
  // bool get isActive => status?.toLowerCase() == 'active';

  // Get formatted rating
  // String get formattedRating => rating?.toStringAsFixed(1) ?? '';

  // Get formatted review count
  // String get formattedReviewCount {
  //   final count = reviewCount; // promote into local variable
  //   if (count != null && count >= 1000) {
  //     return '${(count / 1000).toStringAsFixed(1)}k+';
  //   }
  //   return count?.toString() ?? '0'; // handle null properly
  // }

  @override
  List<Object?> get props => [
    id,
    businessName,
    // businessDescription,
    // businessEmail,
    // businessPhone,
    // businessWebsite,
    // status,
    verificationStatus,
    // rating,
    // reviewCount,
  ];
}
