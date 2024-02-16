// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, unused_element, use_build_context_synchronously

import 'package:authentico/components/text_field.dart';
import 'package:authentico/pages/forgot_pw_page.dart';
import 'package:authentico/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  //display a dialog message
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  //sign user in
  void signIn() async {
    // Show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Pop loading screen
      if (context.mounted) Navigator.pop(context);

      // Navigate to the camera page
      Navigator.pushReplacementNamed(
          context, '/camerascreen'); // Replace with your actual route name
    } on FirebaseAuthException catch (e) {
      // Pop loading
      Navigator.pop(context);
      // Display error message
      displayMessage(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 240,
                    height: 140.87,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Image.asset(
                      'assets/images/logo-modi.png',
                      fit: BoxFit.cover,
                      width: 240,
                      height: 140.87,
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PT Sans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PT Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 5),
                const Text(
                  "Password",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'PT Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.blue, // Change the color as needed
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: signIn,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(360.0, 50.0),
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have an account? ",
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage(onTap: () {})),
                        );
                      },
                      child: Text(
                        "Register Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
