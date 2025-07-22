import 'dart:convert';

import 'package:authentication/api_base_class.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  
  RxBool isLoading = false.obs;
  
  Future<void> registerUser(String email, String password,context) async {
    
    isLoading.value = true;

    final url = Uri.parse('https://woo-dev-1.6hexa.com/wp-json/wcoauth/v1/register');

    var body = {'email': email, 'password': password};

    try {
      final response = await ApiProvider().post(url, body, false, Get.context);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {

        print("message ${data['message']}");

      } else {
        final message = data['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print("message ${message}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      isLoading.value = false;
    }
  }


}