import 'api_base_class.dart';

class LoginResponse extends ApiResponseBase {
  final int? userId;
  final String? userEmail;
  final String? jwtToken;
  final String? refreshToken;

  LoginResponse({
    required bool success,
    String? message,
    this.userId,
    this.userEmail,
    this.jwtToken,
    this.refreshToken,
  }) : super(success: success, message: message);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      userId: json['user_id'],
      userEmail: json['user_email'],
      jwtToken: json['jwt_token'],
      refreshToken: json['refresh_token'],
    );
  }
}
