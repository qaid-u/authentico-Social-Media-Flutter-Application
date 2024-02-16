// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ThemedPost {
  final String postId;
  final String uid;
  final String rearimage;
  final String description;

  ThemedPost({
    required this.postId,
    required this.uid,
    required this.rearimage,
    required this.description,
  });
}

class ThemedPostGalleryPage extends StatefulWidget {
  final String challengeName;

  const ThemedPostGalleryPage({super.key, required this.challengeName});

  @override
  // ignore: library_private_types_in_public_api
  _ThemedPostGalleryPageState createState() => _ThemedPostGalleryPageState();
}

class _ThemedPostGalleryPageState extends State<ThemedPostGalleryPage> {
  late List<ThemedPost> themedPosts = [];
  final ImagePicker _imagePicker = ImagePicker();

  late CameraController _cameraController;
  late List<CameraDescription> cameras;
  final int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchThemedPosts();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();

      // Initialize the camera controller with the rear camera (index 0)
      _cameraController = CameraController(
        cameras[_currentCameraIndex], // Use index 0 for the rear camera
        ResolutionPreset.medium,
      );

      // Wait for the camera controller to initialize
      await _cameraController.initialize();

      // Ensure the widget is rebuilt after initialization
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error Initializing Camera'),
            content: Text('Error: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchThemedPosts() async {
    try {
      var themedPostsSnapshot = await FirebaseFirestore.instance
          .collection('themed_posts')
          .where('challenge', isEqualTo: widget.challengeName)
          .get();

      setState(() {
        themedPosts = themedPostsSnapshot.docs
            .map((doc) => ThemedPost(
                  postId: doc.id,
                  uid: doc['uid'],
                  rearimage: doc['rearimage'],
                  description: doc['description'],
                ))
            .toList();
      });
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error Fetching Themed Posts'),
            content: Text('Error: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _takePicture(bool isFront) async {
    TextEditingController descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Description'),
        content: TextField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: 'Enter a description...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _captureAndUploadImage(false, descriptionController.text);
            },
            child: const Text('Take Picture'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndUploadImage(
      bool isFront, String description) async {
    try {
      final imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxHeight: 800,
        maxWidth: 800,
      );

      if (imageFile == null) return;

      final File file = File(imageFile.path);
      final String fileName =
          DateTime.now().millisecondsSinceEpoch.toString();

      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('themed_posts/$fileName.jpg');
      await storageRef.putFile(file);

      final String downloadURL = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('themed_posts').doc(widget.challengeName).set({
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'challenge': widget.challengeName,
        'rearimage': downloadURL,
        'description': description,
      });

      await fetchThemedPosts();
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error Taking Picture'),
            content: Text('Error: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.challengeName} Gallery'),
      ),
      body: themedPosts.isEmpty
          ? const Center(child: Text('No themed posts available.'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: themedPosts.length,
              itemBuilder: (context, index) {
                ThemedPost themedPost = themedPosts[index];

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    themedPost.rearimage,
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: const Text('Take Rear Picture'),
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture(false);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
