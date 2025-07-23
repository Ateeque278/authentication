import 'api_base_class.dart';

class LoginResponse extends ApiResponseBase {
  final String? accessToken;
  final bool? isVerified;
  final User? user;

  LoginResponse({
    required bool success,
    String? message,
    this.accessToken,
    this.isVerified,
    this.user,
  }) : super(success: success, message: message);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['is_success'] ?? false,
      message: json['message'],
      accessToken: json['access_token'],
      isVerified: json['is_verified'],
      user: json['data']?['user'] != null ? User.fromJson(json['data']['user']) : null,
    );
  }
}

class User {
  final int? id;
  final String? msisdn;
  final int? status;
  final String? lastActivityAt;
  final String? createdAt;
  final String? updatedAt;

  final Profile? userProfile;
  final Profile? profile;
  final MerchantProfile? merchantProfile;

  User({
    this.id,
    this.msisdn,
    this.status,
    this.lastActivityAt,
    this.createdAt,
    this.updatedAt,
    this.userProfile,
    this.profile,
    this.merchantProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      msisdn: json['msisdn'],
      status: json['status'],
      lastActivityAt: json['last_activity_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userProfile: json['user_profile'] != null ? Profile.fromJson(json['user_profile']) : null,
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
      merchantProfile: json['merchant_profile'] != null ? MerchantProfile.fromJson(json['merchant_profile']) : null,
    );
  }
}

class Profile {
  final int? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? profileImg;

  Profile({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.profileImg,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      profileImg: json['profile_img'],
    );
  }
}

class MerchantProfile {
  final int? id;
  final String? businessName;
  final String? businessAddress;

  MerchantProfile({
    this.id,
    this.businessName,
    this.businessAddress,
  });

  factory MerchantProfile.fromJson(Map<String, dynamic> json) {
    return MerchantProfile(
      id: json['id'],
      businessName: json['business_name'],
      businessAddress: json['business_address'],
    );
  }
}
