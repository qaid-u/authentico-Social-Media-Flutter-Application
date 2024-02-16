// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:authentico/components/text_field.dart';
import 'package:authentico/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPassswordTextController = TextEditingController();

  //sign user up
  void signUp() async {
    void displayMessage(String message) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(message),
              ));
    }

    //show loading circle
    showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()));

    //make sure passwords match
    if (passwordTextController.text != confirmPassswordTextController.text) {
      //pop loading circle
      Navigator.pop(context);
      //show error to user
      displayMessage("Passwords don't match!");
      return;
    }

    //try creating the user
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //after creating the user, create a new dosument in cloud firestore called Users
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set({
        'username': emailTextController.text.split('@')[0], //initial username
        'bio': 'empty bio', //initail empty bio
        'uid': userCredential.user!.uid,
        'email': userCredential.user!.email,
        'profileimage': 'https://icons8.com/icon/12438/customer',
        'posts': [],

        //add any fields
      });

      //pop loading circle
      Navigator.pop(context);

      //show success message to the user
      displayMessage("Registered successfully!");

      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //pop loading circle
      Navigator.pop(context);
      //show error to user
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

            //Authentico Message

            const SizedBox(height: 50),

            const Text(
              "Create an account",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'PT Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Email",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'PT Sans',
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),

            //email textfield
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
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),

            //password textfield
            MyTextField(
              controller: passwordTextController,
              hintText: 'Password',
              obscureText: true,
            ),

            const SizedBox(height: 5),

            const Text(
              "Confirm Password",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'PT Sans',
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
            ),

            MyTextField(
              controller: confirmPassswordTextController,
              hintText: 'Confirm password',
              obscureText: true,
            ),

            const SizedBox(height: 25),

            //sign up button
            TextButton(
              onPressed: signUp,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account.",
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
                          builder: (context) => LoginPage(onTap: () {})),
                    );
                  },
                  child: Text(
                    "Login now",
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
      ))),
    );
  }
}
