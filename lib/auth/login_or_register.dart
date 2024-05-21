import 'package:flutter/material.dart';
import 'package:note_flutter/screens/signin.dart';
import 'package:note_flutter/screens/signup.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({Key? key}) : super(key: key);

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage
          ? SignInScreen(
              onTap: togglePages,
            )
          : SignUpScreen(
              onTap: togglePages,
            ),
    );
  }
}
