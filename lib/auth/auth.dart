import 'package:authentico/camera/real_camera.dart';
import 'package:authentico/pages/home_page.dart';
import 'package:authentico/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              // ignore: prefer_const_constructors
              return CameraPage();
            }

            // user not logged in
            else {
              return LoginPage(
                onTap: () {},
              );
            }
          }),
    );
  }
}
