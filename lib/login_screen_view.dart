import 'package:authentication/login_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  LoginScreenController controller = Get.put(LoginScreenController());
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
            ElevatedButton(onPressed: (){}, child: Text("Email Verify")),

          ],
        ),
      ),
    );
  }
}
