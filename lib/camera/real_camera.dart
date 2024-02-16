// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, avoid_print, prefer_final_fields, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';
import 'package:authentico/pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String uid;
  late String username;
  late String time;
  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isTakingPicture = false;
  bool _isSwitchingCamera = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _initializeCamera();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // Retrieve additional user data from Firestore
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          setState(() {
            uid = user.uid;
            username = userSnapshot['username'] ?? 'DefaultUsername';
            time = DateTime.now().toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      // Initialize the camera controller with the initial camera
      _cameraController = CameraController(
        cameras[_currentCameraIndex],
        ResolutionPreset.medium,
      );

      // Wait for the camera controller to initialize
      await _cameraController.initialize();

      // Set flash mode to off after initialization
      await _cameraController.setFlashMode(FlashMode.off);

      // Ensure the widget is rebuilt after initialization
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    try {
      // Toggle between available cameras
      _currentCameraIndex = (_currentCameraIndex + 1) % cameras.length;

      // Initialize a new controller with the new camera
      await _cameraController.dispose(); // Dispose the old controller
      _cameraController = CameraController(
        cameras[_currentCameraIndex],
        ResolutionPreset.medium,
      );

      // Wait for the camera controller to initialize
      await _cameraController.initialize();

      // Ensure the widget is rebuilt after initialization
      if (mounted) {
        setState(() {});

        // Check if the new camera is the front camera and turn off the flashlight
        if (_currentCameraIndex == 1) {
          await _cameraController.setFlashMode(FlashMode.off);
        }
      }
    } catch (e) {
      print("Error toggling camera: $e");
    }
  }

  Future<void> _takePicture() async {
    try {
      await _fetchUserData();

      if (_isTakingPicture) {
        return; // Prevent multiple simultaneous picture-taking attempts
      }

      setState(() {
        _isTakingPicture = true;
      });

      // Ensure that the camera controller is initialized before taking pictures
      if (_cameraController != null && _isCameraInitialized) {
        // Take a picture with the rear camera
        final XFile rearImage = await _cameraController.takePicture();

        String postId = DateTime.now().millisecondsSinceEpoch.toString();

        // Upload image to Firebase Cloud Firestore and get the image path
        await _uploadImage(rearImage, 'rear', postId);

        // Dispose of the current camera controller before switching to the front camera
        await _cameraController.dispose();

        // Introduce a delay before switching to the front camera (adjust the duration as needed)
        await Future.delayed(Duration(seconds: 5));

        // Switch to the front camera
        await _toggleCamera();

        // Take a picture with the front camera
        final XFile frontImage = await _cameraController.takePicture();

        // Upload image to Firebase Cloud Firestore and get the image path
        await _uploadImage(frontImage, 'front', postId);

        // Display the captured image using a Future.delayed to ensure it's shown after the current frame
        await Future.delayed(Duration(seconds: 2));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                children: [
                  Text('Rear Camera Image:'),
                  Image.file(
                    File(rearImage.path),
                    width: 240, // Adjust the width as needed
                    height: 240, // Adjust the height as needed
                  ),
                  SizedBox(height: 2.0), // Add some spacing between images
                  Text('Front Camera Image:'),
                  Image.file(
                    File(frontImage.path),
                    width: 240, // Adjust the width as needed
                    height: 240, // Adjust the height as needed
                  ),
                ],
              ),
            );
          },
        );

        await Future.delayed(Duration(
            seconds: 3)); // Navigate to another page and pass the image paths
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else {
        print("Error: Camera controller not initialized.");
      }
    } catch (e) {
      print("Error taking pictures or uploading to Firestore: $e");
    } finally {
      setState(() {
        _isTakingPicture = false;
      });
    }
  }

  Future<String> _uploadImage(
      XFile image, String cameraType, String postID) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentReference userDocRef =
            _firestore.collection('Users').doc(user.uid);
        DocumentSnapshot userSnapshot = await userDocRef.get();

        // Check if the user snapshot exists
        if (userSnapshot.exists) {
          Map<String, dynamic>? userData =
              userSnapshot.data() as Map<String, dynamic>?;

          // Check if the user data contains the 'username' field
          if (userData != null && userData.containsKey('username')) {
            // Get the username from user data
            String username = userData['username'];
            String userImage = userData['profileimage'];

            const path = 'post_images/';

            // Upload image to Firebase Cloud Firestore
            final CollectionReference postsCollection =
                FirebaseFirestore.instance.collection('posts');

            final String postId = postID;

            final String otherId =
                DateTime.now().millisecondsSinceEpoch.toString();

            // Reference to the Firebase Storage path
            final ref = firebase_storage.FirebaseStorage.instance
                .ref()
                .child('$path$otherId.jpg');

            // Upload image to Firebase Storage
            await ref.putFile(File(image.path));

            // Get the download URL of the uploaded image
            final String imagePath = await ref.getDownloadURL();

            if (cameraType != 'front') {
              String timestampString = DateTime.now().toUtc().toIso8601String();
              DateTime timestamp = DateTime.parse(timestampString);

              // Format the date only
              String dateOnly = DateFormat('yyyy-MM-dd').format(timestamp);

              // Format the time in 24-hour format (HH:mm)
              String timeIn24HourFormat = DateFormat('HH:mm').format(timestamp);

              await postsCollection.doc(postId).set({
                'uid': user.uid,
                'postId': postId,
                'username': username,
                'frontImagePath': "",
                'rearImagePath': imagePath,
                'profileimage': userImage,
                'timestamp': DateTime.now().toUtc().toIso8601String(),
                'time': "$dateOnly  $timeIn24HourFormat",
                'likes': [],
              });
            } else {
              await postsCollection.doc(postId).update({
                'frontImagePath': imagePath,
              });
            }
            // Print logs
            print("$cameraType Image path: ${image.path}");
            print("$cameraType Image uploaded to Firestore with ID: $postId");

            return imagePath;
          } else {
            print(
                "Error: 'username' field does not exist in user snapshot data.");
            throw Exception(
                "'username' field does not exist in user snapshot data.");
          }
        } else {
          // Create a new user document with default data (optional)
          // await userDocRef.set({
          //   'username': 'DefaultUsername', // You can set a default username or customize it
          // });

          print("User document does not exist for UID: ${user.uid}");

          // You might want to handle this case based on your application logic
          throw Exception("User document does not exist for UID: ${user.uid}");
        }
      } else {
        print("Error: User not authenticated.");
        // Handle the case where the user is not authenticated
        throw Exception("User not authenticated");
      }
    } catch (e) {
      print("Error uploading image to Firestore: $e");
      rethrow; // Rethrow the error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Center(
            child: Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Image.asset(
                'assets/images/logo-modi.png',
                fit: BoxFit.cover,
                width: 120,
                height: 70,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: _isCameraInitialized
                  ? CameraPreview(_cameraController)
                  : Container(), // Placeholder or loading indicator
            ),
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _takePicture,
                child: Icon(Icons.camera_alt_rounded, color: Colors.blue),
              ),
            ],
          ),
          if (_isSwitchingCamera || _isTakingPicture)
            Center(
              child: CircularProgressIndicator(
                strokeAlign: CircularProgressIndicator.strokeAlignCenter,
                valueColor: AlwaysStoppedAnimation(Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
