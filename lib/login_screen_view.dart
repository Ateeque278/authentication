import 'package:authentication/login_screen_controller.dart';
import 'package:authentication/testing_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  AuthController controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){
              controller.registerUser("email@test.com", "123", context);
            }, child: Text("Email Register")),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              controller.loginUser("email@test.com", "123", context);
            }, child: Text("Login")),
            SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ExceptionTestPage()),
              );

            }, child: Text("Test")),

          ],
        ),
      ),
    );
  }
}
