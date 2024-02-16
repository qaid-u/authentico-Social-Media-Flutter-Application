// ignore_for_file: no_leading_underscores_for_local_identifiers, camel_case_types, avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:authentico/components/text_box.dart';

class OthersProfilePage extends StatefulWidget {
  const OthersProfilePage({super.key, required this.viewuid});

  final String viewuid;

  @override
  State<OthersProfilePage> createState() => _OthersProfilePageState();
}

// Function to send friend request

class _OthersProfilePageState extends State<OthersProfilePage> {
  final _controller = PageController();
  int _selectedImageIndex = -1;
  String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "USER PROFILE",
          style: TextStyle(
            fontFamily: 'Comfortaa',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Conditionally display the FlatButton only if users are not already friends
          Builder(
            builder: (context) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('friends')
                    .doc(widget.viewuid)
                    .collection('user_friends')
                    .doc(currentUserUid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasData && snapshot.data!.exists) {
                    // Users are already friends, hide the button
                    return Container();
                  }

                  // Users are not friends, display the button
                  return IconButton(
                    onPressed: () {
                      _sendFriendRequest(context);
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    tooltip: 'Add Friend',
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(widget.viewuid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        // Use NetworkImage to load the image from the URL
                        foregroundImage: NetworkImage(userData['profileimage']),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        userData['email'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PT Sans',
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 25.0),
                        child: Text(
                          'My Details',
                          style: TextStyle(
                            fontFamily: 'PT Sans',
                            fontStyle: FontStyle.normal,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextBox(
                        text: userData['username'],
                        sectionName: 'username',
                      ),
                      TextBox(
                        text: userData['bio'],
                        sectionName: 'bio',
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
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
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
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendFriendRequest(BuildContext context) async {
    try {
      // Get the current user UID
      String currentUserUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;

      DocumentSnapshot userData =
          await _firestore.collection('Users').doc(currentUserUid).get();

      // Check if the current user is authenticated
      if (currentUserUid.isNotEmpty) {
        // Check if users are already friends
        DocumentSnapshot friendSnapshot = await _firestore
            .collection('friends')
            .doc(widget.viewuid)
            .collection('user_friends')
            .doc(currentUserUid)
            .get();

        if (friendSnapshot.exists) {
          // Users are already friends, do nothing
          _showDialog(context, 'Info', 'You are already friends!');
        } else {
          // Add the viewuid to the friend requests collection
          await _firestore
              .collection('friend_requests')
              .doc(widget.viewuid)
              .collection('requests')
              .doc(currentUserUid)
              .set({
            'uid': currentUserUid,
            'username': userData['username'],
            'profileimage': userData['profileimage'],
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Show a success message on the screen
          _showDialog(context, 'Success', 'Friend request sent successfully!');
        }
      } else {
        // Show an error message on the screen
        _showDialog(context, 'Error', 'User not authenticated.');
      }
    } catch (error) {
      // Show an error message on the screen
      _showDialog(context, 'Error', 'Error sending friend request: $error');
    }
  }

  void _showDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
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

  Widget _buildGalleryPage() {
    final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: _firebaseFirestore
          .collection('posts')
          .where('uid', isEqualTo: widget.viewuid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return const Text("ERROR");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading...');
          return const Text("LOADING...");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          print('No data available.');
          return const Text("No data available.");
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
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: sortedDocs.length > 5 ? 5 : sortedDocs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = index;
                  });
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
      },
    );
  }

  Widget _buildGalleryItem(BuildContext context, DocumentSnapshot document,
      FirebaseFirestore firestore,
      {bool isLarge = false}) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String frontImagePath = data['frontImagePath'] as String? ?? '';
    String rearImagePath = data['rearImagePath'] as String? ?? '';
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
              ClipRRect(
                borderRadius: BorderRadius.circular(isLarge ? 20.0 : 12.0),
                child: Image.network(
                  frontImagePath,
                  fit: isLarge ? BoxFit.contain : BoxFit.cover,
                ),
              ),
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
          Navigator.of(context).pop();
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      frontImagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
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
