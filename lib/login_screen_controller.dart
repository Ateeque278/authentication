import 'package:authentication/register_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api_base_class.dart';
import 'auth_api_provider.dart';
import 'login_model.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  final AuthApiProvider _authApi = AuthApiProvider();

  Future<void> registerUser(String email, String password, BuildContext context) async {
    isLoading.value = true;

    try {
      print("📲 [Controller] Register user called");

      RegisterResponse response = await _authApi.registerUser(email, password);

      print("reponsee in controller try $response");

      if (response.success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Registration successful')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Registration failed')),
        );
      }
    } on AppException catch (e) {
      print("reponsee in controller catch $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      print('Error Code: ${e.code}');
      print('Details: ${e.details}');

    } finally {
      isLoading.value = false;
    }
  }


  Future<void> loginUser(String email, String password, BuildContext context) async {
    isLoading.value = true;

    try {
      LoginResponse response = await _authApi.loginUser(email, password);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message ?? (response.success ? 'Login successful' : 'Login failed'))),
      );

      if (response.success && response.accessToken != null) {
        print("Token: ${response.accessToken}");
        print("User: ${response.user?.profile?.name}");
        // You could store token, user info etc. here
      }
    } on AppException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Error: $e")),
      );
      print('Error Code: ${e.code}');
      print('Details: ${e.details}');

    } finally {
      isLoading.value = false;
    }
  }

}
