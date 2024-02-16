// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:authentico/image/pfp_image.dart';
import 'package:authentico/pages/album_page.dart';
import 'package:authentico/pages/friends_requests_page.dart';
import 'package:authentico/pages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:authentico/components/text_box.dart';
import 'package:image_cropper/image_cropper.dart';

final imagesHelper = ImageHelper();

class ProfileImage extends StatefulWidget {
  const ProfileImage({
    super.key,
    required this.initials,
  });

  final String initials;

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
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
          return const CircularProgressIndicator(); // While data is loading
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null || !snapshot.data!.exists) {
          // Handle the case where the document doesn't exist
          return const Text('Document does not exist.');
        } else {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final profileImage = userData['profileimage'] ?? '';

          return Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 56,
                // Use NetworkImage to load the image from the URL
                foregroundImage:
                    profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
              ),
              Positioned(
                bottom: -10,
                left: 220,
                child: IconButton(
                  iconSize: 32,
                  onPressed: () async {
                    final files = await imagesHelper.pickImage();
                    if (files != null) {
                      final croppedFile = await imagesHelper.crop(
                        file: files,
                        cropstyle: CropStyle.circle,
                      );
                      if (croppedFile != null) {
                        // Update Firebase database with new image data
                        await updateFirebaseDatabase(croppedFile.path);
                      }
                    }
                  },
                  icon: const Icon(Icons.add_a_photo),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Function to update image data in Firebase
  Future<void> updateFirebaseDatabase(String localImagePath) async {
    try {
      const path = 'user_images/';
      // Reference to the Firebase Storage path
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$path$localImagePath.jpg');

      // Upload image to Firebase Storage
      await ref.putFile(File(localImagePath));

      // Get the download URL of the uploaded image
      final String remoteImagePath = await ref.getDownloadURL();

      // Assuming you have a 'users' collection in your Firestore
      await _firebaseFirestore.collection('Users').doc(uid).update({
        'profileimage': remoteImagePath,
      });
    } catch (e) {
      displayMessage('Error updating Firebase database: $e');
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _controller = PageController();
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  int _selectedImageIndex = -1;

  //all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  //edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          //cancel buttton
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          //save button
          TextButton(
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          )
        ],
      ),
    );

    //update in firestore
    if (newValue.trim().isNotEmpty) {
      //only update when there is something textfield
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text("USER PROFILE",
        style: TextStyle(
          fontFamily: 'Comfortaa',
          fontWeight: FontWeight.bold,
        ),),
        leading: IconButton(
          icon: const Icon(Icons.settings), onPressed: () { 
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
           },
        ),
        actions: [IconButton(
          icon: const Icon(Icons.person_pin_rounded),
          // ignore: prefer_const_constructors
          onPressed: () {
            Navigator.push(context, 
            MaterialPageRoute(builder: (context) => const FriendRequestsPage()));
          },
        ),]
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              //get user data
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                return ListView(
                  shrinkWrap:
                      true, // Add shrinkWrap to avoid unbounded height issue
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const ProfileImage(initials: ''),
                    Text(
                      currentUser.email!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'PT Sans',
                          fontStyle: FontStyle.italic,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 70,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Details',
                        style: TextStyle(
                            fontFamily: 'PT Sans',
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextBox(
                      text: userData['username'],
                      sectionName: 'username',
                      onPressed: () => editField('username'),
                    ),
                    TextBox(
                      text: userData['bio'],
                      sectionName: 'bio',
                      onPressed: () => editField('bio'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Albums',
                              style: TextStyle(
                                  fontFamily: 'PT Sans',
                                  fontStyle: FontStyle.normal,
                                  fontSize: 16,
                                  color: Colors.black),
                            ),
                          ]),
                    ),
                    SizedBox(
                      height: 200, // Set the desired height for the gallery
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return _buildGalleryPage();
                        },
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error${snapshot.error}'),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildGalleryPage() {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
        stream: _firebaseFirestore
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("ERROR");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("LOADING...");
          }

          List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
          sortedDocs.sort((a, b) {
            DateTime timeA =
                DateTime.parse((a.data() as Map<String, dynamic>)['timestamp']);
            DateTime timeB =
                DateTime.parse((b.data() as Map<String, dynamic>)['timestamp']);
            return timeB.compareTo(timeA);
          });

          return SizedBox(
            height: 200, // Set the desired height for the gallery
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Set the scroll direction
              itemCount: sortedDocs.length > 5 ? 5 : sortedDocs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  onDoubleTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AlbumPage(),
                      ),
                    );
                  },
                  child: _buildGalleryItem(
                    context,
                    sortedDocs[index],
                    _firebaseFirestore,
                    isLarge: _selectedImageIndex == index,
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildGalleryItem(BuildContext context, DocumentSnapshot document,
      FirebaseFirestore firestore,
      {bool isLarge = false}) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String frontImagePath = data['frontImagePath'] as String? ?? '';
    String rearImagePath = data['rearImagePath'] as String? ?? '';

    // Use post ID as the tag for Hero animation
    String heroTag = document.id;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return FadeTransition(
              opacity: animation,
              child: _buildEnlargedGalleryItem(context, document),
            );
          },
        ));
      },
      child: Hero(
        tag: heroTag,
        child: Card(
          elevation: isLarge ? 10.0 : 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLarge ? 20.0 : 12.0),
          ),
          child: Stack(
            children: [
              // Front Image
              ClipRRect(
                borderRadius: BorderRadius.circular(isLarge ? 20.0 : 12.0),
                child: Image.network(
                  frontImagePath,
                  fit: isLarge ? BoxFit.contain : BoxFit.cover,
                ),
              ),
              // Rear Image
              Positioned(
                left: isLarge ? 10.0 : 2.0,
                top: isLarge ? -10.0 : -2.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isLarge ? 20.0 : 12.0),
                  child: Image.network(
                    rearImagePath,
                    width: isLarge ? 150 : 75,
                    height: isLarge ? 150 : 75,
                    fit: isLarge ? BoxFit.contain : BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnlargedGalleryItem(
      BuildContext context, DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String frontImagePath = data['frontImagePath'] as String? ?? '';
    String rearImagePath = data['rearImagePath'] as String? ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // Close the enlarged view on tap
        },
        child: Center(
          child: Hero(
            tag: document.id,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                children: [
                  // Front Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      frontImagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Rear Image
                  Positioned(
                    left: 10.0,
                    top: -10.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        rearImagePath,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
