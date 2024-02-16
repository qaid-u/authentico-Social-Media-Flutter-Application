// ignore_for_file: prefer_const_constructors

import 'package:authentico/pages/details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AlbumPage extends StatefulWidget {
  const AlbumPage({super.key});

  @override
  State<AlbumPage> createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String currentUserProfileImage = '';
  String currentUserUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserProfileImage(); // Fetch the current user's profile image on initialization
  }

  // Asynchronously fetch the 'profileimage' for the current user
  Future<void> _fetchCurrentUserProfileImage() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          currentUserProfileImage = userDoc['profileimage'] as String? ?? '';
          currentUserUsername = userDoc['username'] as String? ?? '';
        });
      }
    } catch (error) {
      // ignore: use_build_context_synchronously, avoid_print
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading:
            true, // Add this line for default back button
        centerTitle: true,
        elevation: 0,
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align to the start (left)
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(currentUserProfileImage.isNotEmpty
                  ? currentUserProfileImage
                  : 'https://icons8.com/icon/12438/customer'), // Use a default image if the profile image is not available
              radius: 24,
            ),
            const SizedBox(width: 8),
            Text(
              currentUserUsername,
              style: TextStyle(
                fontFamily: 'PT Sans',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: _buildUserPhotoAlbum(),
    );
  }

  Widget _buildUserPhotoAlbum() {
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

        // Sort the documents based on the 'timestamp' field in descending order
        List<DocumentSnapshot> sortedDocs = snapshot.data!.docs;
        sortedDocs.sort((a, b) {
          // Convert timestamp strings to DateTime and compare them
          DateTime timeA =
              DateTime.parse((a.data() as Map<String, dynamic>)['timestamp']);
          DateTime timeB =
              DateTime.parse((b.data() as Map<String, dynamic>)['timestamp']);
          return timeB.compareTo(timeA);
        });

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Increase the number of columns
            crossAxisSpacing: 2.0, // Adjust spacing between columns
            mainAxisSpacing: 2.0, // Adjust spacing between rows
          ),
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            return _buildUserPhotoAlbumItem(sortedDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildUserPhotoAlbumItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    String username = data['username'] as String? ?? 'Unknown';
    String profileImage = data['profileimage'] as String? ?? '';
    String uid = data['uid'] as String? ?? '';
    String postID = document.id;

    // Assuming `data` is a Map or some object with a 'likes' field
    dynamic likesData = data['likes'] ?? 0;

    // Cast the 'likesData' to a List of integers
    List<int> likes = [];

    if (likesData is List) {
      likes = likesData.map((like) => (like is int) ? like : 0).toList();
    } else if (likesData is int) {
      likes.add(likesData);
    }

    if (_auth.currentUser?.uid == uid) {
      return Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          title: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(
                        username: username,
                        likes: likes,
                        profileImage: profileImage,
                        frontImage: data['frontImagePath'],
                        rearImage: data['rearImagePath'],
                        postID: postID,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: AspectRatio(
                    aspectRatio: 1 / 1, // Adjust this ratio as needed
                    child: Image.network(
                      data['frontImagePath'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 2.0,
                top: -2.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsPage(
                          username: username,
                          likes: likes,
                          profileImage: profileImage,
                          frontImage: data['frontImagePath'],
                          rearImage: data['rearImagePath'],
                          postID: postID,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: Image.network(
                      data['rearImagePath'],
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8), // Adjust the spacing between images and text
              Text(
                data['time'].toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'PT Sans', // Adjust text style
                  color: Colors.black,
                ),
              ),
            ],
          ),
          tileColor: Colors.grey[350],
        ),
      );
    } else {
      return Container();
    }
  }
}
