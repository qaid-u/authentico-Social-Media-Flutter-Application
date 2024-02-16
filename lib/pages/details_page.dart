// ignore_for_file: must_be_immutable, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String username;
  final List<int> likes;
  final String profileImage;
  final String frontImage;
  final String rearImage;
  final String postID;

  const DetailsPage({
    required this.username,
    required this.likes,
    required this.profileImage,
    required this.frontImage,
    required this.rearImage,
    required this.postID,
    super.key,
  });

  void deleteData(String documentId, BuildContext context) async {
    try {
      // Get a reference to the document
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(documentId)
          .delete();

      // Show an alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Item Deleted'),
            content: Text('The item has been successfully deleted.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert dialog
                  Navigator.pop(context); // Navigate back to the photo album
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Show an error alert dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error deleting the item. Please try again.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the alert dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      print('Error deleting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Hero(
              tag: 'logo',
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    frontImage,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: -35,
                    top: 0,
                    child: Image.network(
                      rearImage,
                      width: 290,
                      height: 290,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                      Text(
                        username,
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Likes: ${likes.join(", ")}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      // Other relevant information based on your data
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your buy logic here
                          // Assuming 'data' contains the document ID for deletion
                          deleteData(postID, context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
