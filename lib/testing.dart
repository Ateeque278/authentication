import 'package:flutter/material.dart';

import 'auth_api_provider.dart';

class Testing extends StatelessWidget {
   Testing({super.key});
  final auth = AuthApiProvider();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () async {
                 await auth.registerUser("email1@gmail.com", "12345678");
            }, child: Text("Email-Register")),
            SizedBox(height: 10,),
            ElevatedButton(onPressed: () async {
                await auth.loginUser("email2@gmail.com", "12345678");
            }, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
