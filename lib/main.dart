// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, depend_on_referenced_packages

import 'package:authentico/auth/auth.dart';
import 'package:authentico/camera/real_camera.dart';
import 'package:authentico/pages/album_page.dart';
import 'package:authentico/pages/discovery_page.dart';
import 'package:authentico/pages/friends_page.dart';
import 'package:authentico/pages/home_page.dart';
import 'package:authentico/pages/profile_page.dart';
import 'package:authentico/pages/settings_page.dart';
import 'package:authentico/themes/themes_provider.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugDumpRenderTree();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Provider.of<ThemeProvider>(context).themeData,
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      home: AuthPage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/profilepage': (context) => ProfilePage(),
        '/discoverypage': (context) => DiscoveryPage(),
        '/albumpage': (context) => AlbumPage(),
        '/settingspage': (context) => SettingsPage(),
        '/camerascreen': (context) => CameraPage(),
        '/friendspage': (context) => FriendsPage(),
      },
    );
  }
}
