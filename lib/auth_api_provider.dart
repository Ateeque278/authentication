import 'dart:convert';
import 'package:authentication/register_model.dart';
import 'package:flutter/foundation.dart';
import 'api_base_class.dart';
import 'login_model.dart';

class AuthApiProvider extends ApiBaseClass {
  final String _baseUrl = 'https://woo-dev-1.6hexa.com/wp-json/wcoauth/v1';
  final _api = ApiBaseClass();

  Future<RegisterResponse> registerUser(String email, String password) async {
    try {
      print("📲 [Provider] Register user called");

      final response = await _api.post(
        '${_baseUrl}/register',
         {
          'email': email,
          'password': password,
        },
        false

      );
      print("reponsee in provider try $response");


      return RegisterResponse.fromJson(response.data);
    } catch (e) {
      print("reponsee in provider catch $e");
      // Optional: map DioError to a custom error or rethrow
      rethrow;
    }
  }


  Future<LoginResponse> loginUser(String email, String password) async {
    try {
      final response = await _api.post(
        '$_baseUrl/login',
        {
          'email': email,
          'password': password,
        },
        false,
      );

      return LoginResponse.fromJson(response);
    }catch(e){
      rethrow ;
    }
  }

}
