// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:authentico/pages/about_page.dart';
import 'package:authentico/pages/help_centre.dart';
import 'package:authentico/pages/login_page.dart';
import 'package:authentico/themes/themes.dart';
import 'package:authentico/themes/themes_provider.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String uid;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // While data is loading
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || !snapshot.data!.exists) {
          // Handle the case where the document doesn't exist
          return Text('Document does not exist.');
        } else {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImage = userData['profileimage'] ?? '';

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              title: Text("SETTINGS",
              style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
          ),),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 56,
                          // Use NetworkImage to load the image from the URL
                          foregroundImage: profileImage.isNotEmpty
                              ? NetworkImage(profileImage)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  SettingsGroup(
                    items: [
                      SettingsItem(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AboutPage()),
                          );
                        },
                        icons: CupertinoIcons.info_circle,
                        iconStyle: IconStyle(),
                        title: 'About',
                        subtitle: "Learn More About Authentico",
                      ),
                      SettingsItem(
                        onTap: () {},
                        icons: Icons.dark_mode_rounded,
                        iconStyle: IconStyle(
                          iconsColor: Colors.white,
                          withBackground: true,
                          backgroundColor: Colors.red,
                        ),
                        title: 'Dark mode',
                        subtitle: "Automatic",
                        trailing: Switch.adaptive(
                          value:
                              Provider.of<ThemeProvider>(context).themeData ==
                                  darkMode,
                          onChanged: (value) {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
                          },
                        ),
                      ),
                    ],
                  ),
                  SettingsGroup(
                    items: [
                      SettingsItem(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpCenterPage()),
                          );
                        },
                        icons: Icons.help_center,
                        iconStyle: IconStyle(
                          backgroundColor: Colors.purple,
                        ),
                        title: 'Help',
                        subtitle: "Help Centre",
                      ),
                    ],
                  ),
                  // You can add a settings title
                  SettingsGroup(
                    settingsGroupTitle: "Account",
                    items: [
                      SettingsItem(
                        onTap: () {
                          _showSignOutDialog(context);
                        },
                        icons: Icons.exit_to_app_rounded,
                        title: "Sign Out",
                      ),
                      SettingsItem(
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                        icons: CupertinoIcons.delete_solid,
                        title: "Delete account",
                        titleStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

void _showSignOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Sign Out"),
        content: Text("Are you sure you want to sign out?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => LoginPage(onTap: () {})),
              );
            },
            child: Text("Sign Out"),
          ),
        ],
      );
    },
  );
}

void _showDeleteAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete Account"),
        content: Text(
            "Are you sure you want to delete your account? This action is irreversible."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              String? error = await _deleteAccount();
              if (error != null) {
                // Display an AlertDialog or handle the error as needed
                showDialog(
                  context: context, // Make sure to have a valid context
                  builder: (context) => AlertDialog(
                    title: Text("Error"),
                    content: Text(error),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginPage(onTap: () {})),
                );
              }
            },
            child: Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<String?> _deleteAccount() async {
  try {
    // Get the current user from FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Delete user from Firebase Authentication
      await user.delete();

      // Delete user data from Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .delete();
      return null;
    }
  } catch (e) {
    // Handle errors here (e.g., display an error message)
    return ('Error deleting account: $e');
  }
  return null;
}
