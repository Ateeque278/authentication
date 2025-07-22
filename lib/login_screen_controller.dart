import 'dart:convert';

import 'package:authentication/api_base_class.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreenController extends GetxController {
  
  RxBool isLoading = false.obs;

  Future<void> registerUser(String email, String password, BuildContext context) async {
    isLoading.value = true;

    final url = 'https://woo-dev-1.6hexa.com/wp-json/wcoauth/v1/register';
    final body = {'email': email, 'password': password};

    try {
      final response = await ApiProvider().post(url, body, false, context);

      // `response` is already a parsed Map or dynamic object
      if (response['success'] == true) {
        print("message: ${response['message']}");
      } else {
        final message = response['message'] ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
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