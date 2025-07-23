import 'api_base_class.dart';

class RegisterResponse extends ApiResponseBase {
  final String? userID;

  RegisterResponse({
    required bool success,
    String? message,
    this.userID,
  }) : super(success: success, message: message);

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'],
      userID: json['user_id']?.toString(),
    );
  }
}
